import 'package:flutter/material.dart';

class CustomOptionsContainer extends StatelessWidget {
  final List<Widget> children;

  const CustomOptionsContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: children),
        ),
      ),
    );
  }
}
