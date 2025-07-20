import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_inicial_adm.dart';
import 'package:projeto_infoplus/Pages/usuario/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/professor/pagina_inicial_professor.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_troca_senha.dart'; // << ADICIONADO

class AuthService {
  Future<void> signin({
    required String email,
    required String password,
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
        );
        return;
      }

      Map<String, dynamic>? userData = userDoc.data();

      if (userData == null || !userData.containsKey('role')) {
        Get.snackbar(
          "Erro",
          "O campo 'role' não foi encontrado.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      final dynamic roleData = userData['role'];
      String role = '';

      if (roleData is String) {
        role = roleData;
      } else if (roleData is List && roleData.isNotEmpty) {
        role = roleData.first.toString();
      } else {
        Get.snackbar(
          "Erro",
          "Formato inesperado para 'role'.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
        );
        return;
      }

      // 🔐 VERIFICA SE É O PRIMEIRO LOGIN
      bool primeiroLogin = userData['primeiro_login'] ?? false;
      if (primeiroLogin) {
        Get.offAll(() => const PaginaTrocaSenha());
        return;
      }

      print("Role do usuário: $role");

      if (role == 'professor') {
        String turma = userData['turma'] ?? '';
        print("Turma do professor: $turma");

        Get.offAll(() => PaginaInicialProfessor(turmas: [turma]));
      } else if (role == 'usuario') {
        String turma = userData['turma'] ?? '';
        if (turma.isEmpty) {
          Get.snackbar(
            "Erro",
            "Turma não encontrada para o aluno.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        Get.offAll(() => const PaginaInicial());
      } else if (role == 'admin') {
        Get.offAll(() => PaginaInicialAdm());
      } else {
        Get.snackbar(
          "Erro",
          "Tipo de usuário não reconhecido.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'Formato de e-mail inválido.';
          break;
        case 'user-disabled':
          message = 'Usuário desativado.';
          break;
        case 'user-not-found':
          message = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta.';
          break;
        case 'network-request-failed':
          message = 'Sem conexão com a internet.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas. Tente mais tarde.';
          break;
        default:
          message = 'Erro: ${e.code}';
          break;
      }

      Get.snackbar(
        "Erro",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
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
