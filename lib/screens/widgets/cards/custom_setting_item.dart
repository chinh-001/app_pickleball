import 'package:flutter/material.dart';

class CustomSettingItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Widget? leading;

  const CustomSettingItem({
    Key? key,
    required this.title,
    required this.onTap,
    this.trailing,
    this.leading,
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
            if (leading != null) leading!,
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
