import 'package:flutter/material.dart';
import 'package:app_pickleball/screens/home_screen/View/home_screen.dart';
import 'package:app_pickleball/screens/orderlist_screen/View/orderlist_screen.dart';
import 'package:app_pickleball/screens/profile_screen/View/profile_screen.dart';
import 'package:app_pickleball/screens/setting_screen/View/setting_screen.dart';

// Tạo một key toàn cục để giữ trạng thái của navigation bar
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  static const String heroTag = 'bottomNavBar'; // Tag cho Hero animation

  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Hero widget để giữ thanh điều hướng không bị tải lại khi chuyển trang
    return Hero(
      tag: heroTag,
      child: BottomNavigationBar(
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
          // Sử dụng chuyển trang tùy chỉnh để giữ bottom navigation bar
          Widget nextScreen;

          if (index == 0) {
            nextScreen = const HomeScreen();
          } else if (index == 1) {
            nextScreen = const OrderListScreen(token: 'your_token_here');
          } else if (index == 2) {
            nextScreen = const ProfileScreen();
          } else if (index == 3) {
            nextScreen = const SettingScreen();
          } else {
            return; // Không có trang tương ứng
          }

          // Sử dụng PageRouteBuilder với chuyển tiếp tùy chỉnh để tránh tải lại navigation bar
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => nextScreen,
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                // Fade transition nhẹ nhàng
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
              maintainState: true,
            ),
          );
        },
      ),
    );
  }
}
