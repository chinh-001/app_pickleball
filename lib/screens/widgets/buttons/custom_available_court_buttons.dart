import 'package:flutter/material.dart';
import 'package:app_pickleball/models/available_cour_for_booking_model.dart';

class CustomAvailableCourtButtons extends StatelessWidget {
  final List<Court> availableCourts;
  final List<String> selectedCourtIds;
  final int maxSelections;
  final Function(String courtId, bool isSelected) onCourtSelected;

  const CustomAvailableCourtButtons({
    Key? key,
    required this.availableCourts,
    required this.selectedCourtIds,
    required this.maxSelections,
    required this.onCourtSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (availableCourts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          'Không có sân',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          availableCourts.map((court) {
            // Kiểm tra xem sân có được chọn hay không
            final bool isSelected = selectedCourtIds.contains(court.id);

            // Kiểm tra xem đã đạt giới hạn số lượng sân chọn chưa
            final bool reachedLimit = selectedCourtIds.length >= maxSelections;

            // Chỉ vô hiệu hóa nếu đạt giới hạn VÀ sân hiện tại chưa được chọn
            final bool isDisabled = reachedLimit && !isSelected;

            return ElevatedButton(
              onPressed:
                  isDisabled
                      ? null // Vô hiệu hóa nút nếu đã đạt giới hạn và sân này chưa được chọn
                      : () {
                        // Khi nhấn nút, thay đổi trạng thái chọn của sân
                        onCourtSelected(court.id, !isSelected);
                      },
              style: ElevatedButton.styleFrom(
                // Sân được chọn -> màu xanh, chưa chọn -> màu xám
                // Sân vô hiệu hóa -> màu xám nhạt
                backgroundColor:
                    isDisabled
                        ? Colors.grey[300]
                        : (isSelected ? Colors.green : Colors.grey),
                foregroundColor: isDisabled ? Colors.black38 : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: const Size(60, 36),
              ),
              child: Text(
                court.name,
                style: TextStyle(
                  color: isDisabled ? Colors.black38 : Colors.white,
                ),
              ),
            );
          }).toList(),
    );
  }
}
