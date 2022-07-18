import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:telephony/telephony.dart';

class OTPVerification extends StatefulWidget {
  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  String appSignature = '';
  int otpVerificationCode = 00000;
  bool isVisible = false;
   final Telephony telephony = Telephony.instance;
  TextEditingController phoneController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });
    _listOPT();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Phone number verification"),
      //   centerTitle: true,
      //   backgroundColor: cViolet,
      //   brightness: Brightness.dark,
      // ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 32.0, right: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 60,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Confirm to ',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 20),
                              ),
                              TextSpan(
                                text: 'One Time Password',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                    fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(wordSpacing: 2.1),
                          children: [
                            TextSpan(
                              text: '\nSystem will send ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextSpan(
                              text: 'OTP ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 16),
                            ),
                            TextSpan(
                              text:
                                  'on the below number containig this phone.\n',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      PhoneFieldHint(
                        controller: phoneController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your phone number'),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        '\nN.B: SMS cost will be charged from the given number. This is for first time registration/login only.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Visibility(
                        visible: isVisible,
                        child: IgnorePointer(
                          child: PinFieldAutoFill(
                            decoration: UnderlineDecoration(
                              textStyle:
                                  TextStyle(fontSize: 20, color: Colors.black),
                              colorBuilder:
                                  FixedColorBuilder(Colors.indigo.withOpacity(0.3)),
                            ),
                            codeLength: 5,
                            onCodeSubmitted: (code) {},
                            onCodeChanged: (code) async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();

                              if (otpVerificationCode.toString() == code) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                prefs.setString('otp', 'verified');

                                print('OTP Code: $code');
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Random random = new Random();

                          otpVerificationCode = random.nextInt(88888) + 10000;
                          print(appSignature);
                          print(otpVerificationCode.toString());
                          setState(() {
                            setState(() {
                              isVisible = true;
                            });
                          });
                          String smsText =
                              '<#> Your code $otpVerificationCode\n$appSignature';
                          var uri =
                              'sms:${Uri.encodeComponent(phoneController.text)}?body=${Uri.encodeComponent(smsText)}';

                          telephony.sendSms(
                              to: "${phoneController.text}",
                              message:
                                  "<#> Your code $otpVerificationCode\n$appSignature");
                        },
                        child: Text('hurra'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _listOPT() async {
    await SmsAutoFill().listenForCode;
  }
}
