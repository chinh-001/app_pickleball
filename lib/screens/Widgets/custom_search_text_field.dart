import 'package:flutter/material.dart';

class CustomSearchTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefixIcon;
  final double height;
  final double width;
  final EdgeInsets margin;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final Color? backgroundColor;

  const CustomSearchTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.height,
    required this.width,
    required this.margin,
    this.controller,
    this.onChanged,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: prefixIcon,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          isDense: true,
          filled: true,
          fillColor: backgroundColor ?? Colors.transparent,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
