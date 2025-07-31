//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Importações necessárias                          //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:projeto_infoplus/Pages/admin/pagina_cadastro_materia.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_cadastro_professor.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_reset_login.dart';
import 'package:projeto_infoplus/Pages/professor/envia_csv.dart';
import 'package:projeto_infoplus/Pages/professor/mostra_csv_professor.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_cadastro_aluno.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';
import 'package:projeto_infoplus/Services/auth_service.dart';
import 'package:projeto_infoplus/Pages/geral/auth_page.dart';
import 'package:projeto_infoplus/Pages/usuario/mostra_csv.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Página principal do administrador (Stateful)     //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class PaginaAdm extends StatefulWidget {
  const PaginaAdm({super.key});

  @override
  State<PaginaAdm> createState() => _PaginaAdmState();
}

class _PaginaAdmState extends State<PaginaAdm> {
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Índice da aba atual no BottomNavigationBar       //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  int _currentIndex = 1;

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Aba inferior (ainda não utilizada neste exemplo) //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  final tabs = [
    Center(child: Text('Sair')),
    Center(child: Text('Home')),
    Center(child: Text('Perfil')),
  ];

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Função de logout usando FirebaseAuth             //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  void signOutUser() {
    FirebaseAuth.instance.signOut();
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Construção da interface da página                //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      // AppBar com botão de logout
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          'INFO+',
          style: GoogleFonts.roboto(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              signOutUser();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaginaLogin()),
              );
            },
            icon: Icon(Icons.logout_rounded),
            color: Colors.white,
          ),
        ],
      ),

      //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
      // Corpo principal da página                         //
      //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título da tela
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Selecione a opção desejada',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Lista de botões do menu
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 16),

                    // Linha com botões de cadastro de aluno e professor
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaCadastroAluno(),
                              ),
                            );
                          },
                          icon: 'assets/images/aluno.png',
                          title: 'ALUNOS',
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaCadastroProfessor(),
                              ),
                            );
                          },
                          icon: 'assets/images/professor.png',
                          title: 'PROFESSORES',
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Linha com botões de reset de senha e matérias
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaResetSenhas(),
                              ),
                            );
                          },
                          icon: 'assets/images/senha.png',
                          title: 'RESET SENHAS',
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaCadastroMateria(),
                              ),
                            );
                          },
                          icon: 'assets/images/materias.png',
                          title: 'MATERIAS',
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
      // Barra de navegação inferior (BottomNavigationBar) //
      //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuração',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Perfil',
          ),
        ],
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });

          // Redirecionamento de acordo com o item clicado
          if (_currentIndex == 2) {
            Navigator.pushNamed(context, '/home/user');
          } else if (_currentIndex == 0) {
            // Pode adicionar ações específicas para Configuração aqui
          }
        },
      ),
    );
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Widget reutilizável para montar os botões do menu //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Widget _cardMenu({
    required String title,
    required String icon,
    VoidCallback? onTap,
    Color color = Colors.white,
    Color fontColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        width: 156,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Image.asset(icon),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: fontColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
