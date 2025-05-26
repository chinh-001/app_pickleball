import 'package:flutter/material.dart';

class CustomConfirmLogoutDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;

  const CustomConfirmLogoutDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = 'Không',
    this.confirmText = 'Đồng ý',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.grey),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
