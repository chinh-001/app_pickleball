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
  });

  @override
  Widget build(BuildContext context) {
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
                value: selectedValue,
                isExpanded: true,
                onChanged: onChanged,
                items:
                    options.map((String value) {
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
