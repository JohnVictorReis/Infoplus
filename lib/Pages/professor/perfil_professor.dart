// ignore_for_file: avoid_print

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Importações necessárias                          //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_infoplus/Pages/Components/caixa_texto.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Tela de Perfil do Professor                      //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class PerfilProfessor extends StatefulWidget {
  const PerfilProfessor({super.key});

  @override
  State<PerfilProfessor> createState() => _PerfilProfessorState();
}

class _PerfilProfessorState extends State<PerfilProfessor> {
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Variáveis de estado                             //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Recupera as informações do professor logado      //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _getProfessorInfo() async {
    try {
      if (userAtual != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userAtual!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            nomeProfessor = userDoc['nome'] ?? 'Nome não encontrado';
            emailProfessor = userDoc['email'] ?? 'Email não encontrado';
            materiaProfessor = userDoc['materia'] ?? 'Matéria não encontrada';
            roleProfessor = userDoc['role'] ?? 'Role não encontrada';
            codigoProfessor =
                userDoc['codigoProfessor'] ?? 'Código não encontrado';

            var turmasData = userDoc['turmas'];
            turmasProfessor = (turmasData is List)
                ? List<String>.from(turmasData)
                : [turmasData ?? 'Sem turmas'];
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do professor: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Interface da tela                                //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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

          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
          // Ícone do professor                               //
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
          // Nome do professor                                //
          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              nomeProfessor.isNotEmpty ? nomeProfessor : 'Nome não encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
          // Caixa com os dados do professor                  //
          //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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
              // Ação ao clicar (se necessário)
            },
          ),
        ],
      ),
    );
  }
}
