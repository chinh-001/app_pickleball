import 'package:flutter/material.dart';
import 'package:app_pickleball/screens/order_detail_screen/View/order_detail_screen.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';

class BookingItem {
  final String name;
  final String court;
  final String time;
  final String type;
  final String paymentStatusId;
  final String statusId;

  BookingItem({
    required this.name,
    required this.court,
    required this.time,
    required this.type,
    required this.paymentStatusId,
    required this.statusId,
  });

  factory BookingItem.fromMap(Map<String, String> map) {
    return BookingItem(
      name: map['customerName'] ?? '',
      court: map['courtName'] ?? '',
      time: map['time'] ?? '',
      type: map['type'] ?? '',
      paymentStatusId: map['paymentStatusId'] ?? '1', // Default to unpaid (1)
      statusId: map['statusId'] ?? '1', // Default to new (1)
    );
  }
}

class CustomOrderListView extends StatelessWidget {
  final List<Map<String, String>> items;
  final void Function(Map<String, String>)? onItemTap;

  const CustomOrderListView({super.key, required this.items, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final String paymentStatusId =
            item['paymentStatusId'] ?? '1'; // Default to unpaid (1)
        final String statusId = item['statusId'] ?? '1'; // Default to new (1)
        final bool isRecurring = item['type'] == 'Định kì';

        return GestureDetector(
          onTap: () {
            if (onItemTap != null) {
              onItemTap!(item);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(item: item),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['courtName'] ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isRecurring ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isRecurring ? 'Định kỳ' : 'Loại lẻ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['customerName'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['time'] ?? '',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(statusId),
                          size: 16,
                          color: _getStatusColor(statusId),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getLocalizedStatus(context, statusId),
                          style: TextStyle(
                            color: _getStatusColor(statusId),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ), // Thêm khoảng trống cho payment status
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPaymentStatusIcon(paymentStatusId),
                        size: 16,
                        color: _getPaymentStatusColor(paymentStatusId),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getLocalizedPaymentStatus(context, paymentStatusId),
                        style: TextStyle(
                          color: _getPaymentStatusColor(paymentStatusId),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getPaymentStatusIcon(String statusId) {
    switch (statusId) {
      case '2': // Paid
        return Icons.check_circle;
      case '3': // Completed
        return Icons.done_all;
      case '4': // Deposit
        return Icons.account_balance_wallet;
      case '5': // Refunded
        return Icons.undo;
      case '6': // Canceled
        return Icons.cancel;
      case '1': // Unpaid
      default:
        return Icons.error;
    }
  }

  Color _getPaymentStatusColor(String statusId) {
    switch (statusId) {
      case '2': // Paid
      case '3': // Completed
        return Colors.green;
      case '4': // Deposit
        return Colors.orange;
      case '5': // Refunded
        return Colors.blue;
      case '6': // Canceled
        return Colors.red;
      case '1': // Unpaid
      default:
        return Colors.red;
    }
  }

  String _getLocalizedPaymentStatus(BuildContext context, String statusId) {
    return AppLocalizations.of(context).translate('payment_status_$statusId');
  }

  IconData _getStatusIcon(String statusId) {
    switch (statusId) {
      case '2': // Booked
        return Icons.event_available;
      case '3': // Time Conflict
        return Icons.access_time_filled;
      case '4': // Confirmed
        return Icons.thumb_up;
      case '5': // Check-in
        return Icons.login;
      case '6': // Check-out
        return Icons.logout;
      case '7': // Admin Canceled
      case '8': // Customer Canceled
        return Icons.cancel;
      case '9': // Completed
        return Icons.task_alt;
      case '1': // New
      default:
        return Icons.fiber_new;
    }
  }

  Color _getStatusColor(String statusId) {
    switch (statusId) {
      case '2': // Booked
      case '4': // Confirmed
        return Colors.blue;
      case '3': // Time Conflict
        return Colors.orange;
      case '5': // Check-in
        return Colors.green;
      case '6': // Check-out
        return Colors.purple;
      case '7': // Admin Canceled
      case '8': // Customer Canceled
        return Colors.red;
      case '9': // Completed
        return Colors.teal;
      case '1': // New
      default:
        return Colors.blue;
    }
  }

  String _getLocalizedStatus(BuildContext context, String statusId) {
    return AppLocalizations.of(context).translate('status_$statusId');
  }
}
