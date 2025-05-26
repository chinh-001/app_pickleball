import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle style;

  const CustomText({
    super.key,
    required this.text,
    required this.onTap,
    this.style = const TextStyle(fontSize: 14, color: Colors.blueAccent),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: style,
      ),
    );
  }
}