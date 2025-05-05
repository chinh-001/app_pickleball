import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  // Immediately return the current locale
  Locale get currentLocale => _locale;

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'vi';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    }
  }
}
