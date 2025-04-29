import 'package:flutter/material.dart';
import 'package:app_pickleball/services/api/api_client.dart';
import 'package:app_pickleball/screens/splash_screen/View/splash_screen.dart';
import 'package:app_pickleball/utils/connectivity_service.dart';
import 'package:app_pickleball/screens/connectivity_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo ApiClient
  await ApiClient.initialize();

  // Khởi tạo ConnectivityService
  ConnectivityService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pickleball App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Sử dụng builder để wrap tất cả các routes với ConnectivityWrapper
      builder: (context, child) {
        return ConnectivityWrapper(child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
    );
  }
}
