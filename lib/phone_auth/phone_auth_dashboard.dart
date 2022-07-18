
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/authentication.dart';

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