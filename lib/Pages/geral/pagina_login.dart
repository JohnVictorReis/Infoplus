import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';
import 'package:projeto_infoplus/Services/auth_service.dart';
import 'package:projeto_infoplus/Pages/usuario/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/professor/pagina_inicial_professor.dart';

class PaginaLogin extends StatefulWidget {
  const PaginaLogin({super.key});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  // Controladores de texto para o email e a senha
  late final TextEditingController _emailControllerLogin;
  late final TextEditingController _passwordControllerLogin;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores de texto para capturar o email e a senha
    _emailControllerLogin = TextEditingController();
    _passwordControllerLogin = TextEditingController();
  }

  @override
  void dispose() {
    // Libera os controladores quando o widget for descartado
    _emailControllerLogin.dispose();
    _passwordControllerLogin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone e título da aplicação
              Icon(
                Icons.android,
                size: 40,
              ),
              Text(
                'INFO+',
                style: GoogleFonts.oswald(
                  fontSize: 54,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Bem Vindo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Acesse sua conta',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 25),

              // Campo de entrada para o e-mail
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
                      controller:
                          _emailControllerLogin, // Atribui o controlador
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Email'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Campo de entrada para a senha
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
                      controller:
                          _passwordControllerLogin, // Atribui o controlador
                      obscureText: true, // Oculta a senha
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Senha'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Botão de login que chama a função para autenticação
              MyButton(
                onTap: () async {
                  // Chama o método de login da AuthService passando email e senha
                  await AuthService().signin(
                    email: _emailControllerLogin.text,
                    password: _passwordControllerLogin.text,
                  );
                },
                text: 'LOGIN',
                icon: Icons.login, // Ícone do botão de login
              ),
              SizedBox(height: 25),

              // Se precisar de um link para cadastro de novos usuários, pode descomentar aqui
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Não possui uma conta?'),
                  Text(
                    ' Cadastre-se',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              )
              */
            ],
          ),
        ),
      ),
    );
  }
}
