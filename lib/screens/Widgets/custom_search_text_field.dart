import 'package:flutter/material.dart';

class CustomSearchTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefixIcon;
  final double height;
  final double width;
  final EdgeInsets margin;
  final TextEditingController? controller; // Thêm controller
  final ValueChanged<String>? onChanged;

  const CustomSearchTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.height,
    required this.width,
    required this.margin,
    this.controller, // Khởi tạo controller
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0, // Tạo khoảng cách bên trái
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
