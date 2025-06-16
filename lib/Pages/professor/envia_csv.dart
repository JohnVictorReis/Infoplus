// ignore_for_file: use_build_context_synchronously, unused_import, unused_local_variable, unused_element, library_private_types_in_public_api

/*import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PaginaCadastroCSV extends StatefulWidget {
  const PaginaCadastroCSV({super.key});

  @override
  State<PaginaCadastroCSV> createState() => _PaginaCadastroCSVState();
}

class _PaginaCadastroCSVState extends State<PaginaCadastroCSV> {
  List<List<dynamic>> csvData = [];

  // Função para carregar e processar o arquivo CSV
  Future<void> _pickAndLoadCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      final input = file.readAsStringSync();
      List<List<dynamic>> data = CsvToListConverter().convert(input);

      setState(() {
        csvData = data;
      });

      // Salvar os dados no Firestore
      await _uploadDataToFirestore(data);
    }
  }

  // Função para fazer upload dos dados no Firestore
  Future<void> _uploadDataToFirestore(List<List<dynamic>> data) async {
    try {
      CollectionReference dataCollection = FirebaseFirestore.instance.collection('atividades');

      for (var row in data) {
        // Estruturando os dados
        var turma = row[0];
        var aluno = row[1];
        var atividade = row[2];
        var nota = row[3];

        // Adicionando os dados no Firestore
        await dataCollection.add({
          'turma': turma,
          'aluno': aluno,
          'atividade': atividade,
          'nota': nota,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dados cadastrados com sucesso!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao cadastrar dados")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar CSV")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickAndLoadCsv,
              child: Text("Carregar CSV"),
            ),
            SizedBox(height: 20),
            // Exibir os dados carregados
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

/*import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PaginaCadastroCSV extends StatefulWidget {
  const PaginaCadastroCSV({super.key});

  @override
  State<PaginaCadastroCSV> createState() => _PaginaCadastroCSVState();
}

class _PaginaCadastroCSVState extends State<PaginaCadastroCSV> {
  List<List<dynamic>> csvData = [];

  // Função para carregar e processar o arquivo CSV
  Future<void> _pickAndLoadCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      final input = file.readAsStringSync();
      //Comentado para converter o CSV em uma lista e ajustar problema do ponto e virgula
      //List<List<dynamic>> data = CsvToListConverter().convert(input);
      List<List<dynamic>> data = CsvToListConverter(fieldDelimiter: ';').convert(input);

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-//
//Ignorar a primeira linha do CSV, não adicionando o titulo das colunas ao Firestore//
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-//
      setState(() {
        csvData = data.skip(1).toList();
      });

      // Salvar os dados no Firestore
      await _uploadDataToFirestore(data);
    }
  }

  // Função para fazer upload dos dados no Firestore
  Future<void> _uploadDataToFirestore(List<List<dynamic>> data) async {
    try {
      CollectionReference dataCollection = FirebaseFirestore.instance.collection('atividades');

      for (var row in data) {
        print("Linha CSV: $row");

        var turma = row[0];
        var aluno = row[1];
        var atividade = row[2];
        var nota = row[3];

        print("Enviando para Firestore: turma=$turma, aluno=$aluno, atividade=$atividade, nota=$nota");

        await dataCollection.add({
          'turma': turma,
          'aluno': aluno,
          'atividade': atividade,
          'nota': nota,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dados cadastrados com sucesso!")));
    } catch (e, stacktrace) {
      print("Erro ao cadastrar dados: $e");
      print(stacktrace);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao cadastrar dados: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar CSV")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickAndLoadCsv,
              child: Text("Carregar CSV"),
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
*/
/*
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:projeto_infoplus/Pages/Components/botoes.dart';
import 'package:projeto_infoplus/Pages/pagina_nota_professor.dart';
// ignore: unused_import
import 'package:projeto_infoplus/Services/auth_service.dart';

class PaginaCadastroCSV extends StatefulWidget {
  const PaginaCadastroCSV({super.key});

  @override
  State<PaginaCadastroCSV> createState() => _PaginaCadastroCSVState();
}

class _PaginaCadastroCSVState extends State<PaginaCadastroCSV> {
  List<List<dynamic>> csvData = [];

  // Função para carregar e processar o arquivo CSV
  Future<void> _pickAndLoadCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      final input = file.readAsStringSync();
      // Lê o arquivo CSV e usa ';' como delimitador de campo
      List<List<dynamic>> data = CsvToListConverter(fieldDelimiter: ';').convert(input);

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
      CollectionReference dataCollection = FirebaseFirestore.instance.collection('atividades');

      for (var row in data) {
        // Exibe a linha para debug
        print("Linha CSV: $row");

        // Garantir que os dados estão sendo extraídos corretamente
        var turma = row[0];
        var aluno = row[1];
        var atividade = row[2];
        var nota = row[3];

        // Exibe os dados que serão enviados para o Firestore
        print("Enviando para Firestore: turma=$turma, aluno=$aluno, atividade=$atividade, nota=$nota");

        // Envia os dados para o Firestore
        await dataCollection.add({
          'turma': turma,
          'aluno': aluno,
          'atividade': atividade,
          'nota': nota,
        });
      }
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-//
// Navega para a página de notas do professor após o upload do arquivo CSV//
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-//
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaginaNotaProfessor())
    );
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-//
// Exibe uma mensagem de sucesso//
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-//
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dados cadastrados com sucesso!")));
    } catch (e, stacktrace) {
      print("Erro ao cadastrar dados: $e");
      print(stacktrace);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao cadastrar dados: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Selecione um arquivo CSV")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
*/

