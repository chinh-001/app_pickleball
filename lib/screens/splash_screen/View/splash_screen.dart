import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/login_screen/View/login_screen.dart';
import 'package:app_pickleball/screens/home_screen/View/home_screen.dart';
import '../bloc/splash_screen_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Tạo SplashScreenBloc và kích hoạt sự kiện bắt đầu
        final bloc = SplashScreenBloc();
        bloc.add(SplashStartedEvent());
        return bloc;
      },
      child: BlocListener<SplashScreenBloc, SplashScreenState>(
        listener: (context, state) {
          // Lắng nghe trạng thái và thực hiện chuyển màn hình khi cần
          if (state is SplashNavigateToLoginState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          } else if (state is SplashNavigateToHomeState) {
            // Người dùng đã đăng nhập, chuyển đến trang chủ
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        },
        child: const SplashScreenView(),
      ),
    );
  }
}

class SplashScreenView extends StatelessWidget {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_app.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
