import 'package:flutter/material.dart';

class CaixaTexto extends StatelessWidget {
  final String texto;
  final String nomeSessao;
  final void Function()? onPressed;
  const CaixaTexto({
    super.key, 
    required this.texto, 
    required this.nomeSessao,
    required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10)
        ),
      padding: const EdgeInsets.only(left: 15,bottom: 15, top: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nomeSessao,
                style: const TextStyle(color:Colors.grey)),

              //Botão para editar informações
              IconButton(onPressed: onPressed, 
              icon: const Icon(Icons.edit),iconSize: 20,)
            ],
          ),

          Text(texto),
        ],
      ),
    );
  }
}