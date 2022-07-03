
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                signInUserWithEmailAndPassword(
                  email: 'enamul@gmail.com',
                  password: '123456',
                );
              },
              child: Text('Sign up'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> signInUserWithEmailAndPassword({required String email, required String password}) async {
  try {
  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
} on FirebaseAuthException catch (e) {
  if (e.code == 'weak-password') {
    print('The password provided is too weak.');
  } else if (e.code == 'email-already-in-use') {
    print('The account already exists for that email.');
  }
} catch (e) {
  print(e);
}
}