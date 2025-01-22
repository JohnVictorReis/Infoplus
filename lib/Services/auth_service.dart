/* Comentando todo o codigo no dia 02/01/25 para tentativa de ajuste do login e logout

// ignore_for_file: unused_local_variable, unused_element, unused_import

// ignore: avoid_web_libraries_in_flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projeto_infoplus/Pages/pagina_cadastro.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';
import 'package:projeto_infoplus/Pages/pagina_notificacao.dart';
import 'package:projeto_infoplus/Pages/pagina_usuario.dart';

class AuthService{

//Comentando signup devido a regra de negócios
/*
Future<void> signup({
  required String emailsignup,
  required String passwordsignup,
  BuildContext? context
}) async {
  try{

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailsignup,
      password: passwordsignup,
    );

   
      /*await Future.delayed(const Duration(seconds: 1));
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context !, '/home/login');*/

  } on FirebaseAuthException catch(e){
    String message = '';
    if(e.code == 'weak-password') {
      message = ' Senha muito Fraca';
    }else if (e.code =='email-already-in-use' ){
      message = 'O e-mail apresentado já está em uso';
    }
    
       Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );

  } cacth(e){

  }
}

*/


signinUser({required String email, required String password, required BuildContext context}) {}

//Login Method
//Descomentado pois criação de usuário será executada manualmente via console do Firebase 23/09/24
/*
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    
    try {

UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
//Coletando o uid do usuário logado  
String uid = userCredential.user!.uid;

//Comentado dia 02/01/25 para teste de login usando a role especifica do usuário
/*
      await Future.delayed(const Duration(seconds: 0));
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PaginaInicial()
        )
      );
*/

// Busca o papel (role) do usuário no Firestore
DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

if (userDoc.exists) {
      String role = userDoc['role'];

// Redireciona usuário com base no papel (role)
      if (role == 'professor') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const PaginaNotificacao(),
          ),
        );
        
      } else if (role == 'usuario') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const PaginaInicial(),
          ),
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

    } else {
      Fluttertoast.showToast(
        msg: "Usuário não encontrado no Firestore.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }

    } on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'Não encontramos esse e-mail em nossa base de dados.';
      } else if (e.code == 'invalid-credential') {
        message = 'Senha de usuário inválida .';
      } else if (e.code == 'user-not-found') {
        message = 'Não ach .';
      }
       Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

//Metodo de signout comentado dia 23/03/24 devido ao uso no paginaInicial 


*/

Future<void> signin({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    // Realiza o login do usuário
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Coleta o UID do usuário logado
    String uid = userCredential.user!.uid;

    // Busca o papel (role) do usuário no Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (userDoc.exists) {
      String role = userDoc['role'];

      // Verifica se o widget ainda está montado antes de usar o contexto
      if (context.mounted) {
        if (role == 'professor') {
          // Redireciona para a página de notificações
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PaginaNotificacao(),
            ),
          );
        } else if (role == 'usuario') {
          // Redireciona para a página inicial
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PaginaInicial(),
            ),
          );
        } else {
          // Exibe uma mensagem se o papel do usuário não estiver definido
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
    } else {
      // Exibe uma mensagem se o documento do usuário não for encontrado no Firestore
      Fluttertoast.showToast(
        msg: "Usuário não encontrado no Firestore.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  } on FirebaseAuthException catch (e) {
    // Tratamento de erros do FirebaseAuth
    String message = '';
    if (e.code == 'invalid-email') {
      message = 'Não encontramos esse e-mail em nossa base de dados.';
    } else if (e.code == 'invalid-credential') {
      message = 'Senha de usuário inválida.';
    } else if (e.code == 'user-not-found') {
      message = 'Usuário não encontrado.';
    }
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  } catch (e) {
    // Tratamento genérico de erros
    Fluttertoast.showToast(
      msg: "Ocorreu um erro inesperado.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}

Future<void> signout({
    required BuildContext context
  }) async {
    
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>const PaginaLogin()
        )
      );
  }
 

  } 

}

*/



// ignore_for_file: unused_local_variable, unused_element, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projeto_infoplus/Pages/pagina_cadastro.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial.dart';
import 'package:projeto_infoplus/Pages/pagina_inicial_professor.dart';
import 'package:projeto_infoplus/Pages/pagina_login.dart';
import 'package:projeto_infoplus/Pages/pagina_notificacao.dart';
import 'package:projeto_infoplus/Pages/pagina_usuario.dart';

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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role'];

        // Verifica se o widget ainda está montado antes de usar o contexto
        if (context.mounted) {
          if (role == 'professor') {
            // Redireciona para a página de notificações
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const PaginaInicialProfessor(),
              ),
            );
          } else if (role == 'usuario') {
            // Redireciona para a página inicial
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const PaginaInicial(),
              ),
            );
          } else {
            // Exibe uma mensagem se o papel do usuário não estiver definido
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
      } else {
        // Exibe uma mensagem se o documento do usuário não for encontrado no Firestore
        Fluttertoast.showToast(
          msg: "Usuário não encontrado no Firestore.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros do FirebaseAuth
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'Não encontramos esse e-mail em nossa base de dados.';
      } else if (e.code == 'invalid-credential') {
        message = 'Senha de usuário inválida.';
      } else if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      // Tratamento genérico de erros
      Fluttertoast.showToast(
        msg: "Ocorreu um erro inesperado.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
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
