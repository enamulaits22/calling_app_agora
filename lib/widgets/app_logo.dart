import 'package:calling_app/config/presentation/app_color.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Audacity',
      style: new TextStyle(
        fontSize: 40.0,
        fontWeight: FontWeight.bold,
        foreground: Paint()..shader = AppColor.linearGradient,
      ),
    );
  }
}