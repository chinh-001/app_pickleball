import 'package:flutter/material.dart';
import 'package:app_pickleball/screens/order_detail_screen/View/order_detail_screen.dart';

class BookingItem {
  final String name;
  final String court;
  final String time;
  final String type;
  final bool isPaid;
  final String status;

  BookingItem({
    required this.name,
    required this.court,
    required this.time,
    required this.type,
    required this.isPaid,
    required this.status,
  });

  factory BookingItem.fromMap(Map<String, String> map) {
    return BookingItem(
      name: map['customerName'] ?? '',
      court: map['courtName'] ?? '',
      time: map['time'] ?? '',
      type: map['type'] ?? '',
      isPaid: map['paymentStatus'] == 'Đã thanh toán',
      status: map['status'] ?? '',
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
        final bool isPaid = item['paymentStatus'] == 'Đã thanh toán';
        print(item['type']);
        final bool isRecurring = item['type'] == 'Định kì';
        print(isRecurring);
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
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['status'] ?? '',
                          style: const TextStyle(
                            color: Colors.blue,
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
                        isPaid ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: isPaid ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPaid ? 'Đã thanh toán' : 'Chưa thanh toán',
                        style: TextStyle(
                          color: isPaid ? Colors.green : Colors.red,
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
}
