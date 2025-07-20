// ignore_for_file: avoid_print, unnecessary_string_escapes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_infoplus/Pages/admin/pagina_adm.dart';

final TextEditingController _nomeMateriaController =
    TextEditingController(); // Para nome da matéria
final TextEditingController _codigoMateriaController =
    TextEditingController(); // Para código da matéria

class PaginaCadastroMateria extends StatefulWidget {
  const PaginaCadastroMateria({super.key});

  @override
  State<PaginaCadastroMateria> createState() => _PaginaCadastroMateriaState();
}

class _PaginaCadastroMateriaState extends State<PaginaCadastroMateria> {
  List<String> turmas = []; // Lista de turmas disponíveis
  List<String> selectedTurmas = []; // Lista de turmas selecionadas

  @override
  void initState() {
    super.initState();
    _getTurmas(); // Buscar as turmas disponíveis
  }

  // Função para buscar as turmas disponíveis
  Future<void> _getTurmas() async {
    try {
      QuerySnapshot turmaSnapshot =
          await FirebaseFirestore.instance.collection('turmas').get();

      List<String> availableTurmas = [];
      for (var doc in turmaSnapshot.docs) {
        availableTurmas.add(doc.id); // Adiciona o nome da turma
      }

      setState(() {
        turmas = availableTurmas; // Atualiza a lista de turmas
      });
    } catch (e) {
      print("Erro ao carregar turmas: $e");
    }
  }

  // Função para gerar o e-mail com base no nome e código da matéria
  String _gerarEmailMateria(String nomeMateria, String codigoMateria) {
    String materiaNome = nomeMateria
        .split(' ')[0]
        .toLowerCase(); // Pega o primeiro nome e transforma em minúsculo
    return '$materiaNome\_$codigoMateria.professor@mail.com'; // Gera o e-mail no formato desejado
  }

  // Função para cadastrar uma nova matéria
  Future<void> _cadastrarMateria() async {
    try {
      String nomeMateria = _nomeMateriaController.text;
      String codigoMateria =
          _codigoMateriaController.text.trim(); // Código da matéria

      // Gerar o e-mail automaticamente
      String emailMateria = _gerarEmailMateria(nomeMateria, codigoMateria);

      // Salva a matéria na coleção 'materias' na raiz
      await FirebaseFirestore.instance.collection('materias').add({
        'nome': nomeMateria.toLowerCase(), // Nome da matéria em minúsculo
        'email': emailMateria, // E-mail gerado para o professor da matéria
        'codigoMateria': codigoMateria, // Código da matéria
      });

      // Agora vamos associar a matéria às turmas selecionadas
      for (String turmaId in selectedTurmas) {
        // Acessa a turma e cria a matéria dentro da coleção 'materias' da turma
        await FirebaseFirestore.instance
            .collection('turmas')
            .doc(turmaId) // Acessa a turma
            .collection('materias')
            .doc(nomeMateria.toLowerCase()) // Cria a matéria dentro da turma
            .set({
          'nome': nomeMateria.toLowerCase(), // Nome da matéria em minúsculo
          'professor': "A definir", // Nome do professor será definido depois
          'email': emailMateria, // Email do professor
        });
      }

      Get.snackbar(
        "Sucesso",
        "Matéria cadastrada com sucesso!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Após cadastro, redireciona para a página de administração
      Get.offAll(
          () => PaginaAdm()); // Redireciona para a página de administração
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Erro ao cadastrar matéria.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      print("Erro ao cadastrar matéria: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 40),
              SizedBox(height: 30),
              Text('Cadastre a Matéria agora',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              SizedBox(height: 40),

              // Campo de Nome da Matéria
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _nomeMateriaController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Nome da Matéria'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Campo código da Matéria
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _codigoMateriaController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Código da Matéria'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Seleção das turmas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: turmas.map((turma) {
                    return CheckboxListTile(
                      title: Text(turma),
                      value: selectedTurmas.contains(turma),
                      onChanged: (bool? isSelected) {
                        setState(() {
                          if (isSelected == true) {
                            selectedTurmas.add(turma);
                          } else {
                            selectedTurmas.remove(turma);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),

              // Botão para cadastrar a matéria
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ElevatedButton(
                  onPressed: _cadastrarMateria,
                  child: Text('Cadastrar Matéria'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
