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
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4), // Bo tròn ảnh
                      child: Image.asset(
                        'assets/images/grass_bg.png', // Đường dẫn tới hình ảnh
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[index]['customerName']!, // Tên khách
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          items[index]['courtName']!, // Tên sân
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          items[index]['time']!, // Thời gian đặt sân
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          items[index]['status']!, // Trạng thái đặt sân
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Text "Loại lẻ" hoặc "Định kỳ" ở góc trên cùng bên phải
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
                // Trạng thái thanh toán ở góc dưới cùng bên phải
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(
                    items[index]['paymentStatus']!, // Trạng thái thanh toán
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
