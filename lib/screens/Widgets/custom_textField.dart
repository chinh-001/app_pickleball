import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black), // Đường viền màu đen
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black), // Đường viền màu đen khi focus
        ),
        prefixIcon: Icon(prefixIcon),
      ),
    );
  }
}