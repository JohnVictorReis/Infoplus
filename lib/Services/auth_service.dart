// ignore_for_file: avoid_print

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

      // VERIFICA SE É O PRIMEIRO LOGIN
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

