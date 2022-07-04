import 'package:flutter/material.dart';

class AppColor {
  AppColor._();
  static Shader linearGradient = LinearGradient(
    colors: <Color>[
      Color.fromRGBO(26, 201, 252, 1),
      Color.fromRGBO(29, 116, 242, 1)
    ],
  ).createShader(Rect.fromLTWH(104.0, 106.0, 166.0, 63.0));

  static const Color textColor = Color(0XFF9098B1);
  static const Color borderColor = Color.fromRGBO(235, 240, 255, 1);
}