import 'package:flutter/material.dart';

class CustomChoiceItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomChoiceItem({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child:
                  isSelected
                      ? Icon(Icons.check, color: Colors.green[700], size: 22)
                      : null,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? Colors.green[700] : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
