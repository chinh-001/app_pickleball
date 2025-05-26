import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String?> onChanged;
  final double? titleFontSize;
  final double? itemFontSize;
  final double? dropdownWidth;
  final double? dropdownHeight;
  final double? menuMaxHeight;

  const CustomDropdown({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.titleFontSize,
    this.itemFontSize,
    this.dropdownWidth,
    this.dropdownHeight,
    this.menuMaxHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Xử lý trường hợp options rỗng
    final List<String> safeOptions =
        options.isEmpty ? ['Default channel'] : options;

    // Đảm bảo selectedValue có trong danh sách options
    String safeSelectedValue = selectedValue;
    if (selectedValue.isEmpty) {
      safeSelectedValue = safeOptions.first;
    } else if (!safeOptions.contains(selectedValue)) {
      // Nếu giá trị được chọn không có trong danh sách, thêm vào
      safeOptions.add(selectedValue);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize ?? 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: dropdownWidth ?? double.infinity,
          height: dropdownHeight ?? 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 54, 44, 44)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: safeSelectedValue,
                isExpanded: true,
                onChanged: onChanged,
                menuMaxHeight: menuMaxHeight ?? 200,
                itemHeight: 50,
                items:
                    safeOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(fontSize: itemFontSize ?? 14),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
