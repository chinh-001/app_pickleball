import 'package:flutter/material.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/add_order_retail_step_1_screen/View/add_order_retail_step_1_screen.dart';

class CustomChooseBookingTypeDialog extends StatefulWidget {
  const CustomChooseBookingTypeDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const CustomChooseBookingTypeDialog();
      },
    );
  }

  @override
  State<CustomChooseBookingTypeDialog> createState() =>
      _CustomChooseBookingTypeDialogState();
}

class _CustomChooseBookingTypeDialogState
    extends State<CustomChooseBookingTypeDialog> {
  String? selectedBookingType;

  void _selectBookingType(String type) {
    setState(() {
      selectedBookingType = type;
    });
  }

  void _confirmSelection() {
    if (selectedBookingType == null) return;

    Navigator.of(context).pop();

    if (selectedBookingType == 'retail') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddOrderRetailStep1Screen(),
        ),
      );
    } else if (selectedBookingType == 'periodic') {
      // Thêm logic chuyển đến trang đặt sân định kỳ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).translate('addNew'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildBookingOption(
                    context: context,
                    icon: Icons.calendar_month_outlined,
                    title: AppLocalizations.of(
                      context,
                    ).translate('booking_type_retail'),
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    onTap: () => _selectBookingType('retail'),
                    height: 120,
                    isSelected: selectedBookingType == 'retail',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBookingOption(
                    context: context,
                    icon: Icons.repeat,
                    title: AppLocalizations.of(
                      context,
                    ).translate('booking_type_periodic'),
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    onTap: () => _selectBookingType('periodic'),
                    height: 120,
                    isSelected: selectedBookingType == 'periodic',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).translate('cancel')),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedBookingType != null
                            ? Colors.green
                            : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                      selectedBookingType != null ? _confirmSelection : null,
                  child: Text(
                    AppLocalizations.of(context).translate('confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    TextStyle? titleStyle,
    required Function() onTap,
    double height = 100,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.green.withOpacity(0.1) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.green, size: 36),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: titleStyle ?? const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
