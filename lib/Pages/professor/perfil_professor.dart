// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_infoplus/Pages/Components/caixa_texto.dart';

class PerfilProfessor extends StatefulWidget {
  const PerfilProfessor({super.key});

  @override
  State<PerfilProfessor> createState() => _PerfilProfessorState();
}

class _PerfilProfessorState extends State<PerfilProfessor> {
  // Pegando o usuário atual
  User? userAtual = FirebaseAuth.instance.currentUser;
  String nomeProfessor = '';
  String emailProfessor = '';
  String materiaProfessor = '';
  String roleProfessor = '';
  String codigoProfessor = '';
  List<String> turmasProfessor = [];

  @override
  void initState() {
    super.initState();
    _getProfessorInfo(); // Carrega as informações do professor logado
  }

  // Função para pegar as informações do professor logado
  Future<void> _getProfessorInfo() async {
    try {
      if (userAtual != null) {
        // Obtendo dados do Firestore com base no UID do usuário
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userAtual!.uid)
            .get();

        // Se o documento do usuário existir, atualiza os dados na tela
        if (userDoc.exists) {
          setState(() {
            nomeProfessor = userDoc['nome'] ?? 'Nome não encontrado';
            emailProfessor = userDoc['email'] ?? 'Email não encontrado';
            materiaProfessor = userDoc['materia'] ?? 'Matéria não encontrada';
            roleProfessor = userDoc['role'] ?? 'Role não encontrada';
            codigoProfessor =
                userDoc['codigoProfessor'] ?? 'Código não encontrado';

            // Garantir que o campo 'turmas' seja uma lista
            var turmasData = userDoc['turmas'];
            turmasProfessor = (turmasData is List)
                ? List<String>.from(turmasData)
                : [
                    turmasData ?? 'Sem turmas'
                  ]; // Caso seja uma string, converte para lista
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do professor: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: const Text(
          'Perfil do Professor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const SizedBox(height: 25),
          // Ícone de foto de usuário
          Center(
            child: Icon(
              Icons.person,
              size: 80,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(
              height:
                  30), // Adicionado espaçamento maior entre o ícone e as informações

          // Exibindo o nome do professor
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              nomeProfessor.isNotEmpty ? nomeProfessor : 'Nome não encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
/*
          // Exibindo o email do professor
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              emailProfessor.isNotEmpty
                  ? emailProfessor
                  : 'Email não encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),

          // Exibindo a matéria que o professor leciona
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Matéria: $materiaProfessor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Exibindo o código do professor
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              'Código: $codigoProfessor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Detalhes do professor / Exibição das turmas
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              'Turmas que leciona:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Exibindo as turmas que o professor leciona
          for (var turma in turmasProfessor)
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                turma,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
*/

          // CaixaTexto com as informações do professor como lista
          CaixaTexto(
            nomeSessao: 'Dados do Professor',
            texto: '''
Nome: $nomeProfessor
Matéria: $materiaProfessor
E-mail: $emailProfessor
Role: $roleProfessor
Código: $codigoProfessor
Turmas: ${turmasProfessor.join(', ')}
            ''',
            onPressed: () {
              // Ação ao pressionar a caixa de texto (se necessário)
            },
          ),
        ],
      ),
    );
  }
}
