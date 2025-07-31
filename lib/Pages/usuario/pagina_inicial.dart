
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Importações principais do sistema                 //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //Função para logout do usuário                     //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  void signOutUser() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    solicitarPermissaoNotificacao();
    _getAlunoNameECpf();
    _configurarFirebaseMessaging();
    
  }

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Solicita permissão de notificação (Android 13+)   //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
Future<void> solicitarPermissaoNotificacao() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Configuração do Firebase Messaging                //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
Future<void> _configurarFirebaseMessaging() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final messaging = FirebaseMessaging.instance;

  // Solicita permissão para notificação
  await messaging.requestPermission();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notificações Importantes',
    description: 'Canal usado para notificações importantes.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final token = await messaging.getToken();
  if (token != null) {
    // Passo 1: Exclui todos os tokens antigos
    final tokensSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fcmTokens')
        .get();

    for (var doc in tokensSnapshot.docs) {
      await doc.reference.delete();  // Excluindo os tokens antigos
    }

    // Passo 2: Salva o novo token
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fcmTokens')
        .doc(token)  // Usando o novo token como ID de documento
        .set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // App em primeiro plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }

    _getNotificacoes();
  });

  // App aberto pela notificação
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _getNotificacoes();
  });
}



  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //Recupera nome e ID do aluno                       //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
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
          _getNotificacoes();
        }
      }
    } catch (e) {
      print("Erro ao recuperar nome/CPF: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //Carrega notificações recentes do Firestore        //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _getNotificacoes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notificacoes')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      final lista = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        notificacoes = List<Map<String, dynamic>>.from(lista);
      });
    } catch (e) {
      print("Erro ao carregar notificações: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //Remove notificações após visualização             //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _limparNotificacoes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notificacoes')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        notificacoes = [];
      });
    } catch (e) {
      print("Erro ao limpar notificações: $e");
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //Construção da interface                           //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'INFO+',
          style: GoogleFonts.roboto(
            fontSize: screenWidth * 0.06,
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
                MaterialPageRoute(builder: (_) => const PaginaLogin()),
              );
            },
            icon: const Icon(Icons.logout_rounded),
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
                  fontSize: screenWidth * 0.07,
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
                    border: Border.all(color: Colors.black54, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Notificações recentes:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: screenHeight * 0.01),
                      ...notificacoes.map((notificacao) {
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
                          onTap: _limparNotificacoes,
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
                  physics: const BouncingScrollPhysics(),
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
                              customTabsOptions: const CustomTabsOptions(
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
                              customTabsOptions: const CustomTabsOptions(
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
                              customTabsOptions: const CustomTabsOptions(
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
        items: const [
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
