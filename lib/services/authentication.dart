import 'dart:developer';
import 'package:calling_app/home_page.dart';
import 'package:calling_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';
import '../config/utils/sp_utils.dart';
import '../pages/dash_board.dart';

String vId = "";

class Authentication {
  FirebaseAuth auth = FirebaseAuth.instance;

  // Create a CollectionReference called users that references the firestore collection
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  //::::::::::::::::::::::::::::::::::::::::::::::::: SIGN UP with email and password
  Future<void> signUpUserWithEmailAndPassword(
      {required String email, required String password}) async {
    BuildContext context = navigatorKey.currentContext!;
    try {
      await auth.createUserWithEmailAndPassword(
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

  //::::::::::::::::::::::::::::::::::::::::::::::::: LOGIN WITH Email and password
  Future<void> loginUserWithEmailAndPassword(
      {required String email, required String password}) async {
    BuildContext context = navigatorKey.currentContext!;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      User? _firebaseUser = await storeDataToFirestore(email: email);

      SharedPref.saveValueToShaprf(Config.userEmail, email);

      navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (_) => MyHomePage(
                userDocumentsId: _firebaseUser!.uid,
              )));
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

  //::::::::::::::::::::::::::::::::::::::::::::::::: Fetch Otp from Firebase
  Future<void> fetchOtp({required String phoneNumber}) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        vId = verificationId;
        print('vId: $vId');
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  //::::::::::::::::::::::::::::::::::::::::::::::::: Verify Otp and SignIn
  Future<void> verify({required String otp}) async {
    PhoneAuthCredential phoneAuthCredential =
        PhoneAuthProvider.credential(verificationId: vId, smsCode: otp);
    print('vId phoneAuthCredential: $vId');

    signInWithPhoneAuthCredential(phoneAuthCredential);
  }

  Future<void> signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    try {
      final authCredential =
          await auth.signInWithCredential(phoneAuthCredential);

      User? _firebaseUser = await storeDataToFirestore(
          phoneNumber: authCredential.user!.phoneNumber);

      if (_firebaseUser != null) {
        Navigator.push(
            navigatorKey.currentState!.context,
            MaterialPageRoute(
                builder: (context) => DashboardPage(
                      uid: _firebaseUser.uid,
                    )));
      }
    } on FirebaseAuthException catch (e) {
      print("catch: $e");
    }
  }

  Future<User?> storeDataToFirestore(
      {String? email, String? phoneNumber}) async {

    final User? _firebaseUser = auth.currentUser;

    return _firebaseUser;
  }

  //::::::::::::::::::::::::::::::::::::::::::::::::: Storing Credential data to Firestore
  Future<void> addUser(
      {
      String? email,
      String? phoneNumber,
      String? userName,
      String? profilePicture,}) async{

    final fcmToken =
    await FirebaseMessaging.instance.getToken().then((value) => value);
    final User? _firebaseUser = auth.currentUser;

    // Call the user's CollectionReference to add a new user
    return users
        .doc('${_firebaseUser!.uid}')
        .set({
          'email': email,
          'phoneNumber': phoneNumber ?? auth.currentUser?.phoneNumber,
          'token': fcmToken,
          'hasReceiverRejectedCall': 'false',
          'hasCallerEndCall': 'false',
          'userName': userName,
          'profilePicture': profilePicture,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
