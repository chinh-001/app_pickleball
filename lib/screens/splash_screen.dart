import 'package:app_pickleball/screens/login_screen/View/login_screen.dart';
// import 'package:app_pickleball/Screens/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome(); // Gọi hàm để chuyển sang màn hình chính
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3)); // Chờ 3 giây
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    ); // Chuyển sang màn hình chính
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Màu nền của splash
      body: Center(
        child: Image.asset(
          'assets/images/logo_app.png', // Thay bằng đường dẫn logo của bạn
          width: 200, // Kích thước logo
          height: 200,
          fit: BoxFit.contain, // Giữ nguyên tỷ lệ logo
        ),
      ),
    );
  }
}
