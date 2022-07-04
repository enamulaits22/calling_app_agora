import 'dart:developer';
import 'package:calling_app/home_page.dart';
import 'package:calling_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authentication {
  //::::::::::::::::::::::::::::::::::::::::::::::::: SIGN UP
  static Future<void> signUpUserWithEmailAndPassword({required String email, required String password}) async {
    BuildContext context = navigatorKey.currentContext!;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      log('created account successful');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration Successful"),
      ));
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("The password provided is too weak."),
        ));
      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("The account already exists for that email."),
        ));
      }
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  //::::::::::::::::::::::::::::::::::::::::::::::::: LOGIN
  static Future<void> loginUserWithEmailAndPassword({required String email, required String password}) async {
    BuildContext context = navigatorKey.currentContext!;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => MyHomePage()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No user found for that email."),
        ));
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Wrong password provided for that user."),
        ));
      }
    }
  }
}
