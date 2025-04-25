import 'dart:developer' as log;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserInfo {
  final String name;
  final String email;
  final DateTime lastUpdated;

  UserInfo({required this.name, required this.email, DateTime? lastUpdated})
    : lastUpdated = lastUpdated ?? DateTime.now();

  // Tạo UserInfo từ dữ liệu API
  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(name: map['name'] ?? '', email: map['email'] ?? '');
  }

  // Tạo đối tượng UserInfo trống
  factory UserInfo.empty() {
    return UserInfo(name: '', email: '');
  }

  // Chuyển đổi UserInfo sang JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Lưu thông tin người dùng vào SharedPreferences
  Future<bool> saveUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(toJson());
      await prefs.setString('USER_INFO_DATA', jsonString);

      log.log('UserInfo đã được lưu thành công: $name, $email');
      return true;
    } catch (e) {
      log.log('Lỗi khi lưu UserInfo: $e');
      return false;
    }
  }

  // Lấy thông tin người dùng từ SharedPreferences
  static Future<UserInfo> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('USER_INFO_DATA');

      if (jsonString == null || jsonString.isEmpty) {
        log.log('Không tìm thấy dữ liệu UserInfo trong storage');
        return UserInfo.empty();
      }

      final Map<String, dynamic> data = json.decode(jsonString);

      final userInfo = UserInfo(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        lastUpdated:
            data['lastUpdated'] != null
                ? DateTime.parse(data['lastUpdated'])
                : null,
      );

      log.log(
        'Đã tải UserInfo từ storage: ${userInfo.name}, ${userInfo.email}',
      );
      return userInfo;
    } catch (e) {
      log.log('Lỗi khi tải UserInfo từ storage: $e');
      return UserInfo.empty();
    }
  }

  // Kiểm tra thông tin có hết hạn chưa (quá 30 phút)
  bool isExpired() {
    final now = DateTime.now();
    return now.difference(lastUpdated).inMinutes > 30;
  }

  // Cập nhật thông tin người dùng
  Future<UserInfo> updateUserInfo({String? name, String? email}) async {
    final updatedUserInfo = UserInfo(
      name: name ?? this.name,
      email: email ?? this.email,
    );

    await updatedUserInfo.saveUserInfo();
    return updatedUserInfo;
  }

  // Xóa thông tin người dùng khỏi storage
  static Future<bool> clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('USER_INFO_DATA');
      log.log('UserInfo đã được xóa khỏi storage');
      return true;
    } catch (e) {
      log.log('Lỗi khi xóa UserInfo: $e');
      return false;
    }
  }
}
