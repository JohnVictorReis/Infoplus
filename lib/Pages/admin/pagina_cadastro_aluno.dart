// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

final TextEditingController _nomeController = TextEditingController();
final TextEditingController _cpfController = TextEditingController();

class PaginaCadastroAluno extends StatefulWidget {
  const PaginaCadastroAluno({super.key});

  @override
  State<PaginaCadastroAluno> createState() => _PaginaCadastroAlunoState();
}

class _PaginaCadastroAlunoState extends State<PaginaCadastroAluno> {
  String? selectedTurma;
  List<String> turmas = [];

  @override
  void initState() {
    super.initState();
    _getTurmas();
  }

  Future<void> _getTurmas() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('turmas').get();
      List<String> listaTurmas = snapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        turmas = listaTurmas;
      });
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Erro ao carregar turmas: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  String _gerarEmail(String nome, String cpf) {
    String primeiroNome = nome.split(' ')[0].toLowerCase();
    String ultimosNumeros = cpf.substring(cpf.length - 4);
    return "$primeiroNome.$selectedTurma$ultimosNumeros@mail.com";
  }

  /// FUNÇÃO PARA FORMATAR O CPF COM 11 DÍGITOS
  String formatarCpf(String cpf) {
    String limpo = cpf.replaceAll(RegExp(r'\D'), '');
    return limpo.padLeft(11, '0');
  }

  Future<void> _cadastrarAlunoManual() async {
    try {
      String nome = _nomeController.text.trim();
      String cpf = formatarCpf(_cpfController.text.trim());
      String email = _gerarEmail(nome, cpf);
      String senha = 'estudante';

      if (selectedTurma == null) {
        Get.snackbar(
          "Erro",
          "Selecione uma turma antes de cadastrar.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'nome': nome,
        'cpf': cpf,
        'turma': selectedTurma,
        'role': 'usuario',
        'email': email,
        'primeiro_login': true,
      });

      _nomeController.clear();
      _cpfController.clear();

      Get.snackbar(
        "Sucesso",
        "Aluno cadastrado com sucesso!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Falha ao cadastrar aluno: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _importarCSV() async {
    try {
      if (selectedTurma == null) {
        Get.snackbar(
          "Erro",
          "Selecione uma turma antes de importar o CSV.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) throw Exception("Nenhum arquivo selecionado.");

      final file = File(result.files.single.path!);
      final input = await file.readAsString();

      final linhas = LineSplitter.split(input).toList();
      if (linhas.isEmpty) throw Exception("CSV vazio.");

      final rawCabecalhos = linhas.first.split(RegExp('[,;]'));
      final cabecalhos =
          rawCabecalhos.map((c) => c.trim().toLowerCase()).toList();

      final nomeIndex = cabecalhos.indexOf("nomealuno");
      final cpfIndex = cabecalhos.indexOf("cpf");

      if (nomeIndex == -1 || cpfIndex == -1) {
        throw Exception(
          "Cabeçalhos inválidos. Esperados: 'nomealuno' e 'cpf', encontrados: ${cabecalhos.join(', ')}",
        );
      }

      int sucesso = 0;
      int erros = 0;

      for (int i = 1; i < linhas.length; i++) {
        final campos = linhas[i].split(RegExp('[,;]'));

        if (campos.length <= cpfIndex || campos.length <= nomeIndex) {
          print("Linha inválida: $campos");
          erros++;
          continue;
        }

        final nome = campos[nomeIndex].trim();
        final cpf = formatarCpf(campos[cpfIndex].trim());
        final email = _gerarEmail(nome, cpf);
        final senha = 'estudante';

        try {
          UserCredential cred = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: senha);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(cred.user!.uid)
              .set({
            'nome': nome,
            'cpf': cpf,
            'turma': selectedTurma,
            'role': 'usuario',
            'email': email,
            'primeiro_login': true,
          });

          sucesso++;
        } catch (e) {
          erros++;
          print("Erro no cadastro de $email: $e");
          Get.snackbar(
            "Erro ao cadastrar $nome",
            "Email: $email\nErro: $e",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 6),
          );
        }
      }

      Get.snackbar(
        "Importação finalizada",
        "$sucesso aluno(s) importado(s) com sucesso. $erros falha(s).",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: sucesso > 0 ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Erro ao importar CSV: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Cadastro de Aluno',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.school_rounded, size: 40),
                const SizedBox(height: 10),
                const Text(
                  'Informações do aluno',
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 20),

                // Campo TURMA primeiro
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: DropdownButton<String>(
                        value: selectedTurma,
                        hint: const Text("Selecione uma turma"),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTurma = newValue;
                          });
                        },
                        items: turmas.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Campo Nome
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: _buildTextField(_nomeController, 'Nome do Aluno'),
                ),
                const SizedBox(height: 10),

                // Campo CPF
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: _buildTextField(_cpfController, 'CPF do Aluno'),
                ),
                const SizedBox(height: 20),

                MyButton(
                  onTap: _cadastrarAlunoManual,
                  text: 'Cadastrar Manual',
                  icon: Icons.person_add,
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
                MyButton(
                  onTap: _importarCSV,
                  text: 'Importar CSV',
                  icon: Icons.upload_file,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: TextField(
          controller: controller,
          decoration:
              InputDecoration(border: InputBorder.none, hintText: hintText),
        ),
      ),
    );
  }
}

