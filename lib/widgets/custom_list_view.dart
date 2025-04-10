import 'package:flutter/material.dart';

class CustomListView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onItemTap;

  const CustomListView({Key? key, required this.items, required this.onItemTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                item['name']?[0] ?? '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(item['name'] ?? 'Unknown Court'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${item['status'] ?? 'Unknown'}'),
                Text('Price: \$${item['price']?.toStringAsFixed(2) ?? '0.00'}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => onItemTap(item),
          ),
        );
      },
    );
  }
}
