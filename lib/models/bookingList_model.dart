import 'dart:developer' as log;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Đã loại bỏ Court class, sử dụng trực tiếp Map<String, dynamic> thay thế

// Mô hình cho một đặt sân cụ thể
class BookingOrder {
  final String customerName;
  final String courtName;
  final String time;
  final String type;
  final String status;
  final String statusId;
  final String paymentStatus;
  final String paymentStatusId;
  final String phoneNumber;
  final String emailAddress;
  final String totalPrice;
  final String noteCustomer;
  final String code;
  final String id;

  BookingOrder({
    required this.customerName,
    required this.courtName,
    required this.time,
    required this.type,
    required this.status,
    this.statusId = '',
    required this.paymentStatus,
    this.paymentStatusId = '',
    required this.phoneNumber,
    required this.emailAddress,
    required this.totalPrice,
    this.noteCustomer = '',
    this.code = '',
    this.id = '',
  });

  factory BookingOrder.fromMap(Map<String, dynamic> map) {
    // Log the raw map for debugging
    // log.log('BookingOrder.fromMap received: ${json.encode(map)}');

    // Extract customer info
    final customer = map['customer'] as Map? ?? {};
    final firstName = customer['firstName']?.toString() ?? '';
    final lastName = customer['lastName']?.toString() ?? '';

    // Check both fields and log detailed information
    // log.log('Customer firstName: "$firstName", lastName: "$lastName"');

    final customerName =
        firstName.isNotEmpty || lastName.isNotEmpty
            ? '$firstName $lastName'.trim()
            : 'Không có tên';

    // log.log('Constructed customerName: "$customerName"');

    final phoneNumber = customer['phoneNumber']?.toString() ?? '';
    final emailAddress = customer['emailAddress']?.toString() ?? '';

    // Extract court info
    final court = map['court'] as Map? ?? {};
    final courtName = court['name']?.toString() ?? 'Không có tên sân';

    // Extract time info
    final startTime = map['start_time']?.toString() ?? '';
    final endTime = map['end_time']?.toString() ?? '';
    final timeRange =
        startTime.isNotEmpty && endTime.isNotEmpty
            ? '$startTime - $endTime'
            : 'Không có thời gian';

    // Extract total price
    final totalPrice = map['total_price']?.toString() ?? '';

    // Extract and map type
    final rawType = map['type']?.toString().toLowerCase() ?? '';
    final type =
        rawType.isEmpty ? 'retail' : rawType; // default to retail if empty

    // Extract booking status from API response
    final statusObj = map['status'] as Map?;
    final status = statusObj?['name']?.toString() ?? 'Mới';
    final statusId = statusObj?['id']?.toString() ?? '';

    // Extract payment status
    final paymentStatusObj = map['paymentstatus'] as Map?;
    final paymentStatus =
        paymentStatusObj?['name']?.toString() ?? 'Chưa thanh toán';
    final paymentStatusId = paymentStatusObj?['id']?.toString() ?? '';

    // Extract new fields with detailed logging
    // log.log('Extracting noteCustomer, code, and id fields:');
    // log.log('  Raw noteCustomer: "${map['noteCustomer']}"');
    // log.log('  Raw code: "${map['code']}"');
    // log.log('  Raw id: "${map['id']}"');

    final noteCustomer = map['noteCustomer']?.toString() ?? '';
    final code = map['code']?.toString() ?? '';
    final id = map['id']?.toString() ?? '';

    // log.log('  Extracted noteCustomer: "$noteCustomer"');
    // log.log('  Extracted code: "$code"');
    // log.log('  Extracted id: "$id"');

    return BookingOrder(
      customerName: customerName,
      courtName: courtName,
      time: timeRange,
      type: type,
      status: status,
      statusId: statusId,
      paymentStatus: paymentStatus,
      paymentStatusId: paymentStatusId,
      phoneNumber: phoneNumber,
      emailAddress: emailAddress,
      totalPrice: totalPrice,
      noteCustomer: noteCustomer,
      code: code,
      id: id,
    );
  }

