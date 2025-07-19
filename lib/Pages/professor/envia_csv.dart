// ignore_for_file: unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

class PaginaCadastroCSV extends StatefulWidget {
  const PaginaCadastroCSV({super.key});

  @override
  State<PaginaCadastroCSV> createState() => _PaginaCadastroCSVState();
}

class _PaginaCadastroCSVState extends State<PaginaCadastroCSV> {
  String? selectedTurma;
  String? selectedMateria;

  List<String> turmas = [];
  List<String> materias = [];
  List<List<dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
    _getTurmasProfessor();
  }

  Future<void> _getTurmasProfessor() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        List<dynamic> turmasList = userDoc.data()!['turmas'] ?? [];
        setState(() {
          turmas = List<String>.from(turmasList.map((e) => e.toString()));
        });
      }
    } catch (e) {
      print("Erro ao recuperar turmas: $e");
    }
  }

  Future<void> _uploadDataToFirestore(List<List<dynamic>> data) async {
    try {
      if (selectedTurma == null || selectedMateria == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selecione uma turma e uma matéria.")),
        );
        return;
      }

      // Verificar se o documento da matéria existe na coleção antes de adicionar as notas
      DocumentSnapshot materiaDoc = await FirebaseFirestore.instance
          .collection('turmas')
          .doc(selectedTurma)
          .collection('materias')
          .doc(selectedMateria)
          .get();

      if (!materiaDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("A matéria selecionada não existe na turma.")),
        );
        return;
      }

      // Referência da subcoleção de notas dentro da turma e matéria selecionada
      CollectionReference notasCollection = FirebaseFirestore.instance
          .collection('turmas')
          .doc(selectedTurma)
          .collection('materias')
          .doc(selectedMateria)
          .collection('notas');

      for (var row in data) {
        var aluno = row[0];
        var atividade = row[1];
        var nota = row[2];
        var codAluno = row[3];

        String cpfAluno = codAluno.toString().trim();

        QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('cpf', isEqualTo: cpfAluno)
            .get();

        if (usersSnapshot.docs.isEmpty) {
          print("Aluno com CPF $cpfAluno não encontrado.");
          continue;
        }

        var alunoDoc = usersSnapshot.docs.first;
        String email = alunoDoc['email'];
        String uid = alunoDoc.id;

        // Envia a nota para a subcoleção
        await notasCollection.add({
          'aluno': aluno,
          'atividade': atividade,
          'nota': nota,
          'email': email,
        });

        //Criar notificação com base no CPF e atividade
        String ultimos4 = cpfAluno.length >= 4
            ? cpfAluno.substring(cpfAluno.length - 4)
            : cpfAluno;
        String mensagem =
            "Nova nota lançada para a matéria '$selectedMateria' atividade '$atividade':";

        // Criando um ID único para cada notificação (utilizando o timestamp)
        String notificationId =
            "${DateTime.now().millisecondsSinceEpoch}"; // ID único para cada notificação

        // Salvando a notificação no Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notificacoes')
            .doc(notificationId) // ID único por notificação
            .set({
          'mensagem': mensagem,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Notas cadastradas com sucesso!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar notas: $e")),
      );
    }
  }

  Future<void> _updateMaterias(String turma) async {
    materias = [];
    try {
      QuerySnapshot materiasSnapshot = await FirebaseFirestore.instance
          .collection('turmas')
          .doc(turma)
          .collection('materias')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      for (var doc in materiasSnapshot.docs) {
        setState(() {
          materias.add(doc.id);
        });
      }
    } catch (e) {
      print("Erro ao recuperar matérias: $e");
    }
  }

  Future<void> _pickAndLoadCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      final input = file.readAsStringSync();
      List<List<dynamic>> data =
          CsvToListConverter(fieldDelimiter: ';').convert(input);

      // Ignora a primeira linha (cabeçalho)
      setState(() {
        csvData = data.skip(1).toList();
      });

      // Salvar os dados no Firestore
      await _uploadDataToFirestore(csvData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar Notas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedTurma,
              hint: Text("Selecione uma turma"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTurma = newValue;
                  _updateMaterias(selectedTurma!);
                });
              },
              items: turmas.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedMateria,
              hint: Text("Selecione uma matéria"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedMateria = newValue;
                });
              },
              items: materias.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            MyButton(
              onTap: () async {
                await _pickAndLoadCsv();
              },
              text: 'BUSCAR CSV',
              icon: Icons.file_upload,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: csvData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(csvData[index].join(', ')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
