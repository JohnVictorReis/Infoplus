// ignore_for_file: avoid_print

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Importações necessárias                          //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_infoplus/Pages/Components/caixa_texto.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Página de Perfil do Usuário                      //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class PaginaUsuario extends StatefulWidget {
  const PaginaUsuario({super.key});

  @override
  State<PaginaUsuario> createState() => _PaginaUsuarioState();
}

class _PaginaUsuarioState extends State<PaginaUsuario> {
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Variáveis para armazenar dados do usuário        //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Formata o CPF para exibição                      //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  String formatarCpf(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    } else {
      return 'CPF inválido';
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Busca os dados do usuário logado no Firestore    //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _getUsuarioInfo() async {
    try {
      if (userAtual != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userAtual!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            nomeUsuario = userDoc['nome'] ?? 'Nome não encontrado';
            turmaUsuario = userDoc['turma'] ?? 'Turma não encontrada';
            emailUsuario = userDoc['email'] ?? 'Email não encontrado';
            roleUsuario = userDoc['role'] ?? 'Role não encontrada';
            cpfUsuario = formatarCpf(userDoc['cpf'] ?? 'CPF não encontrado');
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Construção da interface da página                //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
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

          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
          // Ícone de perfil do usuário                         //
          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
          Center(
            child: Icon(
              Icons.person,
              size: 80,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 30),

          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
          // Exibição do nome do usuário                       //
          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              nomeUsuario.isNotEmpty ? nomeUsuario : 'Nome não encontrado',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
          // Exibição dos demais dados em CaixaTexto           //
          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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
              // Ação futura (editar perfil, por exemplo)
            },
          ),
        ],
      ),
    );
  }
}