  Map<String, String> toJson() {
    // Explicitly include all fields in the JSON representation
    final map = {
      'customerName': customerName,
      'courtName': courtName,
      'time': time,
      'type': type,
      'status': status,
      'statusId': statusId,
      'paymentStatus': paymentStatus,
      'paymentStatusId': paymentStatusId,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'total_price': totalPrice,
      // Always include these fields, even if empty
      'id': id,
      'code': code,
      'noteCustomer': noteCustomer,
    };

    // Log the map for debugging purposes
    // log.log(
    //   'BookingOrder.toJson() result contains fields: ${map.keys.join(", ")}',
    // );
    // log.log('customerName in JSON: "${map['customerName']}"');

    return map;
  }
}

// Mô hình danh sách đặt sân (orders)
class BookingOrderList {
  final List<BookingOrder> orders;
  final DateTime lastUpdated;
  final String channelToken;
  final DateTime bookingDate;
  final int totalItems;

  BookingOrderList({
    required this.orders,
    required this.channelToken,
    required this.bookingDate,
    this.totalItems = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory BookingOrderList.fromApiResponse(
    Map<String, dynamic> response, {
    required String channelToken,
    required DateTime bookingDate,
  }) {
    try {
      // Xử lý response và tạo danh sách BookingOrder
      final data = response['data'];
      if (data == null) {
        log.log('Dữ liệu API không hợp lệ: data is null');
        return BookingOrderList(
          orders: [],
          channelToken: channelToken,
          bookingDate: bookingDate,
        );
      }

      final getAllBooking = data['getAllBooking'];
      if (getAllBooking == null) {
        log.log('Dữ liệu API không hợp lệ: getAllBooking is null');
        return BookingOrderList(
          orders: [],
          channelToken: channelToken,
          bookingDate: bookingDate,
        );
      }

      final totalItems = getAllBooking['totalItems'] as int? ?? 0;
      final items = getAllBooking['items'] as List? ?? [];

      if (items.isEmpty) {
        log.log('Không có đặt sân nào trong danh sách');
        return BookingOrderList(
          orders: [],
          channelToken: channelToken,
          bookingDate: bookingDate,
          totalItems: totalItems,
        );
      }

      final orders =
          items
              .map((item) {
                try {
                  return BookingOrder.fromMap(item as Map<String, dynamic>);
                } catch (e) {
                  log.log('Lỗi chuyển đổi đơn đặt sân: $e');
                  return null;
                }
              })
              .whereType<BookingOrder>()
              .toList();

      // log.log('Đã xử lý ${orders.length} đơn đặt sân');
      return BookingOrderList(
        orders: orders,
        channelToken: channelToken,
        bookingDate: bookingDate,
        totalItems: totalItems,
      );
    } catch (e) {
      log.log('Lỗi xử lý dữ liệu API đặt sân: $e');
      return BookingOrderList(
        orders: [],
        channelToken: channelToken,
        bookingDate: bookingDate,
      );
    }
  }

  // Lưu danh sách vào SharedPreferences
  Future<bool> saveOrderListData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Lưu toàn bộ dữ liệu dưới dạng JSON
      final key = _getOrderStorageKey(channelToken, bookingDate);
      final jsonString = json.encode(toJson());
      await prefs.setString(key, jsonString);

      // log.log(
      //   'BookingOrderList đã lưu thành công cho channel: $channelToken, ngày: ${bookingDate.toIso8601String()}',
      // );
      return true;
    } catch (e) {
      log.log('Lỗi khi lưu BookingOrderList: $e');
      return false;
    }
  }

