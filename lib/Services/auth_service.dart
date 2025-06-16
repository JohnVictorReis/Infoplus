/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial_professor.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';

class AuthService {
  Future<void> signin({
    required String email,
    required String password,
    // Remova o parâmetro context
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        Get.snackbar(
          "Erro",
          "Usuário não encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      Map<String, dynamic>? userData = userDoc.data();

      if (userData == null || !userData.containsKey('role')) {
        Get.snackbar(
          "Erro",
          "O campo 'role' não foi encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      final dynamic roleData = userData['role'];
      if (roleData == null) {
        Get.snackbar(
          "Erro",
          "O campo 'role' está vazio.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      String role = '';
      if (roleData is String) {
        role = roleData;
      } else if (roleData is List && roleData.isNotEmpty) {
        role = roleData.first.toString();
      } else {
        Get.snackbar(
          "Erro",
          "O campo 'role' está em um formato inesperado.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      print("Role do usuário: $role");

      // Aqui navegue usando GetX sem contexto
      if (role == 'professor') {
        Get.offAll(() => const PaginaInicialProfessor());
      } else if (role == 'usuario') {
        Get.offAll(() => const PaginaInicial());
      } else if (role == 'admin') {
        Get.snackbar(
          "Erro",
          "Acesso negado para administradores.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Erro",
          "Tipo de usuário não definido.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'O formato do e-mail está incorreto.';
          break;
        case 'user-disabled':
          message = 'Este usuário foi desativado.';
          break;
        case 'user-not-found':
          message = 'Usuário não encontrado. Verifique seu e-mail.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta. Tente novamente.';
          break;
        case 'network-request-failed':
          message = 'Falha na conexão com a internet. Verifique sua rede.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas de login. Tente novamente mais tarde.';
          break;
        default:
          message = 'Erro desconhecido: ${e.code}';
          break;
      }

      Get.snackbar(
        "Erro",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print("Erro ao fazer login: $e");

      Get.snackbar(
        "Erro inesperado",
        "Erro inesperado: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
    // Navegação usando GetX, sem precisar de contexto
    Get.offAll(() => const PaginaLogin());
  }
}
*/ //termina //termina o certo aqui, fica esperto pra descomentar o código
/*// Atualizado hoje dia 14/06/2025
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial_professor.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';

class AuthService {
  // Função de login que aceita e-mail e senha como parâmetros
  Future<void> signin({
    required String email,
    required String password,
  }) async {
    try {
      // Autentica o usuário com e-mail e senha usando Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Pega o UID (Identificador único) do usuário autenticado
      String uid = userCredential.user!.uid;

      // Recupera o documento do usuário a partir do UID no Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection('users') // A coleção onde o usuário está registrado
              .doc(uid)
              .get();

      // Se o documento não existir, exibe um erro
      if (!userDoc.exists || userDoc.data() == null) {
        Get.snackbar(
          "Erro",
          "Usuário não encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Obtém os dados do usuário (role e outras informações)
      Map<String, dynamic>? userData = userDoc.data();

      // Se os dados não contiverem o campo 'role', exibe um erro
      if (userData == null || !userData.containsKey('role')) {
        Get.snackbar(
          "Erro",
          "O campo 'role' não foi encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Acessa o valor da role do usuário (professor, aluno, etc.)
      final dynamic roleData = userData['role'];
      if (roleData == null) {
        Get.snackbar(
          "Erro",
          "O campo 'role' está vazio.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      String role = '';
      if (roleData is String) {
        role = roleData; // Se a role for uma string, atribui diretamente
      } else if (roleData is List && roleData.isNotEmpty) {
        role = roleData.first
            .toString(); // Se for uma lista, pega o primeiro valor
      } else {
        Get.snackbar(
          "Erro",
          "O campo 'role' está em um formato inesperado.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Verifica a role do usuário e navega para a tela correspondente
      print("Role do usuário: $role");

      // Recupera as turmas associadas ao professor (caso role seja 'professor')
      if (role == 'professor') {
        // Aqui você busca o campo 'turmas' no Firestore
        List<dynamic> turmas = userData['turmas'] ?? [];

        // Imprimir as turmas no console (ou exibir de outra forma)
        print("Turmas associadas ao professor: $turmas");

        // Navegação para a página inicial do professor
        Get.offAll(() => PaginaInicialProfessor(
              turmas: [],
            ));
      } else if (role == 'usuario') {
        // Se for aluno, vai para a tela de início do aluno
        Get.offAll(() => const PaginaInicial());
      } else if (role == 'admin') {
        // Se for admin, exibe uma mensagem de erro (caso deseje bloquear o acesso)
        Get.snackbar(
          "Erro",
          "Acesso negado para administradores.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        // Se o tipo de usuário não for reconhecido, exibe erro
        Get.snackbar(
          "Erro",
          "Tipo de usuário não definido.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Erros relacionados ao Firebase Authentication
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'O formato do e-mail está incorreto.';
          break;
        case 'user-disabled':
          message = 'Este usuário foi desativado.';
          break;
        case 'user-not-found':
          message = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta.';
          break;
        case 'network-request-failed':
          message = 'Falha na conexão com a internet. Verifique sua rede.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas de login. Tente novamente mais tarde.';
          break;
        default:
          message = 'Erro desconhecido: ${e.code}';
          break;
      }

      // Exibe mensagem de erro
      Get.snackbar(
        "Erro",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      // Qualquer outro erro inesperado
      print("Erro ao fazer login: $e");

      Get.snackbar(
        "Erro inesperado",
        "Erro inesperado: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Função para logout
  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
    // Navegação para a tela de login após o logout
    Get.offAll(() => const PaginaLogin());
  }
}
//Aqui termina o código do AuthServiceatualizadohojedia14/06
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_inicial_adm.dart';
import 'package:projeto_infoplus/Pages/usuario/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/professor/pagina_inicial_professor.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';

class AuthService {
  // Função de login que aceita e-mail e senha como parâmetros
  Future<void> signin({
    required String email,
    required String password,
  }) async {
    try {
      // Autentica o usuário com e-mail e senha usando Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Pega o UID (Identificador único) do usuário autenticado
      String uid = userCredential.user!.uid;

      // Recupera o documento do usuário a partir do UID no Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection('users') // A coleção onde o usuário está registrado
              .doc(uid)
              .get();

      // Se o documento não existir, exibe um erro
      if (!userDoc.exists || userDoc.data() == null) {
        Get.snackbar(
          "Erro",
          "Usuário não encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Obtém os dados do usuário (role e outras informações)
      Map<String, dynamic>? userData = userDoc.data();

      // Se os dados não contiverem o campo 'role', exibe um erro
      if (userData == null || !userData.containsKey('role')) {
        Get.snackbar(
          "Erro",
          "O campo 'role' não foi encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Acessa o valor da role do usuário (professor, aluno, etc.)
      final dynamic roleData = userData['role'];
      if (roleData == null) {
        Get.snackbar(
          "Erro",
          "O campo 'role' está vazio.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      String role = '';
      if (roleData is String) {
        role = roleData; // Se a role for uma string, atribui diretamente
      } else if (roleData is List && roleData.isNotEmpty) {
        role = roleData.first
            .toString(); // Se for uma lista, pega o primeiro valor
      } else {
        Get.snackbar(
          "Erro",
          "O campo 'role' está em um formato inesperado.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Verifica a role do usuário e navega para a tela correspondente
      print("Role do usuário: $role");

      // Para professor: não gera key
      if (role == 'professor') {
        // Aqui você busca o campo 'turma' no Firestore para o professor
        String turma = userData['turma'] ?? ''; // Se não tiver 'turma', ignora

        // Imprimir a turma no console (ou exibir de outra forma)
        print("Turma associada ao professor: $turma");

        // Navegação para a página inicial do professor
        Get.offAll(() => PaginaInicialProfessor(
              turmas: [turma], // Passa a turma para a página
            ));
      } else if (role == 'usuario') {
        // Se for aluno, vai para a tela de início do aluno
        // Verifica a turma do aluno
        String turma = userData['turma'] ?? ''; // Campo 'turma' para o aluno

        // Se a turma estiver vazia, exibe um erro
        if (turma.isEmpty) {
          Get.snackbar(
            "Erro",
            "Turma não encontrada para o aluno.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          return;
        }

        // Navegação para a página inicial do aluno
        Get.offAll(() => const PaginaInicial());
      } else if (role == 'admin') {
        // Se for admin, navega para a página de admin
        Get.offAll(() => PaginaInicialAdm());
      } else {
        // Se o tipo de usuário não for reconhecido, exibe erro
        Get.snackbar(
          "Erro",
          "Tipo de usuário não definido.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Erros relacionados ao Firebase Authentication
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'O formato do e-mail está incorreto.';
          break;
        case 'user-disabled':
          message = 'Este usuário foi desativado.';
          break;
        case 'user-not-found':
          message = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta.';
          break;
        case 'network-request-failed':
          message = 'Falha na conexão com a internet. Verifique sua rede.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas de login. Tente novamente mais tarde.';
          break;
        default:
          message = 'Erro desconhecido: ${e.code}';
          break;
      }

      // Exibe mensagem de erro
      Get.snackbar(
        "Erro",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Função para logout
  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
    // Navegação para a tela de login após o logout
    Get.offAll(() => const PaginaLogin());
  }
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial_professor.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';
import 'package:get/get.dart';

class AuthService {
  // Método para realizar login
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Realiza o login do usuário
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Coleta o UID do usuário logado
      String uid = userCredential.user!.uid;

      // Busca o papel (role) do usuário no Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        Fluttertoast.showToast(
          msg: "Erro: Usuário não encontrado no Firestore.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      // Obtendo os dados corretamente
      Map<String, dynamic>? userData = userDoc.data();
      
      // Verifica se o campo 'role' está presente
      if (userData == null || !userData.containsKey('role')) {
        Fluttertoast.showToast(
          msg: "Erro: O campo 'role' não foi encontrado no Firestore.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      // Pegando 'role' corretamente e garantindo que seja uma String
      final dynamic roleData = userData['role'];
      if (roleData == null) {
        Fluttertoast.showToast(
          msg: "Erro: O campo 'role' está vazio.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      // 🔹 Verifica se é uma String ou uma Lista
      String role = '';
      if (roleData is String) {
        role = roleData; // Correto se for String
      } else if (roleData is List && roleData.isNotEmpty) {
        role = roleData.first.toString(); // Se for uma lista, pega o primeiro item
      } else {
        Fluttertoast.showToast(
          msg: "Erro: O campo 'role' está em um formato inesperado.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      print("Role do usuário: $role"); // Log para depuração

      // Verifica se o widget ainda está montado antes de usar o contexto
      if (context.mounted) {
        if (role == 'professor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PaginaInicialProfessor(),
            ),
          );
        } else if (role == 'usuario') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PaginaInicial(),
            ),
          );
        } else if (role == 'admin') {
          Fluttertoast.showToast(
            msg: "Acesso negado para administradores.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Tipo de usuário não definido.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros do FirebaseAuth
      String message = '';

      switch (e.code) {
        case 'invalid-email':
          message = 'O formato do e-mail está incorreto.';
          break;
        case 'user-disabled':
          message = 'Este usuário foi desativado.';
          break;
        case 'user-not-found':
          message = 'Usuário não encontrado. Verifique seu e-mail.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta. Tente novamente.';
          break;
        case 'network-request-failed':
          message = 'Falha na conexão com a internet. Verifique sua rede.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas de login. Tente novamente mais tarde.';
          break;
        default:
          message = 'Erro desconhecido: ${e.code}';
          break;
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      print("Erro ao fazer login: $e"); // Para ver o erro no console

      Fluttertoast.showToast(
        msg: "Erro inesperado: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  // Método para realizar logout
  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PaginaLogin(),
        ),
      );
    }
  }
}

*/

/*Comentando em 2025
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Importando GetX
import 'package:projeto_infoplus/Pages/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial_professor.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';

class AuthService {
  // Método para realizar login
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Realiza o login do usuário
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Coleta o UID do usuário logado
      String uid = userCredential.user!.uid;

      // Busca o papel (role) do usuário no Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        Get.snackbar(
          "Erro",
          "Usuário não encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Obtendo os dados corretamente
      Map<String, dynamic>? userData = userDoc.data();
      
      // Verifica se o campo 'role' está presente
      if (userData == null || !userData.containsKey('role')) {
        Get.snackbar(
          "Erro",
          "O campo 'role' não foi encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Pegando 'role' corretamente e garantindo que seja uma String
      final dynamic roleData = userData['role'];
      if (roleData == null) {
        Get.snackbar(
          "Erro",
          "O campo 'role' está vazio.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // 🔹 Verifica se é uma String ou uma Lista
      String role = '';
      if (roleData is String) {
        role = roleData; // Correto se for String
      } else if (roleData is List && roleData.isNotEmpty) {
        role = roleData.first.toString(); // Se for uma lista, pega o primeiro item
      } else {
        Get.snackbar(
          "Erro",
          "O campo 'role' está em um formato inesperado.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      print("Role do usuário: $role"); // Log para depuração

      // Verifica se o widget ainda está montado antes de usar o contexto
      if (context.mounted) {
        if (role == 'professor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PaginaInicialProfessor(),
            ),
          );
        } else if (role == 'usuario') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PaginaInicial(),
            ),
          );
        } else if (role == 'admin') {
          Get.snackbar(
            "Erro",
            "Acesso negado para administradores.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black54,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            "Erro",
            "Tipo de usuário não definido.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black54,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros do FirebaseAuth
      String message = '';

      switch (e.code) {
        case 'invalid-email':
          message = 'O formato do e-mail está incorreto.';
          break;
        case 'user-disabled':
          message = 'Este usuário foi desativado.';
          break;
        case 'user-not-found':
          message = 'Usuário não encontrado. Verifique seu e-mail.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta. Tente novamente.';
          break;
        case 'network-request-failed':
          message = 'Falha na conexão com a internet. Verifique sua rede.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas de login. Tente novamente mais tarde.';
          break;
        default:
          message = 'Erro desconhecido: ${e.code}';
          break;
      }

      Get.snackbar(
        "Erro",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print("Erro ao fazer login: $e"); // Para ver o erro no console

      Get.snackbar(
        "Erro inesperado",
        "Erro inesperado: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Método para realizar logout
  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PaginaLogin(),
        ),
      );
    }
  }
}

*/

/*
class AuthService {
  Future<void> signin({
    required String email,
    required String password,
    //required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        Get.snackbar(
          "Erro",
          "Usuário não encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      Map<String, dynamic>? userData = userDoc.data();

      if (userData == null || !userData.containsKey('role')) {
        Get.snackbar(
          "Erro",
          "O campo 'role' não foi encontrado no Firestore.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final dynamic roleData = userData['role'];
      if (roleData == null) {
        Get.snackbar(
          "Erro",
          "O campo 'role' está vazio.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      String role = '';
      if (roleData is String) {
        role = roleData;
      } else if (roleData is List && roleData.isNotEmpty) {
        role = roleData.first.toString();
      } else {
        Get.snackbar(
          "Erro",
          "O campo 'role' está em um formato inesperado.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      print("Role do usuário: $role");

      // Navegar usando GetX
      if (role == 'professor') {
        Get.off(() => const PaginaInicialProfessor());
      } else if (role == 'usuario') {
        Get.off(() => const PaginaInicial());
      } else if (role == 'admin') {
        Get.snackbar(
          "Erro",
          "Acesso negado para administradores.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Erro",
          "Tipo de usuário não definido.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      switch (e.code) {
        case 'invalid-email':
          message = 'O formato do e-mail está incorreto.';
          break;
        case 'user-disabled':
          message = 'Este usuário foi desativado.';
          break;
        case 'user-not-found':
          message = 'Usuário não encontrado. Verifique seu e-mail.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta. Tente novamente.';
          break;
        case 'network-request-failed':
          message = 'Falha na conexão com a internet. Verifique sua rede.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas de login. Tente novamente mais tarde.';
          break;
        default:
          message = 'Erro desconhecido: ${e.code}';
          break;
      }

      Get.snackbar(
        "Erro",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print("Erro ao fazer login: $e");

      Get.snackbar(
        "Erro inesperado",
        "Erro inesperado: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));

    // Navegar para login usando GetX
    Get.offAll(() => const PaginaLogin());
  }
}

*/
