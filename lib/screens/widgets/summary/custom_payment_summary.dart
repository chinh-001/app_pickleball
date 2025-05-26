import 'package:flutter/material.dart';
import 'package:app_pickleball/screens/widgets/summary/custom_summary_row.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';

class CustomPaymentSummary extends StatelessWidget {
  final String bookingPrice;
  final String serviceFee;
  final String discount;
  final String totalPayment;

  const CustomPaymentSummary({
    super.key,
    required this.bookingPrice,
    required this.serviceFee,
    required this.discount,
    required this.totalPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('paymentDetails'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomSummaryRow(
                label: AppLocalizations.of(context).translate('bookingPrice'),
                value: bookingPrice,
              ),
              const SizedBox(height: 8),
              CustomSummaryRow(
                label: AppLocalizations.of(context).translate('serviceFee'),
                value: serviceFee,
              ),
              const SizedBox(height: 8),
              CustomSummaryRow(
                label: AppLocalizations.of(context).translate('discount'),
                value: discount,
                valueColor: Colors.red,
              ),
              const Divider(height: 24),
              CustomSummaryRow(
                label: AppLocalizations.of(context).translate('totalPayment'),
                value: totalPayment,
                isTotal: true,
                valueColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
