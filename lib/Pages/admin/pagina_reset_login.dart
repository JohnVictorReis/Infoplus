import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/Components/botoes.dart'; // ajuste o path se necessário

class PaginaResetSenhas extends StatefulWidget {
  const PaginaResetSenhas({super.key});

  @override
  State<PaginaResetSenhas> createState() => _PaginaResetSenhasState();
}

class _PaginaResetSenhasState extends State<PaginaResetSenhas> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _mensagem;
  List<String> _sugestoes = [];

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  void _buscarSugestoes(String input) async {
    if (input.trim().length < 3) {
      setState(() => _sugestoes = []);
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: input.toLowerCase())
        .orderBy('email')
        .limit(5)
        .get();

    final resultados = query.docs
        .map((doc) => doc['email']?.toString() ?? '')
        .where((email) => email.contains(input.toLowerCase()))
        .toList();

    setState(() {
      _sugestoes = resultados;
    });
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> resetarSenhaDoUsuario() async {
    setState(() {
      _isLoading = true;
      _mensagem = null;
    });

    try {
      final email = _emailController.text.trim().toLowerCase();
      if (email.isEmpty) {
        Get.snackbar("Erro", "Informe um e-mail.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          _mensagem = "Usuário não encontrado.";
        });
        return;
      }

      final doc = query.docs.first;
      await doc.reference.update({'primeiro_login': true});

      setState(() {
        _mensagem = null;
        _sugestoes = [];
        _emailController.clear(); // Limpa o campo após sucesso
      });

      Get.snackbar(
        "Sucesso",
        "Senha resetada com sucesso!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Aguarda brevemente para o snackbar ser visível, então volta
      await Future.delayed(const Duration(milliseconds: 700));
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar("Erro", "Erro ao tentar resetar: $e",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  Future<void> resetarTodosUsuarios({required String text}) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'primeiro_login': true});
      }

      Get.snackbar(
        "Sucesso",
        "Todos os usuários foram marcados como primeiro login.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Erro ao atualizar usuários: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildSugestoes() {
    if (_sugestoes.isEmpty) return const SizedBox.shrink();
    return Column(
      children: _sugestoes
          .map((email) => ListTile(
                title: Text(email),
                onTap: () {
                  setState(() {
                    _emailController.text = email;
                    _sugestoes = [];
                  });
                },
              ))
          .toList(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<bool> _confirmarResetGlobal() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmação'),
            content: const Text(
                'Tem certeza que deseja resetar a senha de TODOS os usuários?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Reset de Senha',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Informe o usuário para reset de senha:',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                onChanged: _buscarSugestoes,
                decoration: InputDecoration(
                  labelText: 'E-mail do usuário',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
              _buildSugestoes(),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        MyButton(
                          onTap: resetarSenhaDoUsuario,
                          text: 'Resetar Senha',
                          icon: Icons.lock_reset,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'ou',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                        const SizedBox(height: 15),
                        MyButton(
                          onTap: () async {
                            final confirmado = await _confirmarResetGlobal();
                            if (confirmado) {
                              await resetarTodosUsuarios(
                                text: _emailController.text,
                              );
                            }
                          },
                          text: 'Resetar Todos',
                          icon: Icons.lock_reset,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
