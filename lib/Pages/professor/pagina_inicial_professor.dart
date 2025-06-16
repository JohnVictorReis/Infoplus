// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, deprecated_member_use
/*



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_infoplus/Pages/envia_csv.dart';
import 'package:projeto_infoplus/Pages/pagina_cadastro.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';
import 'package:projeto_infoplus/Pages/pagina_notificacao.dart';
import 'package:projeto_infoplus/Services/auth_service.dart';
import 'package:projeto_infoplus/Pages/auth_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projeto_infoplus/Services/url_launcher.dart';


//teste pra rodar a pagina iniciar com statefull e adicionar o menu de baixo

class PaginaInicialProfessor extends StatefulWidget {
  const PaginaInicialProfessor({super.key});

  @override
  State<PaginaInicialProfessor> createState() => _PaginaInicialProfessorState();
}

class _PaginaInicialProfessorState extends State<PaginaInicialProfessor> {
  // ignore: prefer_final_fields
  int _currentIndex = 1;

  final tabs = [
    Center(
      child: Text('Sair'),
    ),
    Center(
      child: Text('Home'),
    ),
    Center(
      child: Text('Perfil'),
    ),
  ];

//Metodo do Firebase para Logoff

  void signOutUser(){
    FirebaseAuth.instance.signOut();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
      backgroundColor:Colors.grey[900],
        title: Text('INFO+',
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
                MaterialPageRoute(
                  builder: (context) => const PaginaLogin(),
                ),
              );
            }, 
            
            icon: Icon(Icons.logout_rounded),
            color: Colors.white,
            ),
        ],
      ),
      body:SafeArea(
        child: Container(margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
             
                children: const [
                  
                  Text(
                    'Bem vindo de volta professor(a)',
                    style: TextStyle(
                      fontSize: 18,  
                      color: Colors.black,  
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                
              ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaCadastro(),
                              ),
                            );
                          },
                          icon: 'assets/images/notas.png',
                          title: 'NOTAS',
                          color: Color.fromRGBO(33, 33, 33, 1), 
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {
                          launchURL('https://www.google.com');  // Chama a função importada
                          },
                          icon: 'assets/images/noticias.png',
                          title: 'NOTICIAS',
                          color:Color.fromRGBO(33, 33, 33, 1),
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaCadastroCSV(),
                              ),
                            );
                          },
                          icon: 'assets/images/calendario.png',
                          title: 'CALENDÁRIO',
                          color: const Color.fromRGBO(33, 33, 33, 1), 
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {


                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaNotificacao(),
                              ),
                            );
                        
                          },
                          icon: 'assets/images/noticias.png',
                          title: 'SAIR',  
                          color: Color.fromRGBO(33, 33, 33, 1),
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],)
      ),
      ),


//Daqui pra baixo é o botton navigation bar funcional


      bottomNavigationBar: BottomNavigationBar(
        
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor:Colors.grey[900], 
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuração'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Perfil',
          ),
        ],
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });
          if (_currentIndex == 2) {
            Navigator.pushNamed(context, '/home/user');
          } else if(_currentIndex == 0) {

          } 
        }
      ),
    );

  //Aqui estamos definindo o widget _cardMenu, com todos os requires necessários, juntamente com as configurações do onTap    
  }
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
        padding: const EdgeInsets.symmetric(
          vertical: 36, 
        ),
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
              style: TextStyle(fontWeight: FontWeight.bold, color: fontColor),
            )
          ],
        ),
      ),
    );
  }
}

/*Classe para adicionar um menu inferior 
class BottonNavigation extends StatefulWidget {
  const BottonNavigation({super.key});

  @override
  State<BottonNavigation> createState() => _BottonNavigationState();
}

class _BottonNavigationState extends State<BottonNavigation> {
  int _currentIndex = 0;
  List<Widget> body = const [
    Icon(Icons.exit_to_app),
    Icon(Icons.home),
    Icon(Icons.account_circle_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(label: 'Sair', icon: Icon(Icons.exit_to_app)),
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              label: 'Perfil', icon: Icon(Icons.account_circle_outlined)),
        ],
      ),
    );
  }
}
*/

