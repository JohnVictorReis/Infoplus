//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//                    Importações necessárias                  //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//                  Página de Exclusão de Alunos               //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class PaginaExclusaoAlunos extends StatefulWidget {
  const PaginaExclusaoAlunos({super.key});

  @override
  State<PaginaExclusaoAlunos> createState() => _PaginaExclusaoAlunosState();
}

class _PaginaExclusaoAlunosState extends State<PaginaExclusaoAlunos> {
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //               Variáveis de estado e controle local           //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  String? selectedTurma;
  List<String> turmas = [];
  List<Map<String, dynamic>> alunos = [];
  Map<String, bool> alunosSelecionados = {};

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //         Endpoint da Cloud Function de exclusão de usuários   //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  final String cloudFunctionUrl =
      'https://deletarusuario-m2qow4c2ja-uc.a.run.app';

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //       Inicialização: carregamento inicial das turmas        //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  void initState() {
    super.initState();
    _getTurmas();
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //           Busca as turmas disponíveis no Firestore          //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _getTurmas() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('turmas').get();
      setState(() {
        turmas = snapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      _erroSnack("Erro ao carregar turmas: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //     Carrega os alunos de uma turma específica do Firestore  //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _carregarAlunosDaTurma(String turma) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('turma', isEqualTo: turma)
          .get();

      setState(() {
        alunos = snapshot.docs
            .map((doc) => {'uid': doc.id, 'nome': doc['nome']})
            .toList();
        alunosSelecionados = {
          for (var aluno in alunos) aluno['uid']: false,
        };
      });
    } catch (e) {
      _erroSnack("Erro ao buscar alunos: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //   Chama a Cloud Function para remover o usuário do Auth     //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _excluirUsuarioPorHttp(String uid) async {
    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': uid}),
      );

      if (response.statusCode != 200) {
        throw Exception("Erro HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erro ao chamar função: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //           Exclui somente os alunos selecionados             //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _excluirSelecionados() async {
    final selecionados = alunosSelecionados.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selecionados.isEmpty) {
      _erroSnack("Selecione pelo menos um aluno.");
      return;
    }

    try {
      for (String uid in selecionados) {
        await _excluirUsuarioPorHttp(uid);
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      }

      _sucessoSnack("Alunos excluídos com sucesso.");
      _carregarAlunosDaTurma(selectedTurma!);
    } catch (e) {
      _erroSnack("Erro ao excluir usuários: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //           Exclui todos os alunos da turma atual             //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _excluirTodos() async {
    if (alunos.isEmpty) return;

    try {
      for (var aluno in alunos) {
        await _excluirUsuarioPorHttp(aluno['uid']);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(aluno['uid'])
            .delete();
      }

      _sucessoSnack("Todos os alunos da turma foram excluídos.");
      _carregarAlunosDaTurma(selectedTurma!);
    } catch (e) {
      _erroSnack("Erro ao excluir alunos da turma: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //                   Funções de exibição de SnackBars           //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  void _erroSnack(String msg) {
    Get.snackbar("Erro", msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white);
  }

  void _sucessoSnack(String msg) {
    Get.snackbar("Sucesso", msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //           Construção da interface da tela principal          //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text("Excluir Usuários",
            style: TextStyle(color: Colors.white)),
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
                const Icon(Icons.delete_forever, size: 40),
                const SizedBox(height: 10),
                const Text("Selecione a turma", style: TextStyle(fontSize: 24)),
                const SizedBox(height: 10),

                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                //                   Dropdown de seleção de turma               //
                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedTurma,
                        hint: const Text("Selecione uma turma"),
                        underline: const SizedBox(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTurma = newValue;
                          });
                          if (newValue != null) {
                            _carregarAlunosDaTurma(newValue);
                          }
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

                const SizedBox(height: 20),

                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                //             Lista de alunos com checkboxes                   //
                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                ...alunos.map((aluno) {
                  return CheckboxListTile(
                    title: Text(aluno['nome']),
                    value: alunosSelecionados[aluno['uid']] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        alunosSelecionados[aluno['uid']] = value ?? false;
                      });
                    },
                  );
                }).toList(),

                const SizedBox(height: 10),

                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                //                     Botões de ação                            //
                //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                MyButton(
                  text: "Excluir Selecionados",
                  icon: Icons.person_remove,
                  onTap: _excluirSelecionados,
                ),
                const SizedBox(height: 10),
                MyButton(
                  text: "Excluir Todos",
                  icon: Icons.delete_sweep,
                  onTap: _excluirTodos,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
