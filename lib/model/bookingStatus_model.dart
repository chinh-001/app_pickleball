import 'dart:developer' as log;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingStatus {
  final int totalBookings;
  final double totalRevenue;
  final DateTime lastUpdated;
  final String? channelToken;

  BookingStatus({
    required this.totalBookings,
    required this.totalRevenue,
    DateTime? lastUpdated,
    this.channelToken,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // Create model from API response
  factory BookingStatus.fromMap(
    Map<String, dynamic> map, {
    String? channelToken,
  }) {
    return BookingStatus(
      totalBookings: map['totalBookings'] ?? 0,
      totalRevenue: _parseDouble(map['totalRevenue']),
      lastUpdated: DateTime.now(),
      channelToken: channelToken,
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'totalRevenue': totalRevenue,
      'lastUpdated': lastUpdated.toIso8601String(),
      'channelToken': channelToken,
    };
  }

  // Create an empty booking status
  factory BookingStatus.empty() {
    return BookingStatus(totalBookings: 0, totalRevenue: 0.0);
  }

  // Lưu dữ liệu BookingStatus vào SharedPreferences
  Future<bool> saveBookingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Lưu toàn bộ dữ liệu dưới dạng JSON
      final key = _getStorageKey(channelToken);
      await prefs.setString(key, _encodeToJson());

      log.log(
        'BookingStatus data saved successfully for channel: ${channelToken ?? "default"}',
      );
      return true;
    } catch (e) {
      log.log('Error saving BookingStatus data: $e');
      return false;
    }
  }

  // Lấy dữ liệu từ SharedPreferences
  static Future<BookingStatus> getFromStorage({String? channelToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(channelToken);
      final jsonString = prefs.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return BookingStatus.empty();
      }

      // Decode JSON và tạo đối tượng BookingStatus
      final Map<String, dynamic> map = _decodeFromJson(jsonString);
      return BookingStatus(
        totalBookings: map['totalBookings'] ?? 0,
        totalRevenue: _parseDouble(map['totalRevenue']),
        lastUpdated:
            map['lastUpdated'] != null
                ? DateTime.parse(map['lastUpdated'])
                : DateTime.now(),
        channelToken: channelToken,
      );
    } catch (e) {
      log.log('Error retrieving BookingStatus data: $e');
      return BookingStatus.empty();
    }
  }

  // Kiểm tra xem dữ liệu có hết hạn chưa (quá 1 ngày)
  bool isExpired() {
    final now = DateTime.now();
    return now.difference(lastUpdated).inDays >= 1;
  }

  // Tạo key lưu trữ trong SharedPreferences dựa vào channelToken
  static String _getStorageKey(String? channelToken) {
    return 'BOOKING_STATUS_${channelToken ?? "default"}';
  }

  // Parse double từ dynamic value
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        log.log('Error parsing string to double: $value');
        return 0.0;
      }
    }
    return 0.0;
  }

  // Encode dữ liệu thành JSON string
  String _encodeToJson() {
    return json.encode(toJson());
  }

  // Decode JSON string thành Map
  static Map<String, dynamic> _decodeFromJson(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      log.log('Error decoding JSON: $e');
      return {};
    }
  }
}
