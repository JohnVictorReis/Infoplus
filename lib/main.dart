//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Importações necessárias para funcionamento do app //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/geral/auth_page.dart';
import 'package:projeto_infoplus/Pages/professor/envia_csv.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_cadastro_aluno.dart';
import 'package:projeto_infoplus/Pages/professor/perfil_professor.dart';
import 'package:projeto_infoplus/Pages/usuario/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_adm.dart';
import 'package:projeto_infoplus/Pages/usuario/perfil_usuario.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Manipulação de mensagens recebidas em background  //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Mensagem recebida em background: ${message.messageId}');
  // Aqui você pode mostrar a notificação enquanto o app está em segundo plano
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Inicialização principal da aplicação               //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções corretas para a plataforma atual
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Define o idioma padrão para português do Brasil
  FirebaseAuth.instance.setLanguageCode("pt-BR");

  // Configura o Firebase Messaging para lidar com mensagens em segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializa notificações locais
  await _setupFlutterLocalNotifications();

  // Inicia o app
  runApp(const AplicativoInfoPlus());
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Inicializações do plugin flutter_local_notifications//
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
Future<void> _setupFlutterLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await FlutterLocalNotificationsPlugin().initialize(initializationSettings);
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Widget principal da aplicação                      //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class AplicativoInfoPlus extends StatelessWidget {
  const AplicativoInfoPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // Tema da aplicação
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0.0,
          shadowColor: Colors.black87,
        ),
        primaryColor: Colors.amber,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.deepPurpleAccent,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),

      // Rota inicial
      initialRoute: '/',

      // Definição de rotas com GetX
      getPages: [
        GetPage(name: '/', page: () => const PaginaLogin()),
        GetPage(name: '/home/teste', page: () => const PaginaCadastroCSV()),
        GetPage(name: '/home/user', page: () => const PaginaUsuario()),
        GetPage(name: '/home/professor', page: () => const PerfilProfessor()),
        GetPage(name: '/home/teacher/profile', page: () => const PerfilProfessor()),
        GetPage(name: '/home/login', page: () => const PaginaLogin()),
      ],
    );
  }
}
