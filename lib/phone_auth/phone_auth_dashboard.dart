import 'package:calling_app/widgets/app_logo.dart';
import 'package:calling_app/widgets/custom_text_button.dart';
import 'package:calling_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import '../services/authentication.dart';

class PhoneAuthForm extends StatefulWidget {
  const PhoneAuthForm({Key? key}) : super(key: key);

  @override
  _PhoneAuthFormState createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController numController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: size.height,
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppLogo(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      placeholderText: 'Enter Phone Number',
                      textEditingController: numController,
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    CustomTextField(
                      placeholderText: 'Enter OTP',
                      textEditingController: otpController,
                      icon: Icons.password,
                      keyboardType: TextInputType.phone,
                    ),
                    CustomTextButton(
                      title: 'Fetch OTP',
                      onTapBtn: () {
                        Authentication().fetchOtp(phoneNumber: numController.text);
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextButton(
                      title: 'Login',
                      onTapBtn: () {
                        Authentication().verify(otp: otpController.text);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
