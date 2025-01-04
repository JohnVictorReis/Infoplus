// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_infoplus/Pages/Components/caixa_texto.dart';
/*
/*
class PaginaUsuario extends StatelessWidget {
  const PaginaUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pagina do Usuario'),
      ),
      body: Center (child:ElevatedButton(
        child: const Text('Teste para ir para login'),
        onPressed: (){
          Navigator.pushNamed(context, '/home/login' );
        },
      )),
    );
  }
}
*/

class PaginaUsuario extends StatefulWidget {
  const PaginaUsuario({super.key});

  @override
  State<PaginaUsuario> createState() => _PaginaUsuarioState();
}

class _PaginaUsuarioState extends State<PaginaUsuario> {
//Pegando o e-mail do usuário conectado
Text(
  userAtual?.email ?? 'Usuário não autenticado',
  textAlign: TextAlign.center,
  style: TextStyle(color: Colors.grey[700]),
),
//Editar o campo da informações do usuário
//Future<void> editaCampoInfo(String campo) async{}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
        color: Colors.white,),
        centerTitle: true,
        title: const Text('Pagina do Usuário', style:TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900], 
      ),

      body: ListView(
        children:  [
        const SizedBox(height: 25,),
          //Foto de usuário
        Icon(Icons.person, 
        size: 80,),

          //Email do usuário
        Text(userAtual.user?.email,
        textAlign: TextAlign.center,
        style: TextStyle(color:Colors.grey[700] )),

        const SizedBox(height: 15,),

          //Detalhes do usuário / BIO
        Padding(
          padding:const EdgeInsets.only(left: 25),
          child: Text(
            ' DADOS ',
            style: TextStyle(color: Colors.grey,),
            )
            ),

          CaixaTexto(
          nomeSessao: 'Usuario', 
          texto: 'John Victor',
          onPressed: () {}/*=> editaCampoInfo('Usuario')*/,
          ),

          //Bio


          CaixaTexto(
          nomeSessao: 'Bio Vazia', 
          texto: 'Bio ',
          onPressed: () {}/*=> editaCampoInfo('Bio')*/,
          ),

        ],
      ),
    );
  }
}


*/


class PaginaUsuario extends StatefulWidget {
  const PaginaUsuario({super.key});

  @override
  State<PaginaUsuario> createState() => _PaginaUsuarioState();
}

class _PaginaUsuarioState extends State<PaginaUsuario> {
  // Pegando o e-mail do usuário conectado
  User? userAtual = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: const Text(
          'Pagina do Usuário',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 25),
          // Foto de usuário
          Icon(
            Icons.person,
            size: 80,
          ),

          // Email do usuário
          Text(
            userAtual?.email ?? 'Usuário não autenticado',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),

          const SizedBox(height: 15),

          // Detalhes do usuário / BIO
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              ' DADOS ',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          CaixaTexto(
            nomeSessao: 'Usuario',
            texto: 'John Victor',
            onPressed: () {}, //=> editaCampoInfo('Usuario'),
          ),

          // Bio
          CaixaTexto(
            nomeSessao: 'Bio Vazia',
            texto: 'Bio ',
            onPressed: () {}, //=> editaCampoInfo('Bio'),
          ),
        ],
      ),
    );
  }
}