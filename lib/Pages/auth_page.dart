import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';

class PaginaAuth extends StatelessWidget {
  const PaginaAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){

          //Snapshot vai saber se o usuário está logado ou não.
          if(snapshot.hasData){
            return const PaginaInicial();
          }

          else{
            return const PaginaLogin();
          }
        },
        ),
    );
  }
}