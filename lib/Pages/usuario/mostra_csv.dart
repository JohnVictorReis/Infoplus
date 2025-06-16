// ignore_for_file: duplicate_import, unused_import, unused_local_variable

/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Pagina_Mostragem_Csv_Aluno extends StatefulWidget {
  const Pagina_Mostragem_Csv_Aluno({super.key});

  @override
  State<Pagina_Mostragem_Csv_Aluno> createState() => _Pagina_Mostragem_Csv_AlunoState();
}

class _Pagina_Mostragem_Csv_AlunoState extends State<Pagina_Mostragem_Csv_Aluno> {
  late Stream<QuerySnapshot> _dadosStream;

  @override
  void initState() {
    super.initState();
    // Obtenha os dados do Firestore
    _dadosStream = FirebaseFirestore.instance.collection('atividades').snapshots();
  }
  //Função para excluir os dados do Firestore
  /*Future<void> _deleteData(String documentId) async {
    // Excluir dados do Firestore
    await FirebaseFirestore.instance.collection('atividades').doc(documentId).delete();
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dados CSV')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dadosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os dados.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum dado encontrado.'));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              return ListTile(
                title: Text('Aluno: ${doc['aluno']}, Atividade: ${doc['atividade']}, Nota: ${doc['nota']}'),
                //chamado o icone de excluir
                //trailing: IconButton(
                  /*icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteData(doc.id);
                  },
                ),*/
              );
            },
          );
        },
      ),
    );
  }
}*/
/*//Pra baixo é o que ta funfando
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

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

      if (userDoc.exists) {
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
                border: Border.all(color: Colors.black.withOpacity(0.5)),
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

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Nenhuma nota encontrada.'));
                  }

                  var docs = snapshot.data!.docs;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.black), // Borda para a tabela
                      borderRadius: BorderRadius.circular(
                          10), // Arredondamento nas bordas
                    ),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.black),
                      headingTextStyle: TextStyle(color: Colors.white),
                      columns: const [
                        //DataColumn(label: Text('Aluno')),
                        DataColumn(label: Text('Atividade')),
                        DataColumn(label: Text('Nota')),
                      ],
                      rows: docs.map<DataRow>((doc) {
                        return DataRow(cells: [
                          //DataCell(Text(doc['aluno'])),
                          DataCell(Text(doc['atividade'])),
                          DataCell(Text(doc['nota'].toString())),
                        ]);
                      }).toList(),
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
}*/
//Pra cima é o que ta funfando
/*//abaixo comentado pra testar com o gif
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';

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
  List<double> notas = []; // Lista para armazenar as notas
  double media = 0.0; // Variável para armazenar a média das notas

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

      if (userDoc.exists) {
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
  void _calcularMedia(List<QueryDocumentSnapshot> docs) {
    notas.clear(); // Limpa a lista de notas antes de recarregar
    double soma = 0.0;

    // Adiciona as notas à lista e calcula a soma
    for (var doc in docs) {
      var nota = doc['nota'] ?? 0.0; // Garantir que a nota seja um número
      notas.add(nota);
      soma += nota;
    }

    // Calcula a média
    setState(() {
      media = soma / notas.length;
    });
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
                border: Border.all(color: Colors.black.withOpacity(0.5)),
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

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Nenhuma nota encontrada.'));
                  }

                  var docs = snapshot.data!.docs;

                  // Usando addPostFrameCallback para garantir que a média seja calculada após o build
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    _calcularMedia(docs);
                  });

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
                              MaterialStateProperty.all(Colors.black),
                          headingTextStyle: TextStyle(color: Colors.white),
                          columns: const [
                            //DataColumn(label: Text('Aluno')),
                            DataColumn(label: Text('Atividade')),
                            DataColumn(label: Text('Nota')),
                          ],
                          rows: docs.map<DataRow>((doc) {
                            return DataRow(cells: [
                              //DataCell(Text(doc['aluno'])),
                              DataCell(Text(doc['atividade'])),
                              DataCell(Text(doc['nota'].toString())),
                            ]);
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Exibe a média das notas
                      Text(
                        'Média: ${media.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
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

*/ //teste com o gif abaixo

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
                          'Média: ${_calcularMedia(docs).toStringAsFixed(2)}',
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


















/*port 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaginaMostragemCSV extends StatefulWidget {
  const PaginaMostragemCSV({super.key});

  @override
  State<PaginaMostragemCSV> createState() => _PaginaMostragemCSVState();
}

class _PaginaMostragemCSVState extends State<PaginaMostragemCSV> {
  late Stream<QuerySnapshot> _dadosStream;

  @override
  void initState() {
    super.initState();
    // Obtenha os dados do Firestore
    _dadosStream = FirebaseFirestore.instance.collection('atividades').snapshots();
  }

  // Função para excluir dados do Firestore
  Future<void> _deleteData(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('atividades').doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Documento excluído com sucesso!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao excluir o documento.")));
    }
  }

  // Função para confirmar a exclusão
  void _confirmDelete(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir este documento?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
                _deleteData(documentId); // Chama a função de exclusão
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dados CSV')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dadosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os dados.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum dado encontrado.'));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              return ListTile(
                title: Text('Aluno: ${doc['aluno']}, Atividade: ${doc['atividade']}, Nota: ${doc['nota']}'),
                // Adiciona o ícone de exclusão
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _confirmDelete(doc.id); // Chama a função de confirmação de exclusão
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}





*/