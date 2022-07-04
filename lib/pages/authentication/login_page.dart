import 'package:calling_app/main.dart';
import 'package:calling_app/pages/authentication/signup_page.dart';
import 'package:calling_app/services/authentication.dart';
import 'package:calling_app/widgets/app_logo.dart';
import 'package:calling_app/widgets/custom_text_button.dart';
import 'package:calling_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
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
                      placeholderText: 'Your Email',
                      textEditingController: emailController,
                      icon: Icons.email,
                    ),
                    CustomTextField(
                      placeholderText: 'Password',
                      textEditingController: passwordController,
                      icon: Icons.lock,
                    ),
                    CustomTextButton(
                      title: 'Login',
                      onTapBtn: (){
                        Authentication.loginUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => SignupPage()));
                      },
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Don\'t have an account?',
                              style: TextStyle(
                                color: Colors.grey
                              )
                            ),
                            TextSpan(
                              text: ' SignUp',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              )
                            ),
                          ],
                        ),
                      ),
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