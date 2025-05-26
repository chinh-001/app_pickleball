import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';

class CustomBookingSummary extends StatelessWidget {
  final String serviceName;
  final int courtCount;
  final double totalPayment;
  final String currencyLocale;
  final String currencySymbol;
  final int decimalDigits;

  const CustomBookingSummary({
    Key? key,
    required this.serviceName,
    required this.courtCount,
    required this.totalPayment,
    this.currencyLocale = 'vi_VN',
    this.currencySymbol = 'VNĐ',
    this.decimalDigits = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Service info
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('court'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(serviceName),
                  ],
                ),
              ),
              Text(
                '$courtCount ${AppLocalizations.of(context).translate('courts')}',
              ),
            ],
          ),
        ),

        // Total payment
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).translate('totalPayment'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                NumberFormat.currency(
                  locale: currencyLocale,
                  symbol: currencySymbol,
                  decimalDigits: decimalDigits,
                ).format(totalPayment),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
