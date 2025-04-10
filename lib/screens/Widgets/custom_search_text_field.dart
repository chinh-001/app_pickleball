import 'package:flutter/material.dart';

class CustomSearchTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefixIcon;
  final double height;
  final double width;
  final EdgeInsets margin;
  final TextEditingController? controller; // Thêm controller
  final ValueChanged<String>? onChanged;

  const CustomSearchTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.height,
    required this.width,
    required this.margin,
    this.controller, // Khởi tạo controller
    this.onChanged,
  });

  @override
 Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0, // Tạo khoảng cách bên trái
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// class OrderDetailScreen extends StatelessWidget {
//   final Map<String, String> item;

//   const OrderDetailScreen({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController customerNameController = TextEditingController(text: item['customerName']);
//     final TextEditingController courtNameController = TextEditingController(text: item['courtName']);
//     final TextEditingController timeController = TextEditingController(text: item['time']);
//     final TextEditingController statusController = TextEditingController(text: item['status']);
//     final TextEditingController paymentStatusController = TextEditingController(text: item['paymentStatus']);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chi tiết đặt sân'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.asset(
//                     'assets/images/grass_bg.png', // Đường dẫn tới hình ảnh
//                     width: 200,
//                     height: 200,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               buildInfoField('Tên khách', customerNameController),
//               buildInfoField('Tên sân', courtNameController),
//               buildInfoField('Thời gian', timeController),
//               buildInfoField('Trạng thái đặt', statusController),
//               buildInfoField(
//                 'Trạng thái thanh toán',
//                 paymentStatusController,
//                 color: item['paymentStatus'] == 'Đã thanh toán' ? Colors.green : Colors.red,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildInfoField(String title, TextEditingController controller, {Color? color}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 5),
//         CustomSearchTextField(
//           hintText: '',
//           prefixIcon: SizedBox.shrink(),
//           height: 50,
//           width: double.infinity,
//           margin: EdgeInsets.zero,
//         ),
//         SizedBox(height: 10),
//       ],
//     );
//   }
// }