//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//               Importações necessárias            //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart';
import 'package:projeto_infoplus/Pages/usuario/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/professor/pagina_inicial_professor.dart';
import 'package:projeto_infoplus/Pages/geral/pagina_login.dart';

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//       Tela de troca de senha no primeiro login   //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class PaginaTrocaSenha extends StatefulWidget {
  const PaginaTrocaSenha({super.key});

  @override
  State<PaginaTrocaSenha> createState() => _PaginaTrocaSenhaState();
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//   Controladores de texto, verificação e lógica   //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
class _PaginaTrocaSenhaState extends State<PaginaTrocaSenha> {
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  bool _isLoading = false;

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //      Função para alterar a senha do usuário     //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> _alterarSenha() async {
    final user = FirebaseAuth.instance.currentUser;
    final novaSenha = _novaSenhaController.text.trim();
    final confirmarSenha = _confirmarSenhaController.text.trim();

    // Verifica se as senhas coincidem
    if (novaSenha != confirmarSenha) {
      Get.snackbar("Erro", "As senhas não coincidem.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    // Verifica o tamanho mínimo da senha
    if (novaSenha.length < 6) {
      Get.snackbar("Erro", "A senha deve ter no mínimo 6 caracteres.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Atualiza a senha no Firebase Authentication
      await user!.updatePassword(novaSenha);

      // Atualiza o campo 'primeiro_login' no Firestore
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.update({'primeiro_login': false});

      // Obtém os dados do usuário para redirecionamento
      final doc = await docRef.get();
      final role = doc['role'];
      final turma = doc.data()?['turma'] ?? '';

      // Exibe mensagem de sucesso
      Get.snackbar("Sucesso", "Senha alterada com sucesso!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      // Aguarda brevemente antes de redirecionar
      await Future.delayed(const Duration(seconds: 1));

      // Redireciona conforme o tipo de usuário
      if (role == 'usuario') {
        Get.offAll(() => const PaginaInicial());
      } else if (role == 'professor') {
        Get.offAll(() => PaginaInicialProfessor(turmas: [turma]));
      } else {
        Get.offAll(() => const PaginaLogin());
      }
    } catch (e) {
      // Em caso de erro na alteração
      Get.snackbar("Erro", "Não foi possível alterar a senha.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //        Libera os controladores da memória        //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  void dispose() {
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  //             Interface da tela de troca de senha  //
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Informe sua nova senha',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Campo para digitar nova senha
            TextField(
              cursorColor: Colors.black,
              controller: _novaSenhaController,
              obscureText: true,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: 20),

            // Campo para confirmar nova senha
            TextField(
              cursorColor: Colors.black,
              controller: _confirmarSenhaController,
              obscureText: true,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: 30),

            // Botão para alterar a senha
            MyButton(
              text: _isLoading ? "" : "Alterar Senha",
              icon: Icons.lock_reset,
              onTap: () {
                _isLoading ? null : _alterarSenha();
              },
            )
          ],
        ),
      ),
    );
  }
}
