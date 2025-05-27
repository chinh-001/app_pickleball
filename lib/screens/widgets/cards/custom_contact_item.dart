import 'package:flutter/material.dart';

class CustomContactItem extends StatelessWidget {
  final String avatarText;
  final String name;
  final String phone;
  final VoidCallback? onTap;
  final Color avatarBackgroundColor;
  final Color avatarTextColor;
  final bool removeDivider;

  const CustomContactItem({
    super.key,
    required this.avatarText,
    required this.name,
    required this.phone,
    this.onTap,
    this.avatarBackgroundColor = const Color(0xFFE0F7E6),
    this.avatarTextColor = Colors.black,
    this.removeDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            // Thêm border radius để tránh hiển thị đường viền
            borderRadius: BorderRadius.circular(removeDivider ? 0.5 : 0),
            // Đảm bảo không có border
            border: Border.all(color: Colors.transparent, width: 0),
          ),
          child: Row(
            children: [
              // Avatar với chữ viết tắt
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: avatarBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatarText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: avatarTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin liên hệ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
