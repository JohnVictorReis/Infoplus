//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Importações necessárias                          //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Controladores de texto para inputs manuais       //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
final TextEditingController _nomeController = TextEditingController();
final TextEditingController _cpfController = TextEditingController();

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Página de cadastro de aluno                      //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class PaginaCadastroAluno extends StatefulWidget {
  const PaginaCadastroAluno({super.key});

  @override
  State<PaginaCadastroAluno> createState() => _PaginaCadastroAlunoState();
}

class _PaginaCadastroAlunoState extends State<PaginaCadastroAluno> {
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Variáveis para controle de estado                //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  String? selectedTurma;
  List<String> turmas = [];

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Inicialização: carrega turmas disponíveis        //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  void initState() {
    super.initState();
    _getTurmas();
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Recupera as turmas do Firestore                  //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Gera email do aluno com base no nome, turma e CPF //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  String _gerarEmail(String nome, String cpf) {
    String primeiroNome = nome.split(' ')[0].toLowerCase();
    String ultimosNumeros = cpf.substring(cpf.length - 4);
    return "$primeiroNome.$selectedTurma$ultimosNumeros@mail.com";
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Formata CPF para conter 11 dígitos               //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  String formatarCpf(String cpf) {
    String limpo = cpf.replaceAll(RegExp(r'\D'), '');
    return limpo.padLeft(11, '0');
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Cadastra aluno de forma manual                   //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Importa alunos por meio de arquivo CSV           //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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
      final bytes = await file.readAsBytes();

      late String input;
      try {
        input = const Utf8Decoder().convert(bytes);
      } catch (_) {
        input = const Latin1Decoder().convert(bytes);
      }

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
      List<String> emailsDuplicados = [];

      //=-=-=-=-=-=-= Loop para cadastrar cada linha do CSV =-=-=-=-=-=-=//
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
        } on FirebaseAuthException catch (e) {
          erros++;
          if (e.code == 'email-already-in-use') {
            emailsDuplicados.add(email);
          } else {
            Get.snackbar(
              "Erro ao cadastrar $nome",
              "Email: $email\nErro: ${e.message}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              duration: const Duration(seconds: 6),
            );
          }
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

      //=-=-=-=-=-=-= Exibe aviso de emails duplicados =-=-=-=-=-=-=//
      if (emailsDuplicados.isNotEmpty) {
        Get.snackbar(
          "E-mails já cadastrados",
          "Os seguintes e-mails já estão em uso:\n\n${emailsDuplicados.join('\n')}\n\nValide o arquivo CSV e tente novamente.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 8),
        );
      }

      //=-=-=-=-=-=-= Feedback final da importação =-=-=-=-=-=-=//
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

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Interface da página                              //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                // Dropdown para seleção de turma                   //
                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                // Campo de entrada do nome do aluno                //
                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: _buildTextField(_nomeController, 'Nome do Aluno'),
                ),

                const SizedBox(height: 10),

                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                // Campo de entrada do CPF do aluno                 //
                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: _buildTextField(_cpfController, 'CPF do Aluno'),
                ),

                const SizedBox(height: 20),

                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                // Botão para cadastro manual                       //
                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                // Botão para importar CSV                         //
                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Widget reutilizável para campo de texto           //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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
