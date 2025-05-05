import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      // Try to load from both locations and merge the results
      Map<String, String> translations = {};

      // Try to load from lib/l10n
      try {
        String jsonString = await rootBundle.loadString(
          'lib/l10n/app_${locale.languageCode}.arb',
        );

        Map<String, dynamic> jsonMap = json.decode(jsonString);
        jsonMap.forEach((key, value) {
          if (!key.startsWith('@') && key != '@@locale' && value is String) {
            translations[key] = value;
          }
        });

        print('Loaded translations from lib/l10n successfully');
      } catch (e) {
        print('Error loading from lib/l10n: $e');
      }

      // Try to load from assets/l10n
      try {
        String jsonString = await rootBundle.loadString(
          'assets/l10n/app_${locale.languageCode}.arb',
        );

        Map<String, dynamic> jsonMap = json.decode(jsonString);
        jsonMap.forEach((key, value) {
          if (!key.startsWith('@') && key != '@@locale' && value is String) {
            // Only add if the key doesn't exist yet or deliberately override
            translations[key] = value;
          }
        });

        print('Loaded translations from assets/l10n successfully');
      } catch (e) {
        print('Error loading from assets/l10n: $e');
      }

      // If we have translations, use them
      if (translations.isNotEmpty) {
        _localizedStrings = translations;
        return true;
      }

      // If we reach here, we couldn't load from either location
      throw Exception('Could not load translations from any location');
    } catch (e) {
      print('Error loading language files: $e');

      // Fallback to hardcoded translations
      _localizedStrings = {
        'appTitle': 'Pickleball App',
        'accountSettings':
            locale.languageCode == 'vi'
                ? 'Thiết lập tài khoản'
                : 'Account Settings',
        'account': locale.languageCode == 'vi' ? 'Tài khoản' : 'Account',
        'language': locale.languageCode == 'vi' ? 'Ngôn ngữ' : 'Language',
        'selectLanguage':
            locale.languageCode == 'vi' ? 'Chọn ngôn ngữ' : 'Select Language',
        'vietnamese': locale.languageCode == 'vi' ? 'Tiếng Việt' : 'Vietnamese',
        'english': 'English',
        'save': locale.languageCode == 'vi' ? 'Lưu' : 'Save',
        'cancel': locale.languageCode == 'vi' ? 'Hủy' : 'Cancel',
        'profile': locale.languageCode == 'vi' ? 'Hồ sơ' : 'Profile',
        'settings': locale.languageCode == 'vi' ? 'Cài đặt' : 'Settings',
        'home': locale.languageCode == 'vi' ? 'Trang chủ' : 'Home',
        'search': locale.languageCode == 'vi' ? 'Tìm kiếm' : 'Search',
        'notifications':
            locale.languageCode == 'vi' ? 'Thông báo' : 'Notifications',
        'searchHint': locale.languageCode == 'vi' ? 'Tìm kiếm' : 'Search',
        'noData': locale.languageCode == 'vi' ? 'Không có dữ liệu' : 'No data',
        'personalInfo':
            locale.languageCode == 'vi'
                ? 'Thông Tin Cá Nhân'
                : 'Personal Information',
        'bookingList': locale.languageCode == 'vi' ? 'Đặt Sân' : 'Booking List',
        'name': locale.languageCode == 'vi' ? 'Tên' : 'Name',
        'email': 'Email',
        'enterYour':
            locale.languageCode == 'vi'
                ? 'Nhập {field} của bạn'
                : 'Enter your {field}',
        'edit': locale.languageCode == 'vi' ? 'Sửa' : 'Edit',
        'infoSaved':
            locale.languageCode == 'vi'
                ? 'Thông tin đã được lưu!'
                : 'Information saved!',
        'editModeEnabled':
            locale.languageCode == 'vi'
                ? 'Chế độ chỉnh sửa đã bật!'
                : 'Edit mode enabled!',
        'logout': locale.languageCode == 'vi' ? 'Đăng xuất' : 'Logout',
        'logoutConfirmTitle':
            locale.languageCode == 'vi' ? 'Đăng xuất' : 'Logout',
        'logoutConfirmMessage':
            locale.languageCode == 'vi'
                ? 'Bạn có chắc chắn muốn đăng xuất không?'
                : 'Are you sure you want to log out?',
      };

      return true;
    }
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

// LocalizationsDelegate is a factory for a set of localized resources
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
