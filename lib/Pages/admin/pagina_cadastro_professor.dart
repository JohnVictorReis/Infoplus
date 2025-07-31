// ignore_for_file: avoid_print, unnecessary_string_escapes

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_adm.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
final TextEditingController _nomeController = TextEditingController();
final TextEditingController _codigoProfessorController =
    TextEditingController();
final TextEditingController _nomeMateriaController = TextEditingController();
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//

class PaginaCadastroProfessor extends StatefulWidget {
  const PaginaCadastroProfessor({super.key});

  @override
  State<PaginaCadastroProfessor> createState() =>
      _PaginaCadastroProfessorState();
}

class _PaginaCadastroProfessorState extends State<PaginaCadastroProfessor> {
  List<String> turmas = [];
  List<String> selectedTurmas = [];

  @override
  void initState() {
    super.initState();
    _getTurmas();
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _getTurmas() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('turmas').get();
      setState(() {
        turmas = snapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print("Erro ao buscar turmas: $e");
    }
  }
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//

  String _gerarEmail(String nome, String codigo) {
    String primeiroNome = nome.split(' ')[0].toLowerCase();
    return '$primeiroNome\_$codigo.professor@mail.com';
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _cadastrarProfessorManual() async {
    String nome = _nomeController.text.trim();
    String codigo = _codigoProfessorController.text.trim();
    String materia = _nomeMateriaController.text.trim();

    try {
      await _cadastrarProfessor(nome, codigo, materia);

      // Exibe snackbar de sucesso
      Get.snackbar("Sucesso", "Professor cadastrado com sucesso!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3));

      // Limpa campos
      _nomeController.clear();
      _codigoProfessorController.clear();
      _nomeMateriaController.clear();
      selectedTurmas.clear();
      setState(() {});

      // Redireciona após pequeno delay para exibir snackbar
      await Future.delayed(const Duration(seconds: 1));
      Get.offAll(() => const PaginaAdm());
    } catch (e) {
      print("Erro ao cadastrar professor manualmente: $e");
      Get.snackbar("Erro", "Não foi possível cadastrar o professor.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _cadastrarProfessor(
      String nome, String codigo, String materia) async {
    String email = _gerarEmail(nome, codigo);
    String senha = 'professor';

    try {
      UserCredential cred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      String uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nome': nome,
        'codigoProfessor': codigo,
        'turmas': selectedTurmas,
        'role': 'professor',
        'email': email,
        'materia': materia,
      });

      for (String turmaId in selectedTurmas) {
        await FirebaseFirestore.instance
            .collection('turmas')
            .doc(turmaId)
            .collection('materias')
            .doc(materia)
            .set({
          'email': email,
          'nome': materia,
          'professor': nome,
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw 'duplicado:$email';
      } else {
        throw 'erro:$email';
      }
    }
  }

Future<void> _importarCSV() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) {
      throw Exception("Nenhum arquivo selecionado.");
    }

    final filePath = result.files.single.path;
    if (filePath == null) throw Exception("Caminho do arquivo não encontrado.");

    final fileBytes = await File(filePath).readAsBytes();

    late String csvContent;
    try {
      csvContent = const Utf8Decoder().convert(fileBytes);
    } catch (_) {
      csvContent = const Latin1Decoder().convert(fileBytes);
    }

    final rows = const CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvContent);

    final snapshot = await FirebaseFirestore.instance.collection('turmas').get();
    final turmasExistentes = snapshot.docs.map((e) => e.id).toList();

    List<String> erros = [];
    int sucesso = 0;

    for (int i = 1; i < rows.length; i++) {
      final linha = rows[i];
      if (linha.length < 4) continue;

      final nome = linha[0].toString().trim();
      final codigo = linha[1].toString().trim();
      final novaMateria = linha[2].toString().trim();
      final turmasRaw = linha[3].toString().trim();

      final turmasLidas = turmasRaw
          .split(',')
          .map((t) => t.trim())
          .where((t) => turmasExistentes.contains(t))
          .toList();

      if (turmasLidas.isEmpty) {
        erros.add("Nenhuma turma válida para $nome");
        continue;
      }

      final primeiroNome = nome.split(' ').first.toLowerCase();
      final email = "${primeiroNome}_$codigo.professor@mail.com";
      const senha = 'professor';

      try {
        // Tentativa de criação do usuário
        final cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: senha);
        final uid = cred.user!.uid;

        // Cadastro do novo professor
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'nome': nome,
          'codigoProfessor': codigo,
          'turmas': turmasLidas,
          'role': 'professor',
          'email': email,
          'materia': [novaMateria],
          'primeiro_login': true,
        });

        // Criação da matéria nas turmas
        for (String turmaId in turmasLidas) {
          await FirebaseFirestore.instance
              .collection('turmas')
              .doc(turmaId)
              .collection('materias')
              .doc(novaMateria)
              .set({
            'email': email,
            'nome': novaMateria,
            'professor': nome,
          });
        }

        sucesso++;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Atualiza professor existente
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (userSnapshot.docs.isEmpty) {
            erros.add("Usuário $email não encontrado no Firestore.");
            continue;
          }

          final userDoc = userSnapshot.docs.first;
          final userData = userDoc.data();
          final uid = userDoc.id;

          // Atualiza matérias
          final materiasAtuais = userData['materia'] is List
              ? List<String>.from(userData['materia'])
              : [userData['materia'].toString()];
          if (!materiasAtuais.contains(novaMateria)) {
            materiasAtuais.add(novaMateria);
          }

          // Atualiza turmas
          final turmasAtuais = userData['turmas'] is List
              ? List<String>.from(userData['turmas'])
              : [userData['turmas'].toString()];
          final novasTurmas = {...turmasAtuais, ...turmasLidas}.toList();

          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'materia': materiasAtuais,
            'turmas': novasTurmas,
          });