/* aqui começa o comentário da ultima versão do código funcional
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:projeto_infoplus/Pages/Components/botoes.dart';
import 'package:projeto_infoplus/Pages/pagina_nota_professor.dart';
// ignore: duplicate_ignore
// ignore: unused_import
import 'package:projeto_infoplus/Services/auth_service.dart';

class PaginaCadastroCSV extends StatefulWidget {
  const PaginaCadastroCSV({super.key});

  @override
  State<PaginaCadastroCSV> createState() => _PaginaCadastroCSVState();
}

class _PaginaCadastroCSVState extends State<PaginaCadastroCSV> {
  List<List<dynamic>> csvData = [];

  // Função para carregar e processar o arquivo CSV
  Future<void> _pickAndLoadCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      final input = file.readAsStringSync();
      // Lê o arquivo CSV e usa ';' como delimitador de campo
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
      CollectionReference dataCollection =
          FirebaseFirestore.instance.collection('atividades');

      for (var row in data) {
        // Exibe a linha para debug
        print("Linha CSV: $row");

        // Garantir que os dados estão sendo extraídos corretamente
        var turma = row[0];
        var aluno = row[1];
        var atividade = row[2];
        var nota = row[3];

        // Exibe os dados que serão enviados para o Firestore
        print(
            "Enviando para Firestore: turma=$turma, aluno=$aluno, atividade=$atividade, nota=$nota");

        // Envia os dados para o Firestore
        await dataCollection.add({
          'turma': turma,
          'aluno': aluno,
          'atividade': atividade,
          'nota': nota,
        });
      }

      // Após o upload bem-sucedido, volta para a página anterior
      Navigator.pop(
          context); // Isso vai fechar a página atual e voltar para a anterior.

      // Exibe uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Dados cadastrados com sucesso!")));
    } catch (e, stacktrace) {
      print("Erro ao cadastrar dados: $e");
      print(stacktrace);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao cadastrar dados: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Selecione um arquivo CSV")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
*/ //aqui termina, fica esperto

