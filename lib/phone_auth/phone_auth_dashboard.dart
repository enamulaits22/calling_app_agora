import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/authentication.dart';

class DashboardPage extends StatefulWidget {
  String? uid;

  DashboardPage({this.uid});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  getUid() {}

  @override
  void initState() {
    this.widget.uid = '';
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      setState(() {
        this.widget.uid = FirebaseAuth.instance.currentUser?.uid;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text('You are now logged in as ${widget.uid}'),
              SizedBox(
                height: 15.0,
              ),
              ElevatedButton(
                child: Text('Logout'),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((action) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhoneAuthForm()));
                  }).catchError((e) {
                    print(e);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneAuthForm extends StatefulWidget {
  const PhoneAuthForm({Key? key}) : super(key: key);

  @override
  _PhoneAuthFormState createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm> {
  var otpController = TextEditingController();
  var numController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                    hintText: 'Enter valid number'),
                controller: numController,
                keyboardType: TextInputType.phone,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'OTP',
                    hintText: 'Enter OTP'),
                controller: otpController,
                keyboardType: TextInputType.number,
              ),
            ),

             TextButton(
                    onPressed: () {
                      Authentication().fetchOtp(phoneNumber: numController.text);
                    },
                    child: const Text("Fetch OTP"),
                  ),

            TextButton(
                onPressed: () {
                  Authentication().verify(otp: otpController.text);
                },
                child: const Text("Login"))
          ],
        ),
      ),
    );
  }
}