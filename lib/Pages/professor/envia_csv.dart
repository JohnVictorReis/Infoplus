// ignore_for_file: unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

class PaginaCadastroCSV extends StatefulWidget {
  const PaginaCadastroCSV({super.key});

  @override
  State<PaginaCadastroCSV> createState() => _PaginaCadastroCSVState();
}

class _PaginaCadastroCSVState extends State<PaginaCadastroCSV> {
  String? selectedTurma;
  String? selectedMateria;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

      CollectionReference notasCollection = FirebaseFirestore.instance
          .collection('turmas')
          .doc(selectedTurma)
          .collection('materias')
          .doc(selectedMateria)
          .collection('notas');

      List<String> naoEncontrados = [];

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
          naoEncontrados.add(cpfAluno);
          continue;
        }

        var alunoDoc = usersSnapshot.docs.first;
        String email = alunoDoc['email'];
        String uid = alunoDoc.id;

        await notasCollection.add({
          'aluno': aluno,
          'atividade': atividade,
          'nota': nota,
          'email': email,
        });

        String ultimos4 = cpfAluno.length >= 4
            ? cpfAluno.substring(cpfAluno.length - 4)
            : cpfAluno;

        String mensagem =
            "Nova nota lançada para a matéria '$selectedMateria' atividade '$atividade':";

        String notificationId = "${DateTime.now().millisecondsSinceEpoch}";

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notificacoes')
            .doc(notificationId)
            .set({
          'mensagem': mensagem,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      String msg = "Notas cadastradas com sucesso!";
      if (naoEncontrados.isNotEmpty) {
        msg +=
            "\n\nOs seguintes CPFs não foram encontrados:\n${naoEncontrados.join('\n')}";
        _mostrarDialogoErroUsuarios(naoEncontrados);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar notas: $e")),
      );
    }
  }

//Aqui pra cima é o código que foi comentado para teste da função de upload de notas juntamente com a criação do token de notificação
  void _mostrarDialogoErroUsuarios(List<String> naoEncontrados) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Usuários não encontrados"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: naoEncontrados.map((cpf) => Text("- $cpf")).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: Text("Fechar"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
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

      final bytes = await file.readAsBytes();
      late String input;
      try {
        input = const Utf8Decoder().convert(bytes);
      } catch (_) {
        input = const Latin1Decoder().convert(bytes);
      }

      List<List<dynamic>> data =
          CsvToListConverter(fieldDelimiter: ';').convert(input);

      setState(() {
        csvData = data.skip(1).toList();
      });

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
