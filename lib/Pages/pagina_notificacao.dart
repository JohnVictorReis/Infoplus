import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaginaNotificacao extends StatelessWidget {
  const PaginaNotificacao({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Abrir URL no Flutter')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final Uri url = Uri.parse('https://google.com'); // URL que será aberta

              try {
                // Verifica se a URL pode ser aberta
                final bool canLaunchResult = await canLaunchUrl(url);
                print('Resultado de canLaunchUrl: $canLaunchResult');

                if (canLaunchResult) {
                  // Abre a URL no navegador externo
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  // Caso não seja possível abrir, exibe mensagem no console
                  print('Nenhum aplicativo disponível para abrir a URL.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nenhum aplicativo disponível para abrir a URL.'),
                    ),
                  );
                }
              } catch (e) {
                // Tratamento de erros inesperados
                print('Erro ao abrir a URL: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao tentar abrir a URL. Tente novamente.'),
                  ),
                );
              }
            },
            child: const Text('Abrir URL'),
          ),
        ),
      ),
    );
  }
}
