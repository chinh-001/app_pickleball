import 'package:flutter/material.dart';
import 'package:app_pickleball/screens/order_detail_screen/View/order_detail_screen.dart';

class CustomOrderListView extends StatelessWidget {
  final List<Map<String, String>> items;
  final void Function(Map<String, String>)? onItemTap;

  const CustomOrderListView({super.key, required this.items, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (onItemTap != null) {
              onItemTap!(items[index]);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(item: items[index]),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[index]['customerName']!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      items[index]['courtName']!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      items[index]['time']!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      items[index]['status']!,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          items[index]['type'] == 'Định kỳ'
                              ? Colors.green
                              : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      items[index]['type'] == 'Định kỳ' ? 'Định kỳ' : 'Loại lẻ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(
                    items[index]['paymentStatus']!,
                    style: TextStyle(
                      color:
                          items[index]['paymentStatus'] == 'Đã thanh toán'
                              ? Colors.green
                              : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
