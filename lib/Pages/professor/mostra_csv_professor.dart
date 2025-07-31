// ignore_for_file: avoid_print, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

class PaginaMostragemCSV extends StatefulWidget {
  const PaginaMostragemCSV({super.key});

  @override
  State<PaginaMostragemCSV> createState() => _PaginaMostragemCSVState();
}

class _PaginaMostragemCSVState extends State<PaginaMostragemCSV> {
  String? selectedTurma;
  String? selectedMateria;
  List<String> turmas = [];
  List<String> materias = [];
  Stream<QuerySnapshot> _dadosStream = Stream.empty();

  @override
  void initState() {
    super.initState();
    _getTurmasProfessor(); // Buscar as turmas do professor
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Função para obter as turmas associadas ao professor          //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Atualiza as matérias com base na turma selecionada            //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _updateMaterias(String turma) async {
    materias = []; // Limpar a lista de matérias
    try {
      QuerySnapshot materiasSnapshot = await FirebaseFirestore.instance
          .collection('turmas')
          .doc(turma)
          .collection('materias')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      for (var doc in materiasSnapshot.docs) {
        setState(() {
          materias.add(doc['nome']);
        });
      }
    } catch (e) {
      print("Erro ao recuperar matérias: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Carrega notas com base na turma e matéria selecionadas        //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _loadNotas() async {
    try {
      if (selectedTurma == null || selectedMateria == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Selecione uma turma e uma matéria.")));
        return;
      }

      setState(() {
        _dadosStream = FirebaseFirestore.instance
            .collection('turmas')
            .doc(selectedTurma)
            .collection('materias')
            .doc(selectedMateria)
            .collection('notas')
            .orderBy('aluno')
            .snapshots();
      });
    } catch (e) {
      print("Erro ao carregar notas: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Função para excluir uma nota                                //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _deleteData(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('turmas')
          .doc(selectedTurma)
          .collection('materias')
          .doc(selectedMateria)
          .collection('notas')
          .doc(documentId)
          .delete();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Nota excluída com sucesso!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao excluir a nota.")));
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Diálogo de confirmação de exclusão                          //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  void _confirmDelete(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir esta nota?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteData(documentId);
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Interface principal                                         //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visualizar Notas')),
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
                  selectedMateria = null; // Resetar ao mudar turma
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
                await _loadNotas();
              },
              text: 'BUSCAR NOTAS',
              icon: Icons.file_upload,
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _dadosStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar os dados.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Nenhuma nota encontrada.'));
                  }

                  var docs = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.black),
                        headingTextStyle: TextStyle(color: Colors.white),
                        columns: const [
                          DataColumn(label: Text('Aluno')),
                          DataColumn(label: Text('Atividade')),
                          DataColumn(label: Text('Nota')),
                          DataColumn(label: Text('Ação')),
                        ],
                        rows: docs.map<DataRow>((doc) {
                          return DataRow(cells: [
                            DataCell(Text(doc['aluno'] ?? '')),
                            DataCell(Text(doc['atividade'] ?? '')),
                            DataCell(Text(doc['nota']?.toString() ?? 'N/A')),
                            DataCell(IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _confirmDelete(doc.id);
                              },
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
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