/*        onTap: (index) {

        }, 
        */


*/

/*//teste para mostrar o nome do professor na tela inicial
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_infoplus/Pages/envia_csv.dart';
import 'package:projeto_infoplus/Pages/mostra_csv.dart';
import 'package:projeto_infoplus/Pages/pagina_cadastro.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';
import 'package:projeto_infoplus/Pages/pagina_nota_professor.dart';
import 'package:projeto_infoplus/Pages/pagina_notificacao.dart';
import 'package:projeto_infoplus/Services/auth_service.dart';
import 'package:projeto_infoplus/Pages/auth_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projeto_infoplus/Services/url_launcher.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart'; // Importando o flutter_web_browser

class PaginaInicialProfessor extends StatefulWidget {
  const PaginaInicialProfessor({super.key, required List<String> turmas});

  @override
  State<PaginaInicialProfessor> createState() => _PaginaInicialProfessorState();
}

class _PaginaInicialProfessorState extends State<PaginaInicialProfessor> {
  int _currentIndex = 1;

  final tabs = [
    Center(child: Text('Sair')),
    Center(child: Text('Home')),
    Center(child: Text('Perfil')),
  ];

  // Método do Firebase para Logoff
  void signOutUser() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
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
                MaterialPageRoute(
                  builder: (context) => const PaginaLogin(),
                ),
              );
            },
            icon: Icon(Icons.logout_rounded),
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Bem vindo de volta professor(a)',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PaginaNotaProfessor(),
                              ),
                            );
                          },
                          icon: 'assets/images/notas.png',
                          title: 'NOTAS',
                          color: Color.fromRGBO(33, 33, 33, 1),
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {
                            // Atualizando para usar o flutter_web_browser
                            FlutterWebBrowser.openWebPage(
                              url:
                                  'https://ensino.araquari.ifc.edu.br/?_gl=1*uz1tfz*_ga*NzYzNTM0NTkxLjE3NDU2MTI2MTI.*_ga_SCB6Z3PWKN*MTc0NTYxMjYxMi4xLjAuMTc0NTYxMjYxMi42MC4wLjA.', // URL a ser aberta
                              customTabsOptions: CustomTabsOptions(
                                colorScheme: CustomTabsColorScheme.dark,
                                toolbarColor:
                                    Colors.blue, // Cor da barra de ferramentas
                              ),
                            );
                          },
                          icon: 'assets/images/noticias.png',
                          title: 'NOTICIAS',
                          color: Color.fromRGBO(33, 33, 33, 1),
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaCadastroCSV(),
                              ),
                            );
                          },
                          icon: 'assets/images/calendario.png',
                          title: 'CALENDÁRIO',
                          color: const Color.fromRGBO(33, 33, 33, 1),
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaNotificacao(),
                              ),
                            );
                          },
                          icon: 'assets/images/noticias.png',
                          title: 'SAIR',
                          color: Color.fromRGBO(33, 33, 33, 1),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuração'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Perfil',
          ),
        ],
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });
          if (_currentIndex == 2) {
            Navigator.pushNamed(context, '/home/user');
          } else if (_currentIndex == 0) {}
        },
      ),
    );
  }

  // Widget do CardMenu
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
              style: TextStyle(fontWeight: FontWeight.bold, color: fontColor),
            )
          ],
        ),
      ),
    );
  }
}
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_infoplus/Pages/professor/envia_csv.dart';
import 'package:projeto_infoplus/Pages/usuario/mostra_csv.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_cadastro_aluno.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';
import 'package:projeto_infoplus/Pages/professor/pagina_nota_professor.dart';
import 'package:projeto_infoplus/Services/auth_service.dart';
import 'package:projeto_infoplus/Pages/geral/auth_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projeto_infoplus/Services/url_launcher.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart'; // Importando o flutter_web_browser

class PaginaInicialProfessor extends StatefulWidget {
  const PaginaInicialProfessor({super.key, required List<String> turmas});

  @override
  State<PaginaInicialProfessor> createState() => _PaginaInicialProfessorState();
}

class _PaginaInicialProfessorState extends State<PaginaInicialProfessor> {
  int _currentIndex = 1;
  String professorNome = ''; // Variável para armazenar o nome do professor

  final tabs = [
    Center(child: Text('Sair')),
    Center(child: Text('Home')),
    Center(child: Text('Perfil')),
  ];

  // Método do Firebase para Logoff
  void signOutUser() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    _getProfessorName(); // Chama a função para buscar o nome do professor
  }

// Função para buscar o nome do professor logado
  Future<void> _getProfessorName() async {
    try {
      // Obtém o e-mail do usuário logado
      final String professorEmail = FirebaseAuth.instance.currentUser!.email!;

      // Extraí o nome do professor do e-mail, pegando apenas a parte antes do primeiro ponto
      String nomeProfessor =
          professorEmail.split('.')[0]; // Pega a parte antes do ponto

      // Capitaliza a primeira letra do nome
      nomeProfessor =
          nomeProfessor[0].toUpperCase() + nomeProfessor.substring(1);

      setState(() {
        professorNome =
            nomeProfessor; // Atualiza a variável com o nome extraído
      });
    } catch (e) {
      print("Erro ao recuperar nome do professor: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
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
                MaterialPageRoute(
                  builder: (context) => const PaginaLogin(),
                ),
              );
            },
            icon: Icon(Icons.logout_rounded),
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensagem de boas-vindas com o nome do professor
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bem-vindo(a) de volta professor(a) ${professorNome.isNotEmpty ? professorNome : ''}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PaginaNotaProfessor(),
                              ),
                            );
                          },
                          icon: 'assets/images/notas.png',
                          title: 'NOTAS',
                          //color: Color.fromRGBO(33, 33, 33, 1),
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {
                            // Atualizando para usar o flutter_web_browser
                            FlutterWebBrowser.openWebPage(
                              url:
                                  'https://ensino.araquari.ifc.edu.br/?_gl=1*uz1tfz*_ga*NzYzNTM0NTkxLjE3NDU2MTI2MTI.*_ga_SCB6Z3PWKN*MTc0NTYxMjYxMi4xLjAuMTc0NTYxMjYxMi42MC4wLjA.', // URL a ser aberta
                              customTabsOptions: CustomTabsOptions(
                                colorScheme: CustomTabsColorScheme.dark,
                                toolbarColor:
                                    Colors.black, // Cor da barra de ferramentas
                              ),
                            );
                          },
                          icon: 'assets/images/noticias.png',
                          title: 'NOTICIAS',
                          //color: Color.fromRGBO(33, 33, 33, 1),
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            // Atualizando para usar o flutter_web_browser
                            FlutterWebBrowser.openWebPage(
                              url:
                                  'https://ensino.ifc.edu.br/calendarios-academicos/', // URL a ser aberta
                              customTabsOptions: CustomTabsOptions(
                                colorScheme: CustomTabsColorScheme.dark,
                                toolbarColor:
                                    Colors.black, // Cor da barra de ferramentas
                              ),
                            );
                          },
                          icon: 'assets/images/calendario.png',
                          title: 'CALENDÁRIO',
                          //color: const Color.fromRGBO(33, 33, 33, 1),
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaLogin(),
                              ),
                            );
                          },
                          icon: 'assets/images/noticias.png',
                          title: 'SAIR',
                          //color: Color.fromRGBO(33, 33, 33, 1),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuração'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Perfil',
          ),
        ],
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });
          if (_currentIndex == 2) {
            Navigator.pushNamed(context, '/home/user');
          } else if (_currentIndex == 0) {}
        },
      ),
    );
  }

  // Widget do CardMenu
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
              style: TextStyle(fontWeight: FontWeight.bold, color: fontColor),
            )
          ],
        ),
      ),
    );
  }
}
