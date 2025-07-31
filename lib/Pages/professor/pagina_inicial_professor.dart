// ignore_for_file: avoid_print, deprecated_member_use

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Importações necessárias                          //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_infoplus/Pages/professor/envia_csv.dart';
import 'package:projeto_infoplus/Pages/professor/perfil_professor.dart';
import 'package:projeto_infoplus/Pages/usuario/mostra_csv.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_cadastro_aluno.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';
import 'package:projeto_infoplus/Pages/professor/pagina_nota_professor.dart';
import 'package:projeto_infoplus/Services/auth_service.dart';
import 'package:projeto_infoplus/Pages/geral/auth_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projeto_infoplus/Services/url_launcher.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
// Página inicial do professor                       //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class PaginaInicialProfessor extends StatefulWidget {
  const PaginaInicialProfessor({super.key, required List<String> turmas});

  @override
  State<PaginaInicialProfessor> createState() => _PaginaInicialProfessorState();
}

class _PaginaInicialProfessorState extends State<PaginaInicialProfessor> {
  int _currentIndex = 1;
  String professorNome = '';

  final tabs = [
    Center(child: Text('Sair')),
    Center(child: Text('Home')),
    Center(child: Text('Perfil')),
  ];

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Logout do Firebase                               //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  void signOutUser() {
    FirebaseAuth.instance.signOut();
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Inicialização da tela                            //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  void initState() {
    super.initState();
    _getProfessorName();
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Buscar nome do professor com base no e-mail       //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _getProfessorName() async {
    try {
      final String professorEmail = FirebaseAuth.instance.currentUser!.email!;
      String nomeProfessor = professorEmail.split('.')[0];
      nomeProfessor = nomeProfessor[0].toUpperCase() + nomeProfessor.substring(1);

      setState(() {
        professorNome = nomeProfessor;
      });
    } catch (e) {
      print("Erro ao recuperar nome do professor: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Interface principal da tela                       //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      // AppBar superior com título e botão de logout
      appBar: AppBar(
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
      // Conteúdo principal da página                      //
      //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensagem de boas-vindas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bem-vindo(a) de volta professor(a)',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Lista de opções
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text(
                      'Selecione a opção desejada',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Primeira linha de botões
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PaginaNotaProfessor()),
                            );
                          },
                          icon: 'assets/images/notas.png',
                          title: 'NOTAS',
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {
                            FlutterWebBrowser.openWebPage(
                              url: 'https://ensino.araquari.ifc.edu.br/?_gl=1*uz1tfz*_ga*NzYzNTM0NTkxLjE3NDU2MTI2MTI.*_ga_SCB6Z3PWKN*MTc0NTYxMjYxMi4xLjAuMTc0NTYxMjYxMi42MC4wLjA.',
                              customTabsOptions: CustomTabsOptions(
                                colorScheme: CustomTabsColorScheme.dark,
                                toolbarColor: Colors.black,
                              ),
                            );
                          },
                          icon: 'assets/images/noticias.png',
                          title: 'NOTÍCIAS',
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Segunda linha de botões
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            FlutterWebBrowser.openWebPage(
                              url: 'https://ensino.ifc.edu.br/calendarios-academicos/',
                              customTabsOptions: CustomTabsOptions(
                                colorScheme: CustomTabsColorScheme.dark,
                                toolbarColor: Colors.black,
                              ),
                            );
                          },
                          icon: 'assets/images/calendario.png',
                          title: 'CALENDÁRIO',
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
      // Barra de navegação inferior                       //
      //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuração'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'Perfil'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (_currentIndex == 2) {
            Navigator.pushNamed(context, '/home/professor');
          }
        },
      ),
    );
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  // Card de menu reutilizável                         //
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
            )
          ],
        ),
      ),
    );
  }
}
