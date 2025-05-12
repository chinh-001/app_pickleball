import 'package:flutter/material.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/custom_choose_booking_type.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        CustomChooseBookingTypeDialog.show(context);
      },
      backgroundColor: Colors.green,
      child: const Icon(Icons.add_circle, color: Colors.white),
    );
  }
}
