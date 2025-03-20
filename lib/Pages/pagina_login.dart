// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, avoid_print, unused_element


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';
import 'package:projeto_infoplus/Services/auth_service.dart';

//Controladores para variáveis de Login
final TextEditingController _emailControllerLogin = TextEditingController();
final TextEditingController _passwordControllerLogin = TextEditingController();

class PaginaLogin extends StatefulWidget {
  const PaginaLogin({super.key});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {

  //Criando os controladores para acesso com firebase
  final db = FirebaseFirestore.instance;
  
  //final _emailController = TextEditingController();
  //final _passwordController = TextEditingController();

 // Future SignIn() async{
  //  await FirebaseAuth.signin,
 // },

/* Tirando o dispose do indiano 
@override
  void dispose(){
  super.dispose();
  _emailController.dispose();
  _passwordController.dispose();
}
*/
  @override
  Widget build(BuildContext context) {

//Inicialização do firebaseStorage, Rotina comentada em 23/09/24 até próximo uso.
//final db = FirebaseFirestore.instance;

    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.android,
              size: 40,),
              Text(
                '  INFO+  ', 
                style: GoogleFonts.oswald(
                  fontSize: 54,
                ), 
              ),
              SizedBox(
                height: 20  ,
              ),
              Text(
                'Bem Vindo',  
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Acesse sua conta',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 25,
              ),
//Campo do e-mail
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _emailControllerLogin,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Email')),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
//Campo da senha
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  //onTap: //signIn,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _passwordControllerLogin,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: 'Senha')),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),
//Botão de Login

              MyButton(onTap: ()async{
                await AuthService().signin(
                    email: _emailControllerLogin.text,
                    password: _passwordControllerLogin.text,
                    context: context
                );
              }, 
              text: 'LOGIN',
              ),

//SizedBox
              SizedBox(
                height: 25,
              ),
//Não possui conta, cadastre-se
/*
          Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Text('Não possui uma conta?',),
              Text(' Cadastre-se', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)) 
            ],
          )
*/
            ],
          )),
        ));
  }
  
}
