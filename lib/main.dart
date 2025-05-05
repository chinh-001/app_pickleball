import 'package:flutter/material.dart';
import 'package:app_pickleball/services/api/api_client.dart';
import 'package:app_pickleball/screens/splash_screen/View/splash_screen.dart';
import 'package:app_pickleball/utils/connectivity_service.dart';
import 'package:app_pickleball/screens/connectivity_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_pickleball/services/localization/language_provider.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo ApiClient
  await ApiClient.initialize();

  // Khởi tạo ConnectivityService
  ConnectivityService.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pickleball App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Localization setup
      locale: languageProvider.locale,
      supportedLocales: const [Locale('en'), Locale('vi')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Sử dụng builder để wrap tất cả các routes với ConnectivityWrapper
      builder: (context, child) {
        return ConnectivityWrapper(child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
    );
  }
}
