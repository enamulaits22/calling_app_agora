import 'package:calling_app/config/presentation/app_color.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String title;
  final VoidCallback onTapBtn;
  final bool showArrow;
  const CustomTextButton({
    Key? key,
    required this.title,
    required this.onTapBtn,
    this.showArrow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTapBtn();
      },
      child: Container(
        height: 48,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: AppColor.blueGradient,
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: Center(
          child: showArrow
              ? Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                )
              : Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}