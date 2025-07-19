// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_infoplus/Pages/Components/caixa_texto.dart';

class PaginaUsuario extends StatefulWidget {
  const PaginaUsuario({super.key});

  @override
  State<PaginaUsuario> createState() => _PaginaUsuarioState();
}

class _PaginaUsuarioState extends State<PaginaUsuario> {
  // Pegando o usuário atual
  User? userAtual = FirebaseAuth.instance.currentUser;
  String nomeUsuario = '';
  String turmaUsuario = '';
  String emailUsuario = '';
  String roleUsuario = '';
  String cpfUsuario = '';

  @override
  void initState() {
    super.initState();
    _getUsuarioInfo(); // Carrega as informações do usuário logado
  }

  // Função para formatar o CPF para o formato correto
  String formatarCpf(String cpf) {
    // Remover qualquer caractere não numérico
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    // Verifica se o CPF possui 11 dígitos
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    } else {
      return 'CPF inválido'; // Caso o CPF não tenha o tamanho correto
    }
  }

  // Função para pegar as informações do usuário logado
  Future<void> _getUsuarioInfo() async {
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
            nomeUsuario = userDoc['nome'] ?? 'Nome não encontrado';
            turmaUsuario = userDoc['turma'] ?? 'Turma não encontrada';
            emailUsuario = userDoc['email'] ?? 'Email não encontrado';
            roleUsuario = userDoc['role'] ?? 'Role não encontrada';
            cpfUsuario = formatarCpf(
                userDoc['cpf'] ?? 'CPF não encontrado'); // Formatar o CPF
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
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
          'Perfil do Usuário',
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

          // Exibindo o nome do usuário
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              nomeUsuario.isNotEmpty ? nomeUsuario : 'Nome não encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
/*
          // Exibindo o email do usuário
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              emailUsuario.isNotEmpty ? emailUsuario : 'Email não encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),

          // Exibindo a turma do usuário
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              'Turma: $turmaUsuario',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Detalhes do usuário / Exibição de todos os dados
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              'Dados do Usuário',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
*/
          // CaixaTexto com as informações do usuário como lista
          CaixaTexto(
            nomeSessao: 'Dados do Usuário',
            texto: '''
Nome: $nomeUsuario
Turma: $turmaUsuario
E-mail: $emailUsuario
Role: $roleUsuario
CPF: $cpfUsuario
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
