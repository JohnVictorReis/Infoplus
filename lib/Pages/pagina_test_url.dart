import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Abrir URL no Flutter')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              const url = 'https://flutter.dev';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Não foi possível abrir a URL: $url';
              }
            },
            child: Text('Abrir URL'),
          ),
        ),
      ),
    );
  }
}
