import 'package:flutter/material.dart';

class CustomStepCircle extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isDone;

  const CustomStepCircle({
    super.key,
    required this.text,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return isActive
        ? CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
        : Container(
          width: 24,
          height: 24,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            shape: BoxShape.circle,
            color: isDone ? Colors.white : Colors.transparent,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isDone ? Colors.green : Colors.white,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
  }
}