//por algum motivo essa bomba de baixo ai funciona a seleção de arquivos no google drive, estou mesclando a versão acima, com a logica da versão abaixo
/*import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

class PaginaCadastroAluno extends StatefulWidget {
  const PaginaCadastroAluno({super.key});

  @override
  State<PaginaCadastroAluno> createState() => _PaginaCadastroAlunoState();
}

class _PaginaCadastroAlunoState extends State<PaginaCadastroAluno> {
  // Variáveis para selecionar a turma
  String? selectedTurma;

  // Lista de turmas associadas ao professor
  List<String> turmas = [];

  // Lista para armazenar os dados do CSV
  List<List<dynamic>> csvData = [];

  // Controladores dos campos de entrada para cadastro manual
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Buscar as turmas associadas ao usuário logado ao iniciar
    _getTurmasProfessor();
  }

  // Função para obter as turmas associadas ao professor
  Future<void> _getTurmasProfessor() async {
    try {
      final String professorEmail = FirebaseAuth.instance.currentUser!.email!;

      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        List<dynamic> turmasList = userDoc.data()!['turmas'] ?? [];
        setState(() {
          turmas = turmasList.cast<String>(); // Preenche as turmas
        });
      }
    } catch (e) {
      print("Erro ao recuperar turmas: $e");
    }
  }

  // Função para gerar o e-mail do aluno baseado no nome, turma e CPF
  String _gerarEmail(String nome, String turma, String cpf) {
    String primeiroNome = nome.split(' ')[0].toLowerCase();
    String cpfUltimos4 = cpf.length >= 4 ? cpf.substring(cpf.length - 4) : cpf;
    return '$primeiroNome.$turma$cpfUltimos4@mail.com'; // Gera o e-mail conforme o formato
  }

  // Função para carregar e processar o arquivo CSV
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

  // Função para fazer upload dos dados no Firestore
  Future<void> _uploadDataToFirestore(List<List<dynamic>> data) async {
    try {
      if (selectedTurma == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Selecione uma turma.")));
        return;
      }

      // Referência da coleção de alunos
      CollectionReference alunosCollection =
          FirebaseFirestore.instance.collection('users');

      for (var row in data) {
        var nomeAluno = row[0];
        var cpfAluno = row[1];

        // Gerar o e-mail para o aluno
        String email = _gerarEmail(nomeAluno, selectedTurma!, cpfAluno);

        // Verificar se o aluno já existe na coleção users
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userSnapshot.docs.isEmpty) {
          // Se o aluno não existir, criar um novo usuário
          String password = 'aluno123'; // Senha temporária
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);

          // Salvar o aluno na coleção users
          await alunosCollection.doc(userCredential.user!.uid).set({
            'nome': nomeAluno,
            'cpf': cpfAluno,
            'email': email,
            'role': 'aluno',
            'turmas': [selectedTurma], // Adiciona a turma ao aluno
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Aluno $nomeAluno cadastrado com sucesso!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao cadastrar aluno: $e")));
    }
  }

  // Função para cadastrar aluno manualmente
  Future<void> _cadastrarAlunoManual() async {
    try {
      String nomeAluno = _nomeController.text;
      String cpfAluno = _cpfController.text;

      // Gerar o e-mail para o aluno
      String email = _gerarEmail(nomeAluno, selectedTurma!, cpfAluno);

      // Verificar se o aluno já existe na coleção users
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        // Se o aluno não existir, criar um novo usuário
        String password = 'aluno123'; // Senha temporária
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Salvar o aluno na coleção users
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'nome': nomeAluno,
          'cpf': cpfAluno,
          'email': email,
          'role': 'aluno',
          'turmas': [selectedTurma], // Adiciona a turma ao aluno
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Aluno $nomeAluno cadastrado com sucesso!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao cadastrar aluno: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar Alunos")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown para selecionar a turma
            DropdownButton<String>(
              value: selectedTurma,
              hint: Text("Selecione uma turma"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTurma = newValue;
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

            // Campos para cadastro manual do aluno
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: "Nome do Aluno"),
            ),
            TextField(
              controller: _cpfController,
              decoration: InputDecoration(labelText: "CPF do Aluno"),
            ),
            SizedBox(height: 20),

            // Botão para cadastrar aluno manualmente
            ElevatedButton(
              onPressed: _cadastrarAlunoManual,
              child: Text("Cadastrar Aluno Manualmente"),
            ),
            SizedBox(height: 20),

            // Botão para carregar o arquivo CSV
            MyButton(
              onTap: _pickAndLoadCsv,
              text: 'Buscar CSV',
              icon: Icons.file_upload,
            ),
            SizedBox(height: 20),

            // Exibe os dados carregados do CSV
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
*/
