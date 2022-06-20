import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final Color fillColor;
  final Color iconColor;
  final double iconSize;
  final VoidCallback onTapBtn;
  const CustomButton({
    Key? key,
    required this.icon,
    this.fillColor = Colors.white,
    this.iconColor = Colors.blueAccent,
    this.iconSize = 20,
    required this.onTapBtn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () => onTapBtn(),
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
      shape: CircleBorder(),
      elevation: 2.0,
      fillColor: fillColor,
      padding: const EdgeInsets.all(12.0),
    );
  }
}