import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/usuario/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';

class PaginaAuth extends StatelessWidget {
  const PaginaAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Snapshot vai saber se o usuário está logado ou não.
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Adiciona um loading enquanto espera pelo estado
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            // Verifica se o usuário está logado
            return const PaginaInicial();
          } else {
            // Se o usuário não estiver logado, mostra a tela de login
            return const PaginaLogin();
          }
        },
      ),
    );
  }
}
