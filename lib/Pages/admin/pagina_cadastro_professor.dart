// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_infoplus/Services/auth_service.dart';

//Controladores para variáveis de Cadastro
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

class PaginaCadastroProfessor extends StatefulWidget {
  const PaginaCadastroProfessor({super.key});

  @override
  State<PaginaCadastroProfessor> createState() => _PaginaCadastroState();
}

class _PaginaCadastroState extends State<PaginaCadastroProfessor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.android,
                size: 40,
              ),
              Text(
                'INFOPLUS+',
                style: GoogleFonts.bebasNeue(
                  fontSize: 54,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Cadastre-se agora',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Faça parte dessa comunidade',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 30,
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
                        controller: _emailController,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Email')),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
//Campo confirmação da senha
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
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Senha')),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
/*
              //Campo da senha
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
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Repita sua Senha')),
                  ),
                ),
             ),
*/
              SizedBox(
                height: 10,
              ),
//Botão Cadastro
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ElevatedButton(
                    onPressed:
                        () {} /*async{
                      //Comentado devido a regra de negócio
                      
                     await AuthService().signup(
                        emailsignup: _emailController.text, 
                        passwordsignup: _passwordController.text);

                    },*/
                    ,
                    child: Text(
                      'Cadastrar',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    )),
              ),
              SizedBox(
                height: 25,
              ),
//Não possui conta, cadastre-se
/*
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não possui uma conta?',
                  ),
                  Text(' Cadastre-se',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold))
                ],
              )
              */
            ],
          )),
        ));
  }
}
