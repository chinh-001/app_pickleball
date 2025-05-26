import 'package:flutter/material.dart';

class CustomMultilineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomMultilineTextField({
    super.key,
    required this.controller,
    this.hintText = '',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3, // Giới hạn nhập tối đa 3 dòng
      keyboardType: TextInputType.multiline, // Bàn phím hỗ trợ nhập nhiều dòng
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15, // Tăng khoảng cách dọc để tăng chiều cao
          horizontal: 15,
        ),
      ),
    );
  }
}