import 'package:flutter/material.dart';
import 'dart:async';

class CustomSearchTextField extends StatefulWidget {
  final String hintText;
  final Widget? prefixIcon;
  final double height;
  final double width;
  final EdgeInsets margin;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final Color? backgroundColor;
  final Duration debounceTime;

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
    this.debounceTime = const Duration(milliseconds: 400),
  });

  @override
  State<CustomSearchTextField> createState() => _CustomSearchTextFieldState();
}

class _CustomSearchTextFieldState extends State<CustomSearchTextField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceTime, () {
      if (widget.onChanged != null) {
        widget.onChanged!(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextField(
        controller: widget.controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: widget.prefixIcon,
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
          fillColor: widget.backgroundColor ?? Colors.transparent,
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
}
