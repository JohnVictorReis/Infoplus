// ignore_for_file: unused_import

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
