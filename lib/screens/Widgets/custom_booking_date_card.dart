import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_pickleball/models/available_cour_for_booking_model.dart';
import 'package:app_pickleball/screens/widgets/custom_available_court_buttons.dart';
import 'package:app_pickleball/screens/widgets/custom_loading_indicator.dart';

class CustomBookingDateCard extends StatelessWidget {
  final int index;
  final DateTime date;
  final String fromTime;
  final String toTime;
  final List<Court> availableCourts;
  final List<String> selectedCourtIds;
  final int maxCourtSelections;
  final bool isCheckingAvailability;
  final Function(String courtId, bool isSelected, DateTime bookingDate)
  onCourtSelected;

  const CustomBookingDateCard({
    Key? key,
    required this.index,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.availableCourts,
    required this.selectedCourtIds,
    required this.maxCourtSelections,
    required this.onCourtSelected,
    this.isCheckingAvailability = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text('${DateFormat('E, dd/MM/yyyy').format(date)}'),
              const Spacer(),
              Text('$fromTime - $toTime'),
            ],
          ),
          const SizedBox(height: 8),

          // Loading indicator
          if (isCheckingAvailability)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomLoadingIndicator(size: 30.0),
                    SizedBox(height: 8),
                    Text('Đang kiểm tra sân có sẵn...'),
                  ],
                ),
              ),
            )
          // Court buttons
          else
            CustomAvailableCourtButtons(
              availableCourts: availableCourts,
              selectedCourtIds: selectedCourtIds,
              maxSelections: maxCourtSelections,
              onCourtSelected: (courtId, isSelected) {
                onCourtSelected(courtId, isSelected, date);
              },
            ),
        ],
      ),
    );
  }
}
