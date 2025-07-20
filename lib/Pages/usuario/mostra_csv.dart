// ignore_for_file: unused_local_variable, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';
import 'package:flutter/scheduler.dart'; // Importando o SchedulerBinding

class PaginaMostragemNotasAluno extends StatefulWidget {
  const PaginaMostragemNotasAluno({super.key});

  @override
  _PaginaMostragemNotasAlunoState createState() =>
      _PaginaMostragemNotasAlunoState();
}

class _PaginaMostragemNotasAlunoState extends State<PaginaMostragemNotasAluno> {
  String? selectedMateria;
  List<String> materias = []; // Lista de matérias da turma do aluno
  Stream<QuerySnapshot> _dadosStream = Stream.empty();
  String? turma; // Turma do aluno
  bool showError = false; // Flag para mostrar o erro (GIF)

  @override
  void initState() {
    super.initState();
    _getTurmaEMaterias(); // Buscar a turma e matérias do aluno
  }

  // Função para obter as matérias associadas à turma do aluno
  Future<void> _getTurmaEMaterias() async {
    try {
      final String alunoEmail = FirebaseAuth.instance.currentUser!.email!;

      // Obtém o documento do aluno na coleção 'users'
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        // Recupera a turma associada ao aluno (agora com o campo 'turma')
        turma = userDoc.data()!['turma'];

        setState(() {
          // A turma foi definida, agora busca as matérias dessa turma
        });

        // Recupera as matérias da turma
        QuerySnapshot materiasSnapshot = await FirebaseFirestore.instance
            .collection('turmas')
            .doc(turma) // Usa a turma recuperada do campo 'turma' do aluno
            .collection('materias')
            .get();

        for (var doc in materiasSnapshot.docs) {
          setState(() {
            materias.add(doc['nome']); // Adiciona as matérias à lista
          });
        }
      }
    } catch (e) {
      print("Erro ao recuperar dados do aluno: $e");
    }
  }

  // Função para carregar as notas com base na matéria selecionada
  Future<void> _loadNotas() async {
    try {
      if (selectedMateria == null || turma == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Selecione uma matéria.")));
        return;
      }

      setState(() {
        showError = false; // Reseta o erro
        _dadosStream = FirebaseFirestore.instance
            .collection('turmas')
            .doc(
                turma!) // A turma agora é dinâmica, vem do campo 'turma' do aluno
            .collection('materias')
            .doc(selectedMateria)
            .collection('notas')
            .where('email',
                isEqualTo: FirebaseAuth.instance.currentUser!
                    .email) // Filtra pelas notas do aluno logado
            .snapshots(); // Atribui o stream corretamente
      });
    } catch (e) {
      print("Erro ao carregar notas: $e");
    }
  }

  // Função para calcular a média das notas
  double _calcularMedia(List<QueryDocumentSnapshot> docs) {
    double soma = 0.0;
    int count = 0;

    for (var doc in docs) {
      var nota = doc['nota'] ?? 0.0; // Garantir que a nota seja um número
      soma += nota;
      count++;
    }

    return count > 0 ? soma / count : 0.0; // Evita divisão por zero
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visualizar Notas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  isExpanded:
                      true, // Faz o dropdown ocupar toda a largura disponível
                  style: TextStyle(color: Colors.black),
                  dropdownColor: Colors.grey[200], // Cor de fundo do dropdown
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

            // Botão para carregar as notas
            MyButton(
              onTap: () async {
                await _loadNotas();
              },
              text: 'BUSCAR NOTAS',
              icon: Icons.file_upload,
            ),
            SizedBox(height: 20),

            // Exibe os dados carregados do Firestore em uma DataTable com personalização de bordas e bordas arredondadas
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

                    // Se não houver dados, exibe o erro com o GIF
                    if (docs.isEmpty) {
                      // Usando Future.delayed para garantir que a imagem seja exibida após a construção
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black), // Borda para a tabela
                            borderRadius: BorderRadius.circular(
                                10), // Arredondamento nas bordas
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
                        // Exibe a média das notas
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
