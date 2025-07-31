// ignore_for_file: unused_local_variable, avoid_print

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Importações necessárias                          //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';
import 'package:flutter/scheduler.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Tela de Visualização de Notas do Aluno           //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class PaginaMostragemNotasAluno extends StatefulWidget {
  const PaginaMostragemNotasAluno({super.key});

  @override
  _PaginaMostragemNotasAlunoState createState() =>
      _PaginaMostragemNotasAlunoState();
}

class _PaginaMostragemNotasAlunoState extends State<PaginaMostragemNotasAluno> {
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Variáveis de estado                              //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  String? selectedMateria;
  List<String> materias = [];
  Stream<QuerySnapshot> _dadosStream = Stream.empty();
  String? turma;
  bool showError = false;

  @override
  void initState() {
    super.initState();
    _getTurmaEMaterias(); // Buscar turma e matérias do aluno
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Recupera a turma e matérias da coleção do aluno  //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _getTurmaEMaterias() async {
    try {
      final String alunoEmail = FirebaseAuth.instance.currentUser!.email!;

      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        turma = userDoc.data()!['turma'];

        setState(() {});

        QuerySnapshot materiasSnapshot = await FirebaseFirestore.instance
            .collection('turmas')
            .doc(turma)
            .collection('materias')
            .get();

        for (var doc in materiasSnapshot.docs) {
          setState(() {
            materias.add(doc['nome']);
          });
        }
      }
    } catch (e) {
      print("Erro ao recuperar dados do aluno: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Carrega as notas da matéria selecionada          //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _loadNotas() async {
    try {
      if (selectedMateria == null || turma == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Selecione uma matéria.")));
        return;
      }

      setState(() {
        showError = false;
        _dadosStream = FirebaseFirestore.instance
            .collection('turmas')
            .doc(turma!)
            .collection('materias')
            .doc(selectedMateria)
            .collection('notas')
            .where('email',
                isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots();
      });
    } catch (e) {
      print("Erro ao carregar notas: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Calcula a média das notas                        //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  double _calcularMedia(List<QueryDocumentSnapshot> docs) {
    double soma = 0.0;
    int count = 0;

    for (var doc in docs) {
      var nota = doc['nota'] ?? 0.0;
      soma += nota;
      count++;
    }

    return count > 0 ? soma / count : 0.0;
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Interface da Tela                                //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visualizar Notas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
            // Dropdown para selecionar matéria                  //
            //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
                border: Border.all(color: Colors.black),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<String>(
                  value: selectedMateria,
                  hint: Text("Selecione uma matéria"),
                  icon: Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  style: TextStyle(color: Colors.black),
                  dropdownColor: Colors.grey[200],
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
              ),
            ),
            SizedBox(height: 20),

            //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
            // Botão para buscar as notas                        //
            //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
            MyButton(
              onTap: () async {
                await _loadNotas();
              },
              text: 'BUSCAR NOTAS',
              icon: Icons.file_upload,
            ),
            SizedBox(height: 20),

            //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
            // Área de exibição de notas ou erro                //
            //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

                  if (snapshot.hasData) {
                    var docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      Future.delayed(Duration.zero, () {
                        setState(() {
                          showError = true;
                        });
                      });
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/404notfound.png',
                                width: 300),
                            SizedBox(height: 20),
                            Text('Nenhuma nota encontrada para a matéria.',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                        // Tabela com notas                                //
                        //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(Colors.black),
                            headingTextStyle: TextStyle(color: Colors.white),
                            columns: const [
                              DataColumn(label: Text('Atividade')),
                              DataColumn(label: Text('Nota')),
                            ],
                            rows: docs.map<DataRow>((doc) {
                              return DataRow(cells: [
                                DataCell(Text(doc['atividade'])),
                                DataCell(Text(doc['nota'].toString())),
                              ]);
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 20),

                        //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                        // Exibição da média das notas                    //
                        //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
                        Text(
                          'Média atual: ${_calcularMedia(docs).toStringAsFixed(1)}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }

                  return Center(child: Text('Nenhuma nota encontrada.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
