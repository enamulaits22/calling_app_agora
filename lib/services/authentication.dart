import 'dart:developer';
import 'package:calling_app/home_page.dart';
import 'package:calling_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';
import '../config/utils/sp_utils.dart';

class Authentication {
  // Create a CollectionReference called users that references the firestore collection
  CollectionReference users = FirebaseFirestore.instance.collection('users');

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
        content: Text("Registration Successful, login please"),
      ));
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
  Future<void> loginUserWithEmailAndPassword({required String email, required String password}) async {
    BuildContext context = navigatorKey.currentContext!;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      final fcmToken = await FirebaseMessaging.instance.getToken().then((value) => value);
      final User? _firebaseUser = FirebaseAuth.instance.currentUser;

      await addUser(fcmToken!, email, _firebaseUser!.uid);

      SharedPref.saveValueToShaprf(Config.userEmail, email);

      navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => MyHomePage(userDocumentsId: _firebaseUser.uid,)));
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

  Future<void> addUser(String token, String email, String firebaseUserId) {
    // Call the user's CollectionReference to add a new user
    return users
        .doc('$firebaseUserId')
        .set({
      'email': email,
      'token': token,
      'hasReceiverRejectedCall': 'false',
      'hasCallerEndCall': 'false'
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

}
