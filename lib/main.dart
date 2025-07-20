// ignore_for_file: unused_import

/*

// ignore_for_file: prefer_const_constructors, unused_import
// Route Pages Imports     /* ignore: unused_import */             
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_infoplus/Pages/auth_page.dart';
import 'package:projeto_infoplus/Pages/envia_csv.dart';
import 'package:projeto_infoplus/Pages/pagina_cadastro.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';
import 'package:projeto_infoplus/Pages/pagina_notificacao.dart';
import 'package:projeto_infoplus/Pages/pagina_teste.dart';
import 'package:projeto_infoplus/Pages/pagina_usuario.dart';
//import 'package:fluttertoast/fluttertoast.dart';


//API Imports
import 'package:http/http.dart' as http;

//Firebase Imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//FireStore  Import
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

 FirebaseAuth.instance.setLanguageCode("pt-BR");
  runApp(AplicativoInfoPlus());
}

class AplicativoInfoPlus extends StatelessWidget {
  const AplicativoInfoPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'Info+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            //backgroundColor: Colors.white,  
            elevation: 0.0,
            shadowColor: Colors.black87),
        primaryColor: Colors.amber,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary:  Colors.deepPurpleAccent,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
    
//usando Rotas Nomeadas
      initialRoute: '/',
      routes: {
        '/': (context) => PaginaLogin(),
        '/home': (context) => PaginaInicial(),
        '/home/teste': (context) => PaginaCadastroCSV(),
        '/home/user': (context) => PaginaUsuario(),
        '/home/notify': (context) => PaginaNotificacao(),
        '/home/login': (context) => PaginaLogin(),
        
        //Pagina de registro comentada devido a regra de negócio (App não permitirá criação de conta por parte do usuário final)
        //'/home/register': (context) => PaginaCadastro(),
      },
    );
  }
}
*/

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
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.setLanguageCode("pt-BR");

  runApp(const AplicativoInfoPlus());
}

class AplicativoInfoPlus extends StatelessWidget {
  const AplicativoInfoPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
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
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const PaginaLogin()),
        //GetPage(name: '/home', page: () => const PaginaInicial()),
        GetPage(name: '/home/teste', page: () => const PaginaCadastroCSV()),
        GetPage(name: '/home/user', page: () => const PaginaUsuario()),
        GetPage(name: '/home/professor', page: () => const PerfilProfessor()),
        GetPage(
            name: '/home/teacher/profile', page: () => const PerfilProfessor()),
        //GetPage(name: '/home/notify', page: () => const PaginaNotificacao()),
        GetPage(name: '/home/login', page: () => const PaginaLogin()),
        // Adicione outras rotas aqui se necessário
      ],
    );
  }
}