  // Lấy danh sách từ SharedPreferences
  static Future<BookingOrderList> getFromStorage({
    required String channelToken,
    required DateTime bookingDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getOrderStorageKey(channelToken, bookingDate);
      final jsonString = prefs.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return BookingOrderList(
          orders: [],
          channelToken: channelToken,
          bookingDate: bookingDate,
        );
      }

      // Decode JSON
      final Map<String, dynamic> map = json.decode(jsonString);

      // Parse orders list
      final List<dynamic> ordersList = map['orders'] ?? [];
      final List<BookingOrder> orders =
          ordersList.map((item) {
            final Map<String, dynamic> orderMap = Map<String, dynamic>.from(
              item,
            );

            return BookingOrder(
              customerName: orderMap['customerName'] ?? '',
              courtName: orderMap['courtName'] ?? '',
              time: orderMap['time'] ?? '',
              type: orderMap['type'] ?? '',
              status: orderMap['status'] ?? '',
              statusId: orderMap['statusId'] ?? '',
              paymentStatus: orderMap['paymentStatus'] ?? '',
              paymentStatusId: orderMap['paymentStatusId'] ?? '',
              phoneNumber: orderMap['phoneNumber'] ?? '',
              emailAddress: orderMap['emailAddress'] ?? '',
              totalPrice: orderMap['total_price'] ?? '',
              noteCustomer: orderMap['noteCustomer'] ?? '',
              code: orderMap['code'] ?? '',
              id: orderMap['id'] ?? '',
            );
          }).toList();

      // Parse other fields
      final DateTime lastUpdated =
          map['lastUpdated'] != null
              ? DateTime.parse(map['lastUpdated'])
              : DateTime.now();
      final int totalItems = map['totalItems'] ?? 0;

      return BookingOrderList(
        orders: orders,
        channelToken: channelToken,
        bookingDate: bookingDate,
        lastUpdated: lastUpdated,
        totalItems: totalItems,
      );
    } catch (e) {
      log.log('Lỗi khi lấy BookingOrderList từ storage: $e');
      return BookingOrderList(
        orders: [],
        channelToken: channelToken,
        bookingDate: bookingDate,
      );
    }
  }

  // Convert danh sách thành JSON
  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'channelToken': channelToken,
      'bookingDate': bookingDate.toIso8601String(),
      'totalItems': totalItems,
    };
  }

  // Kiểm tra xem dữ liệu có hết hạn chưa (quá 30 phút)
  bool isExpired() {
    final now = DateTime.now();
    return now.difference(lastUpdated).inMinutes >= 30;
  }

  // Clear cache for a specific channel and date
  static Future<bool> clearCache({
    required String channelToken,
    required DateTime bookingDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getOrderStorageKey(channelToken, bookingDate);
      await prefs.remove(key);
      // log.log(
      //   'Cache cleared for channel: $channelToken, date: ${bookingDate.toIso8601String()}',
      // );
      return true;
    } catch (e) {
      log.log('Error clearing cache: $e');
      return false;
    }
  }

  // Tạo key lưu trữ trong SharedPreferences dựa vào channelToken và ngày
  static String _getOrderStorageKey(String channelToken, DateTime date) {
    final dateString = '${date.year}-${date.month}-${date.day}';
    return 'BOOKING_ORDERS_${channelToken}_$dateString';
  }

  // Chuyển đổi sang định dạng mà bloc hiện tại đang sử dụng
  List<Map<String, String>> toSimpleMapList() {
    // log.log('\n=== CONVERTING BOOKING ORDER LIST TO SIMPLE MAP LIST ===');
    // log.log('Number of orders to convert: ${orders.length}');

    if (orders.isNotEmpty) {
      // log.log('First order before conversion:');
      // log.log('  noteCustomer: "${orders[0].noteCustomer}"');
      // log.log('  code: "${orders[0].code}"');
      // log.log('  id: "${orders[0].id}"');
    }

    final result = orders.map((order) => order.toJson()).toList();

    if (result.isNotEmpty) {
      // log.log('First order after conversion:');
      // log.log('  noteCustomer: "${result[0]['noteCustomer']}"');
      // log.log('  code: "${result[0]['code']}"');
      // log.log('  id: "${result[0]['id']}"');
    }

    return result;
  }
}

class BookingList {
  final List<Map<String, dynamic>> courts;
  final DateTime lastUpdated;
  final String? channelToken;

  BookingList({required this.courts, DateTime? lastUpdated, this.channelToken})
    : lastUpdated = lastUpdated ?? DateTime.now();

