import 'package:flutter/material.dart';

class CustomListView extends StatelessWidget {
  final List<Map<String, String>> items;

  const CustomListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Không có sân nào để hiển thị',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final String name = item['name'] ?? 'Không có tiêu đề';
          final String status = item['status'] ?? 'Không có mô tả';
          final String price = item['price'] ?? '0';
          final int rating = int.tryParse(item['rating'] ?? '0') ?? 0;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/grass_bg.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          status,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star,
                              color: starIndex < rating
                                  ? const Color.fromARGB(204, 210, 213, 19)
                                  : Colors.grey,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
