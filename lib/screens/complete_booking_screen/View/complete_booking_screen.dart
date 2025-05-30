import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/complete_booking_screen/bloc/complete_booking_screen_bloc.dart';
import 'package:app_pickleball/screens/home_screen/View/home_screen.dart';
import 'package:app_pickleball/utils/number_format.dart';
import 'dart:developer' as log;

class CompleteBookingScreen extends StatelessWidget {
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String bookingCode;
  final List<BookingDetail> bookingDetails;
  final String price;

  const CompleteBookingScreen({
    Key? key,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.bookingCode,
    required this.bookingDetails,
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
                  bookingDetails: bookingDetails,
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
                          if (state is CompleteBookingScreenLoaded)
                            _buildMultipleBookingDetails(context, state),
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

  Widget _buildMultipleBookingDetails(
    BuildContext context,
    CompleteBookingScreenLoaded state,
  ) {
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
            state.bookingCode,
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < state.bookingDetails.length; i++) ...[
            const SizedBox(height: 10),
            _buildBookingSeparator(context, i + 1),
            const SizedBox(height: 10),
            _buildDetailRow(
              AppLocalizations.of(context).translate('court'),
              state.bookingDetails[i].court,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              AppLocalizations.of(context).translate('time'),
              state.bookingDetails[i].bookingTime,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              AppLocalizations.of(context).translate('bookingDate'),
              state.bookingDetails[i].bookingDate,
            ),
            const SizedBox(height: 10),
            _buildPriceDetailRow(
              context,
              AppLocalizations.of(context).translate('price'),
              state.bookingDetails[i].price,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingSeparator(BuildContext context, int bookingNumber) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${AppLocalizations.of(context).translate('booking')} #$bookingNumber',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
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
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetailRow(
    BuildContext context,
    String label,
    String priceValue,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatPrice(context, priceValue),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                ' VND',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(
    BuildContext context,
    CompleteBookingScreenState state,
  ) {
    String displayPrice = price;
    List<BookingDetail> displayBookingDetails = bookingDetails;

    if (state is CompleteBookingScreenLoaded) {
      displayPrice = state.price;
      displayBookingDetails = state.bookingDetails;
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
          for (int i = 0; i < displayBookingDetails.length; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${displayBookingDetails[i].court} (${displayBookingDetails[i].bookingDate})',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Text(
                      '1 x ${_formatPrice(context, displayBookingDetails[i].price)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      ' VND/h',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (i < displayBookingDetails.length - 1) const SizedBox(height: 8),
          ],
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
              Text(
                _formatTotalPrice(context, displayPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper để chuyển đổi string price thành định dạng toCurrency
  // Dùng cho giá đơn vị (không kèm VND)
  String _formatPrice(BuildContext context, String priceString) {
    try {
      // Loại bỏ VND và các khoảng trắng
      String cleanString = priceString.replaceAll('VND', '').trim();

      // Loại bỏ tất cả dấu phẩy để đảm bảo số được parse đúng
      cleanString = cleanString.replaceAll(',', '');

      // Parse số
      double priceValue = double.parse(cleanString);

      // Định dạng lại số tiền (không có VND)
      return priceValue.toCurrency(context).replaceAll(' VND', '');
    } catch (e) {
      // Nếu không parse được, trả về giá trị gốc đã xóa VND
      return priceString.replaceAll('VND', '').trim();
    }
  }

  // Helper để định dạng tổng giá - có kèm VND
  String _formatTotalPrice(BuildContext context, String priceString) {
    try {
      // Loại bỏ VND và các khoảng trắng
      String cleanString = priceString.replaceAll('VND', '').trim();

      // Loại bỏ tất cả dấu phẩy để đảm bảo số được parse đúng
      cleanString = cleanString.replaceAll(',', '');

      // Parse số
      double priceValue = double.parse(cleanString);

      // Định dạng lại số tiền (có VND)
      return priceValue.toCurrency(context);
    } catch (e) {
      // Nếu không parse được, trả về giá trị gốc
      return priceString;
    }
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
          // Reset HomeScreenBloc để buộc nó tải lại dữ liệu khi quay về
          log.log(
            'Resetting HomeScreenBloc để tải lại dữ liệu khi quay về màn hình chính',
          );
          HomeScreen.resetBloc();

          // Chuyển về màn hình chính và xóa hết stack
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
