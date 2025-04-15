import 'package:flutter/material.dart';
import 'package:app_pickleball/screens/home_screen/View/home_screen.dart';
import 'package:app_pickleball/screens/orderlist_screen/View/orderlist_screen.dart';
import 'package:app_pickleball/screens/profile_screen/View/profile_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.green, // Đặt màu nền cho BottomNavigationBar
      type: BottomNavigationBarType.fixed, // Giữ màu nền cố định
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_soccer),
          label: 'Đặt Sân',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tôi'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        if (index == 0) {
          // Điều hướng đến Trang chủ
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (index == 1) {
          // Điều hướng đến Danh sách đặt sân
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const OrderListScreen(token: 'your_token_here'),
            ),
          );
        } else if (index == 2) {
          // Điều hướng đến Danh sách đặt sân
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
        // Bạn có thể thêm logic điều hướng cho các mục khác nếu cần
      },
    );
  }
}
