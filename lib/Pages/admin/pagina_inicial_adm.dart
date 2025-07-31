//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//          Importações necessárias para a aplicação            //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_adm.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_cadastro_aluno.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_exclusao_aluno.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';
import 'package:projeto_infoplus/Services/auth_service.dart';
import 'package:projeto_infoplus/Pages/geral/auth_page.dart';
import 'package:projeto_infoplus/Pages/usuario/mostra_csv.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//                  Tela Inicial para o Administrador          //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class PaginaInicialAdm extends StatefulWidget {
  const PaginaInicialAdm({super.key});

  @override
  State<PaginaInicialAdm> createState() => _PaginaInicialAdmState();
}

class _PaginaInicialAdmState extends State<PaginaInicialAdm> {
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //              Variáveis de estado e controle local            //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  int _currentIndex = 1;
  String AlunoNome = '';

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //         Lista de tabs utilizada no BottomNavigationBar       //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  final tabs = [
    Center(child: Text('Sair')),
    Center(child: Text('Home')),
    Center(child: Text('Perfil')),
  ];

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //               Função para deslogar o usuário                 //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  void signOutUser() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    _getAlunoName(); // Chama a função para buscar o nome do Aluno logado
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //        Busca o nome do aluno com base no e-mail logado       //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _getAlunoName() async {
    try {
      final String AlunoEmail = FirebaseAuth.instance.currentUser!.email!;
      String nomeAluno = AlunoEmail.split('.')[0];
      nomeAluno = nomeAluno[0].toUpperCase() + nomeAluno.substring(1);

      setState(() {
        AlunoNome = nomeAluno;
      });
    } catch (e) {
      print("Erro ao recuperar nome do aluno: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //        Monta a interface principal da tela do admin          //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
              //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
              //                  Saudação personalizada                      //
              //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bem-vindo(a) de volta ${AlunoNome.isNotEmpty ? AlunoNome : ''}',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
              //                   Menu principal com opções                   //
              //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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
                                builder: (context) => const PaginaAdm(),
                              ),
                            );
                          },
                          icon: 'assets/images/adm.png',
                          title: 'ADM',
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PaginaExclusaoAlunos(),
                              ),
                            );
                          },
                          icon: 'assets/images/noticias.png',
                          title: 'EXCLUIR ALUNOS',
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
                            FlutterWebBrowser.openWebPage(
                              url:
                                  'https://ensino.ifc.edu.br/calendarios-academicos/',
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

      //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
      //                Barra de navegação inferior (menu)            //
      //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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
          } else if (_currentIndex == 0) {
            // Aqui você pode adicionar a funcionalidade desejada
          }
        },
      ),
    );
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //           Widget para exibir um card no menu principal       //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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
