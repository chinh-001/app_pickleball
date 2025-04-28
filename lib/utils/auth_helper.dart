import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as log;
import 'dart:convert';

class AuthHelper {
  // Key để lưu trạng thái đăng nhập trong SharedPreferences
  static const String userLoggedInKey = "USER_LOGGED_IN";

  // Key để lưu token xác thực
  static const String userTokenKey = "USER_TOKEN";

  // Key để lưu tên người dùng
  static const String userNameKey = "USER_NAME";

  // Constants for user permissions data
  static const String userPermissionsKey = 'user_permissions';

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

  // Save user permissions data
  static Future<bool> saveUserPermissionsData(
    Map<String, dynamic> permissionsData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(permissionsData);
      await prefs.setString(userPermissionsKey, jsonData);
      return true;
    } catch (e) {
      log.log('Error saving user permissions data: $e');
      return false;
    }
  }

  // Get user permissions data
  static Future<Map<String, dynamic>?> getUserPermissionsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(userPermissionsKey);
      if (jsonData == null) return null;
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      log.log('Error getting user permissions data: $e');
      return null;
    }
  }

  // Clear user permissions data
  static Future<bool> clearUserPermissionsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(userPermissionsKey);
      return true;
    } catch (e) {
      log.log('Error clearing user permissions data: $e');
      return false;
    }
  }
}
