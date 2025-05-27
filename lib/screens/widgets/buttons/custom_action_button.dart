import 'package:flutter/material.dart';

class CustomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isEnabled;
  final double? fontSize;

  /// Custom button dùng cho các hành động chính trong ứng dụng như cancel, confirm
  ///
  /// [text] - Văn bản hiển thị trên nút
  /// [onPressed] - Hàm được gọi khi nhấn nút
  /// [isPrimary] - Nếu true, sử dụng kiểu primary (màu xanh), ngược lại sử dụng kiểu secondary (màu xám)
  /// [isEnabled] - Xác định xem nút có được kích hoạt hay không
  /// [fontSize] - Kích thước chữ trong nút, mặc định là null (sử dụng kích thước mặc định)
  const CustomActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isEnabled = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: isPrimary ? Colors.white : Colors.black87,
      fontSize: fontSize,
    );

    if (isPrimary) {
      return ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          disabledBackgroundColor: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: textStyle),
      );
    } else {
      return OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade400),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: textStyle),
      );
    }
  }
}
