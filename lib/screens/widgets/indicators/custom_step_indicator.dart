import 'package:flutter/material.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';

class CustomStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepKeys;
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;

  const CustomStepIndicator({
    Key? key,
    required this.currentStep,
    required this.stepKeys,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: _buildStepItems(context)),
      ),
    );
  }

  List<Widget> _buildStepItems(BuildContext context) {
    List<Widget> items = [];

    for (int i = 0; i < stepKeys.length; i++) {
      // Add step circle
      items.add(_buildStepCircle('${i + 1}', currentStep >= i + 1));

      // Add step text
      items.add(const SizedBox(width: 8));
      items.add(
        Text(
          AppLocalizations.of(context).translate(stepKeys[i]),
          style: TextStyle(color: textColor),
        ),
      );

      // Add spacing between steps (except for the last step)
      if (i < stepKeys.length - 1) {
        items.add(const SizedBox(width: 16));
      }
    }

    return items;
  }

  Widget _buildStepCircle(String text, bool isActive) {
    return isActive
        ? CircleAvatar(
          radius: 12,
          backgroundColor: activeColor,
          child: Text(
            text,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        )
        : Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: inactiveColor),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(text, style: TextStyle(color: inactiveColor)),
          ),
        );
  }
}
