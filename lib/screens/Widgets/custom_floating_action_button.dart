import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/custom_choose_booking_type.dart';
import 'dart:developer' as log;

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Colors.green,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.green,
          label: AppLocalizations.of(context).translate('addNew'),
          onTap: () {
            CustomChooseBookingTypeDialog.show(context);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
          backgroundColor: Colors.green,
          label: AppLocalizations.of(context).translate('scrollUp'),
          onTap: () {
            log.log('Lướt lên được nhấn');
          },
        ),
      ],
    );
  }
}
