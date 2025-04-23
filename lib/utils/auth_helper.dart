import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as log;

class AuthHelper {
  // Key để lưu trạng thái đăng nhập trong SharedPreferences
  static const String userLoggedInKey = "USER_LOGGED_IN";
  
  // Key để lưu token xác thực
  static const String userTokenKey = "USER_TOKEN";
  
  // Key để lưu tên người dùng
  static const String userNameKey = "USER_NAME";

  // Lưu trạng thái đăng nhập của người dùng
  static Future<bool> saveUserLoggedInStatus(bool isLoggedIn) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(userLoggedInKey, isLoggedIn);
    } catch (e) {
      log.log('Lỗi khi lưu trạng thái đăng nhập: $e');
      return false;
    }
  }

  // Lấy trạng thái đăng nhập hiện tại
  static Future<bool> getUserLoggedInStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(userLoggedInKey) ?? false;
    } catch (e) {
      log.log('Lỗi khi lấy trạng thái đăng nhập: $e');
      return false;
    }
  }

  // Lưu token xác thực
  static Future<bool> saveUserToken(String token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(userTokenKey, token);
    } catch (e) {
      log.log('Lỗi khi lưu token: $e');
      return false;
    }
  }

  // Lấy token xác thực
  static Future<String> getUserToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(userTokenKey) ?? '';
    } catch (e) {
      log.log('Lỗi khi lấy token: $e');
      return '';
    }
  }

  // Lưu tên người dùng
  static Future<bool> saveUserName(String name) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(userNameKey, name);
    } catch (e) {
      log.log('Lỗi khi lưu tên người dùng: $e');
      return false;
    }
  }

  // Lấy tên người dùng
  static Future<String> getUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(userNameKey) ?? '';
    } catch (e) {
      log.log('Lỗi khi lấy tên người dùng: $e');
      return '';
    }
  }

  // Đăng xuất - Xóa tất cả dữ liệu đăng nhập
  static Future<bool> clearUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(userTokenKey);
      await prefs.remove(userNameKey);
      return await prefs.setBool(userLoggedInKey, false);
    } catch (e) {
      log.log('Lỗi khi xóa dữ liệu người dùng: $e');
      return false;
    }
  }
}