          // Criação da nova matéria nas turmas
          for (String turmaId in turmasLidas) {
            await FirebaseFirestore.instance
                .collection('turmas')
                .doc(turmaId)
                .collection('materias')
                .doc(novaMateria)
                .set({
              'email': email,
              'nome': novaMateria,
              'professor': nome,
            });
          }

          sucesso++;
        } else {
          erros.add("Erro ao cadastrar $email: ${e.message}");
        }
      } catch (e) {
        erros.add("Erro inesperado com $nome: $e");
      }
    }

    String msg = "$sucesso professor(es) cadastrados/atualizados.";
    if (erros.isNotEmpty) {
      msg += "\n\nErros:\n${erros.join('\n')}";
    }

    Get.snackbar("Importação Finalizada", msg,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 10));
  } catch (e) {
    print("Erro ao importar CSV: $e");
    Get.snackbar("Erro", "Falha ao importar CSV",
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cadastro de Professor",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.school_rounded, size: 40),
              const SizedBox(height: 20),
              const Text('Informações do Professor',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
              const SizedBox(height: 30),
              _inputField(_nomeController, 'Nome do Professor'),
              _inputField(_codigoProfessorController, 'Código do Professor'),
              _inputField(_nomeMateriaController, 'Nome da Matéria'),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    'Informe uma turma para o professor:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoMono'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: turmas.map((turma) {
                    return CheckboxListTile(
                      title: Text(turma),
                      value: selectedTurmas.contains(turma),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedTurmas.add(turma);
                          } else {
                            selectedTurmas.remove(turma);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: MyButton(
                  onTap: _cadastrarProfessorManual,
                  text: 'Cadastrar',
                  icon: Icons.person_add_alt_1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'ou',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'RobotoMono',
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: MyButton(
                  onTap: _importarCSV,
                  text: 'Importar via CSV',
                  icon: Icons.upload_file,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ),
    );
  }
}