/* //aqui começa o comentário da versão funcional estou testando a versão que funciona selecionar a turma e matéria
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
  // Variáveis para selecionar a turma e matéria
  String? selectedTurma;
  String? selectedMateria;

  // Lista de turmas associadas ao professor (será preenchido dinamicamente)
  List<String> turmas = [];

  // Lista de matérias disponíveis para cada turma
  List<String> materias = [];

  // Lista para armazenar os dados do CSV
  List<List<dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
    // Buscar as turmas associadas ao usuário logado ao iniciar
    _getTurmasProfessor();
  }

  // Função para obter as turmas associadas ao professor
  Future<void> _getTurmasProfessor() async {
    try {
      // Obtém o email do usuário logado
      final String professorEmail = FirebaseAuth.instance.currentUser!.email!;

      // Consulta o documento do professor na coleção 'users'
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
      if (selectedTurma == null || selectedMateria == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Selecione uma turma e uma matéria.")));
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

        // Envia os dados para a subcoleção de notas
        await notasCollection.add({
          'aluno': aluno,
          'atividade': atividade,
          'nota': nota,
          'data': Timestamp.now(), // Adicionando data atual
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notas cadastradas com sucesso!")));
      Navigator.pop(context); // Volta para a página anterior após sucesso
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao cadastrar notas: $e")));
    }
  }

  // Função para atualizar as matérias com base na turma
  void _updateMaterias(String? turma) {
    if (turma == "1info2") {
      materias = ["Matematica", "Ingles", "Calculo2"];
    } else if (turma == "1info3") {
      materias = ["Matematica", "Ingles", "Espanhol"];
    } else if (turma == "1info1") {
      materias = ["Matematica", "Ingles"];
    } else {
      materias = [];
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
            // Dropdown para selecionar a turma (somente as turmas associadas ao professor)
            DropdownButton<String>(
              value: selectedTurma,
              hint: Text("Selecione uma turma"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTurma = newValue;
                  // Atualiza as matérias disponíveis com base na turma selecionada
                  _updateMaterias(selectedTurma);
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

            // Dropdown para selecionar a matéria (baseado na turma)
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
            ElevatedButton(
              onPressed: _pickAndLoadCsv,
              child: Text("Buscar CSV"),
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
/*//aqui termina o comentário da versão funcional estou testando a versão que cria um email automaticamente

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
  // Variáveis para selecionar a turma e matéria
  String? selectedTurma;
  String? selectedMateria;

  // Lista de turmas associadas ao professor (será preenchido dinamicamente)
  List<String> turmas = [];

  // Lista de matérias disponíveis para cada turma
  List<String> materias = [];

  // Lista para armazenar os dados do CSV
  List<List<dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
    // Buscar as turmas associadas ao usuário logado ao iniciar
    _getTurmasProfessor();
  }

  // Função para obter as turmas associadas ao professor
  Future<void> _getTurmasProfessor() async {
    try {
      // Obtém o email do usuário logado
      final String professorEmail = FirebaseAuth.instance.currentUser!.email!;

      // Consulta o documento do professor na coleção 'users'
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
      if (selectedTurma == null || selectedMateria == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Selecione uma turma e uma matéria.")));
        return;
      }

      // Verificar se o documento da matéria existe na coleção antes de adicionar as notas
      DocumentSnapshot materiaDoc = await FirebaseFirestore.instance
          .collection('turmas')
          .doc(selectedTurma)
          .collection('materias')
          .doc(selectedMateria)
          .get();

      // Se o documento da matéria não existir, exibe um erro
      if (!materiaDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("A matéria selecionada não existe na turma.")));
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

        // Envia os dados para a subcoleção de notas
        await notasCollection.add({
          'aluno': aluno,
          'atividade': atividade,
          'nota': nota,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notas cadastradas com sucesso!")));
      Navigator.pop(context); // Volta para a página anterior após sucesso
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao cadastrar notas: $e")));
    }
  }

  // Função para atualizar as matérias com base na turma e professor logado
  Future<void> _updateMaterias(String turma) async {
    materias = []; // Limpar a lista de matérias
    try {
      // Recupera as matérias da turma selecionada com base no email do professor logado
      QuerySnapshot materiasSnapshot = await FirebaseFirestore.instance
          .collection('turmas')
          .doc(turma)
          .collection('materias')
          .where('email',
              isEqualTo: FirebaseAuth
                  .instance.currentUser!.email) // Use o campo 'email'
          .get();

      for (var doc in materiasSnapshot.docs) {
        setState(() {
          materias.add(doc['nome']); // Adiciona as matérias à lista
        });
      }
    } catch (e) {
      print("Erro ao recuperar matérias: $e");
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
            // Dropdown para selecionar a turma (somente as turmas associadas ao professor)
            DropdownButton<String>(
              value: selectedTurma,
              hint: Text("Selecione uma turma"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTurma = newValue;
                  // Atualiza as matérias disponíveis com base na turma selecionada
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

            // Dropdown para selecionar a matéria (baseado nas matérias do professor)
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
/*
            ElevatedButton(
              onPressed: _pickAndLoadCsv,
              child: Text("Buscar CSV"),
            ),
*/
            MyButton(
              onTap: () async {
                await _pickAndLoadCsv();
              },
              text: 'BUSCAR CSV',
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
//Aquipracimaéoquetafuncionando
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
  // Variáveis para selecionar a turma e matéria
  String? selectedTurma;
  String? selectedMateria;

  // Lista de turmas associadas ao professor (será preenchido dinamicamente)
  List<String> turmas = [];

  // Lista de matérias disponíveis para cada turma
  List<String> materias = [];

  // Lista para armazenar os dados do CSV
  List<List<dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
    // Buscar as turmas associadas ao usuário logado ao iniciar
    _getTurmasProfessor();
  }

  // Função para obter as turmas associadas ao professor
  Future<void> _getTurmasProfessor() async {
    try {
      // Obtém o email do usuário logado
      final String professorEmail = FirebaseAuth.instance.currentUser!.email!;

      // Consulta o documento do professor na coleção 'users'
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
      if (selectedTurma == null || selectedMateria == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Selecione uma turma e uma matéria.")));
        return;
      }

      // Verificar se o documento da matéria existe na coleção antes de adicionar as notas
      DocumentSnapshot materiaDoc = await FirebaseFirestore.instance
          .collection('turmas')
          .doc(selectedTurma)
          .collection('materias')
          .doc(selectedMateria)
          .get();

      // Se o documento da matéria não existir, exibe um erro
      if (!materiaDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("A matéria selecionada não existe na turma.")));
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

        // Gerar o e-mail para o aluno com base no nome e turma
        String nomeCompleto =
            aluno; // Considera que o nome do aluno é a primeira coluna
        String primeiroNome = nomeCompleto
            .split(' ')[0]
            .toLowerCase(); // Pega o primeiro nome e coloca em minúsculo
        String email =
            '$primeiroNome.$selectedTurma@mail.com'; // Gera o e-mail conforme o padrão

        // Envia os dados para a subcoleção de notas, incluindo o email gerado
        await notasCollection.add({
          'aluno': aluno,
          'atividade': atividade,
          'nota': nota,
          'email': email, // Adiciona o email gerado ao documento de nota
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notas cadastradas com sucesso!")));
      Navigator.pop(context); // Volta para a página anterior após sucesso
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao cadastrar notas: $e")));
    }
  }

  // Função para atualizar as matérias com base na turma e professor logado
  Future<void> _updateMaterias(String turma) async {
    materias = []; // Limpar a lista de matérias
    try {
      // Recupera as matérias da turma selecionada com base no email do professor logado
      QuerySnapshot materiasSnapshot = await FirebaseFirestore.instance
          .collection('turmas')
          .doc(turma)
          .collection('materias')
          .where('email',
              isEqualTo: FirebaseAuth
                  .instance.currentUser!.email) // Use o campo 'email'
          .get();

      for (var doc in materiasSnapshot.docs) {
        setState(() {
          materias.add(doc['nome']); // Adiciona as matérias à lista
        });
      }
    } catch (e) {
      print("Erro ao recuperar matérias: $e");
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
            // Dropdown para selecionar a turma (somente as turmas associadas ao professor)
            DropdownButton<String>(
              value: selectedTurma,
              hint: Text("Selecione uma turma"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTurma = newValue;
                  // Atualiza as matérias disponíveis com base na turma selecionada
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

            // Dropdown para selecionar a matéria (baseado nas matérias do professor)
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
/*
            ElevatedButton(
              onPressed: _pickAndLoadCsv,
              child: Text("Buscar CSV"),
            ),
*/
            MyButton(
              onTap: () async {
                await _pickAndLoadCsv();
              },
              text: 'BUSCAR CSV',
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
