import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/complete_booking_screen/bloc/complete_booking_screen_bloc.dart';
import 'package:app_pickleball/screens/home_screen/View/home_screen.dart';

class CompleteBookingScreen extends StatelessWidget {
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String bookingCode;
  final String court;
  final String bookingTime;
  final String bookingDate;
  final String price;

  const CompleteBookingScreen({
    Key? key,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.bookingCode,
    required this.court,
    required this.bookingTime,
    required this.bookingDate,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              CompleteBookingScreenBloc()..add(
                LoadCompleteBookingData(
                  customerName: customerName,
                  customerEmail: customerEmail,
                  customerPhone: customerPhone,
                  bookingCode: bookingCode,
                  court: court,
                  bookingTime: bookingTime,
                  bookingDate: bookingDate,
                  price: price,
                ),
              ),
      child: BlocBuilder<CompleteBookingScreenBloc, CompleteBookingScreenState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Text(
                AppLocalizations.of(context).translate('completeBooking'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildSuccessIcon(),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).translate('bookingSuccessful'),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildCustomerInfoRow(context, state),
                          const SizedBox(height: 16),
                          _buildBookingDetailsCard(context, state),
                          const SizedBox(height: 16),
                          _buildPaymentSummary(context, state),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomBar(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.green,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),
            _buildStepCircle('1', false, true),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('courtInformation'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            _buildStepCircle('2', false, true),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('customerInformation'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            _buildStepCircle('3', true, false),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('completeBooking'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(String text, bool isActive, bool isDone) {
    return isActive
        ? CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
        : Container(
          width: 24,
          height: 24,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            shape: BoxShape.circle,
            color: isDone ? Colors.white : Colors.transparent,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isDone ? Colors.green : Colors.white,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 8),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 60),
      ),
    );
  }

  Widget _buildCustomerInfoRow(
    BuildContext context,
    CompleteBookingScreenState state,
  ) {
    String displayName = customerName;
    String displayEmail = customerEmail;
    String displayPhone = customerPhone;

    if (state is CompleteBookingScreenLoaded) {
      displayName = state.customerName;
      displayEmail = state.customerEmail;
      displayPhone = state.customerPhone;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerInfoItem(Icons.person, displayName),
          const SizedBox(height: 12),
          _buildCustomerInfoItem(Icons.email, displayEmail),
          const SizedBox(height: 12),
          _buildCustomerInfoItem(Icons.phone, displayPhone),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoItem(IconData icon, String text) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: icon == Icons.person ? Colors.green : Colors.blue,
          radius: 16,
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailsCard(
    BuildContext context,
    CompleteBookingScreenState state,
  ) {
    String displayBookingCode = bookingCode;
    String displayCourt = court;
    String displayBookingTime = bookingTime;
    String displayBookingDate = bookingDate;
    String displayPrice = price;

    if (state is CompleteBookingScreenLoaded) {
      displayBookingCode = state.bookingCode;
      displayCourt = state.court;
      displayBookingTime = state.bookingTime;
      displayBookingDate = state.bookingDate;
      displayPrice = state.price;
    }

    final String bookingDetailsText = AppLocalizations.of(
      context,
    ).translate('orderDetails');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bookingDetailsText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            AppLocalizations.of(context).translate('bookingCode'),
            displayBookingCode,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            AppLocalizations.of(context).translate('court'),
            displayCourt,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            AppLocalizations.of(context).translate('time'),
            displayBookingTime,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            AppLocalizations.of(context).translate('bookingDate'),
            displayBookingDate,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            AppLocalizations.of(context).translate('price'),
            displayPrice,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(
    BuildContext context,
    CompleteBookingScreenState state,
  ) {
    String displayPrice = price;

    if (state is CompleteBookingScreenLoaded) {
      displayPrice = state.price;
    }

    final String paymentSummaryText = AppLocalizations.of(
      context,
    ).translate('paymentDetails');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paymentSummaryText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).translate('court'),
                style: const TextStyle(fontSize: 14),
              ),
              Row(
                children: [
                  Text(
                    '1 x ${displayPrice.split('VND').first}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'VND/h',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).translate('total'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    displayPrice.split('VND').first.trim(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Text(
                    ' VND',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          AppLocalizations.of(context).translate('close'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
