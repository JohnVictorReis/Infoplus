//ignore_for_file: non_constant_identifier_names, avoid_print, unnecessary_to_list_in_spreads, deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';
import 'package:projeto_infoplus/Pages/usuario/mostra_csv.dart';

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  int _currentIndex = 1;
  String AlunoNome = '';
  String userId = '';
  List<Map<String, dynamic>> notificacoes = [];

  void signOutUser() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    _getAlunoNameECpf();
  }

  // Função para obter o nome e CPF do aluno
  Future<void> _getAlunoNameECpf() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        String nomeAluno = email.split('.')[0];
        nomeAluno = nomeAluno[0].toUpperCase() + nomeAluno.substring(1);

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            AlunoNome = nomeAluno;
            userId = user.uid;
          });
          _getNotificacoes(); // Chama após obter userId
        }
      }
    } catch (e) {
      print("Erro ao recuperar nome/CPF: $e");
    }
  }

  // Função para carregar as notificações para o aluno
  Future<void> _getNotificacoes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notificacoes')
          .orderBy('timestamp', descending: true)
          .limit(3) // Limitar a 3 notificações
          .get();

      final lista = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        notificacoes = List<Map<String, dynamic>>.from(lista);
      });
    } catch (e) {
      print("Erro ao carregar notificações: $e");
    }
  }

  // Função para excluir as notificações após visualização
  Future<void> _limparNotificacoes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notificacoes')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete(); // Deletando as notificações
      }

      setState(() {
        notificacoes = [];
      });
    } catch (e) {
      print("Erro ao limpar notificações: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pegando as dimensões da tela
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'INFO+',
          style: GoogleFonts.roboto(
            fontSize: screenWidth * 0.06, // Ajuste dinâmico de fonte
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              signOutUser();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PaginaLogin()),
              );
            },
            icon: Icon(Icons.logout_rounded),
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vindo(a) de volta ${AlunoNome.isNotEmpty ? AlunoNome : ''}',
                style: TextStyle(
                  fontSize: screenWidth * 0.07, // Ajuste dinâmico de fonte
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              if (notificacoes.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black54,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Notificações recentes:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      ...notificacoes.take(3).map((notificacao) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                          child: Text(
                            '- ${notificacao['mensagem'] ?? 'Mensagem não disponível'}',
                            style: TextStyle(fontSize: screenWidth * 0.04),
                          ),
                        );
                      }).toList(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: MyButton(
                          onTap: () async {
                            await _limparNotificacoes(); // Limpar notificações após visualização
                          },
                          text: 'OK',
                          icon: Icons.check,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    Text(
                      'Selecione a opção desejada',
                      style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const PaginaMostragemNotasAluno()),
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
                              url: 'https://ensino.araquari.ifc.edu.br/',
                              customTabsOptions: CustomTabsOptions(
                                colorScheme: CustomTabsColorScheme.dark,
                                toolbarColor: Colors.black,
                              ),
                            );
                          },
                          icon: 'assets/images/noticias.png',
                          title: 'NOTICIAS',
                          color: Colors.black,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
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
                        _cardMenu(
                          onTap: () {
                            FlutterWebBrowser.openWebPage(
                              url: 'https://ifc.pergamum.com.br',
                              customTabsOptions: CustomTabsOptions(
                                colorScheme: CustomTabsColorScheme.dark,
                                toolbarColor: Colors.black,
                              ),
                            );
                          },
                          icon: 'assets/images/biblioteca.png',
                          title: 'BIBLIOTECA',
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
              icon: Icon(Icons.account_circle_rounded), label: 'Perfil'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (_currentIndex == 2) {
            Navigator.pushNamed(context, '/home/user');
          }
        },
      ),
    );
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
            ),
          ],
        ),
      ),
    );
  }
}