  // Tạo danh sách từ API response
  factory BookingList.fromMapList(
    List<Map<String, dynamic>> maps, {
    String? channelToken,
  }) {
    return BookingList(
      courts:
          maps, // Sử dụng trực tiếp List<Map<String, dynamic>> thay vì chuyển đổi qua Court
      lastUpdated: DateTime.now(),
      channelToken: channelToken,
    );
  }

  // Lọc danh sách dựa trên khoảng ngày
  BookingList filterByDateRange(List<DateTime> dates) {
    if (dates.isEmpty) {
      return this; // Trả về danh sách hiện tại nếu không có ngày nào được chọn
    }

    // Chuẩn hóa các ngày được chọn để chỉ bao gồm năm-tháng-ngày
    final normalizedDates =
        dates
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet()
            .toList();

    // Lọc danh sách sân theo ngày
    final filteredCourts =
        courts.where((court) {
          // Lấy thông tin ngày từ sân (giả sử có trường "booking_date" hoặc tương tự)
          if (court.containsKey('booking_date')) {
            try {
              final bookingDateStr = court['booking_date'] as String?;
              if (bookingDateStr == null || bookingDateStr.isEmpty) {
                return false;
              }

              final bookingDate = DateTime.parse(bookingDateStr);
              final normalizedBookingDate = DateTime(
                bookingDate.year,
                bookingDate.month,
                bookingDate.day,
              );

              // Kiểm tra xem ngày của sân có nằm trong các ngày được chọn không
              return normalizedDates.any(
                (date) =>
                    date.year == normalizedBookingDate.year &&
                    date.month == normalizedBookingDate.month &&
                    date.day == normalizedBookingDate.day,
              );
            } catch (e) {
              log.log('Lỗi khi phân tích ngày đặt sân: $e');
              return false;
            }
          }
          return false;
        }).toList();

    return BookingList(
      courts: filteredCourts,
      lastUpdated: DateTime.now(),
      channelToken: channelToken,
    );
  }

  // Convert danh sách thành JSON
  Map<String, dynamic> toJson() {
    return {
      'courts':
          courts, // Sử dụng trực tiếp courts vì đã là List<Map<String, dynamic>>
      'lastUpdated': lastUpdated.toIso8601String(),
      'channelToken': channelToken,
    };
  }

  // Tạo danh sách rỗng
  factory BookingList.empty({String? channelToken}) {
    return BookingList(courts: [], channelToken: channelToken);
  }

  // Lưu danh sách vào SharedPreferences
  Future<bool> saveListData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Lưu toàn bộ dữ liệu dưới dạng JSON
      final key = _getStorageKey(channelToken);
      final jsonString = json.encode(toJson());
      await prefs.setString(key, jsonString);

      log.log(
        'BookingList data saved successfully for channel: ${channelToken ?? "default"}',
      );
      return true;
    } catch (e) {
      log.log('Error saving BookingList data: $e');
      return false;
    }
  }

  // Lấy danh sách từ SharedPreferences
  static Future<BookingList> getFromStorage({String? channelToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(channelToken);
      final jsonString = prefs.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return BookingList.empty();
      }

      // Decode JSON
      final Map<String, dynamic> map = json.decode(jsonString);

      // Parse courts list - giữ nguyên Map<String, dynamic> thay vì chuyển đổi qua Court
      final List<dynamic> courtsList = map['courts'] ?? [];
      final List<Map<String, dynamic>> courts =
          courtsList.map((item) => item as Map<String, dynamic>).toList();

      return BookingList(
        courts: courts,
        lastUpdated:
            map['lastUpdated'] != null
                ? DateTime.parse(map['lastUpdated'])
                : DateTime.now(),
        channelToken: channelToken,
      );
    } catch (e) {
      log.log('Error retrieving BookingList data: $e');
      return BookingList.empty();
    }
  }

  // Kiểm tra xem dữ liệu có hết hạn chưa (quá 1 giờ)
  bool isExpired() {
    final now = DateTime.now();
    return now.difference(lastUpdated).inHours >= 1;
  }

  // Tạo key lưu trữ trong SharedPreferences dựa vào channelToken
  static String _getStorageKey(String? channelToken) {
    return 'BOOKING_LIST_${channelToken ?? "default"}';
  }
}
