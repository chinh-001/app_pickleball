import 'package:flutter/material.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/custom_menu_item.dart';
import 'package:app_pickleball/screens/add_order_retail_step_1_screen/View/add_order_retail_step_1_screen.dart';

class MenuFunctionScreen extends StatelessWidget {
  const MenuFunctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('bookingType'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                AppLocalizations.of(context).translate('selectBookingType'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Danh sách các mục chức năng
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Item "định kì"
                _buildMenuItem(
                  context: context,
                  icon: Icons.repeat,
                  text: AppLocalizations.of(
                    context,
                  ).translate('booking_type_periodic'),
                  onTap: () {
                    // Xử lý khi nhấn vào mục đặt sân định kì
                    Navigator.pop(context); // Quay lại màn hình trước
                    // TODO: Thêm điều hướng đến màn hình đặt sân định kì
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          ).translate('periodicBookingSelected'),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Item "loại lẻ"
                _buildMenuItem(
                  context: context,
                  icon: Icons.calendar_today,
                  text: AppLocalizations.of(
                    context,
                  ).translate('booking_type_retail'),
                  onTap: () {
                    // Xử lý khi nhấn vào mục đặt sân lẻ
                    Navigator.pop(context); // Quay lại màn hình trước
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddOrderRetailStep1Screen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const Spacer(),

            // Nút hủy bỏ
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.green,
  }) {
    return CustomMenuItem(
      icon: icon,
      iconColor: iconColor,
      text: text,
      onTap: onTap,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      borderRadius: 8,
      height: 70,
      fontSize: 16,
      iconSize: 28,
    );
  }
}
