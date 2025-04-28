import '../interfaces/i_booking_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../../model/bookingStatus_model.dart';
import '../../model/bookingList_model.dart';

class BookingRepository implements IBookingService {
  final ApiClient _apiClient;

  BookingRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  String getChannelToken(String channelName) {
    if (channelName == 'Demo-channel') {
      return 'demo-channel';
    } else if (channelName == 'Pikachu Pickleball Xuân Hoà') {
      return 'pikachu';
    }
    return 'demo-channel';
  }

  @override
  Future<BookingList> getCourtItems({String? channelToken}) async {
    try {
      log.log('\n===== BOOKING REPOSITORY: getCourtItems =====');

      // Thử lấy dữ liệu đã lưu từ storage
      final storedList = await BookingList.getFromStorage(
        channelToken: channelToken,
      );

      // Nếu có dữ liệu và chưa hết hạn, sử dụng dữ liệu đã lưu
      if (storedList.courts.isNotEmpty && !storedList.isExpired()) {
        log.log(
          'Using stored court data for channel: ${channelToken ?? "default"}',
        );
        return storedList;
      }

      // Nếu không có dữ liệu hoặc dữ liệu đã hết hạn, gọi API
      const query = '''
        query GetCourts {
          GetCourts {
            id
            name
            status
            price
            star
          }
        }
      ''';

      final response = await _apiClient.query<Map<String, dynamic>>(
        query,
        channelToken: channelToken ?? 'demo-channel',
        converter: (json) => json,
      );

      if (response == null || response['data'] == null) {
        return BookingList.empty();
      }

      final courts = response['data']['GetCourts'] as List?;
      if (courts == null) {
        return BookingList.empty();
      }

      final courtsData =
          courts
              .map(
                (court) => {
                  'id': court['id'].toString(),
                  'name': court['name'] ?? 'Unknown Court',
                  'status': court['status'] ?? 'available',
                  'price': '${court['price'] ?? '0'}đ/giờ',
                  'star': court['star']?.toString() ?? '0',
                },
              )
              .toList();

      // Tạo BookingList từ dữ liệu API và lưu vào storage
      final bookingList = BookingList.fromMapList(
        courtsData,
        channelToken: channelToken,
      );
      await bookingList.saveListData();

      log.log(
        'Fetched and saved ${courtsData.length} courts for channel: ${channelToken ?? "default"}',
      );
      return bookingList;
    } catch (e) {
      log.log('Error fetching court items: $e');

      // Nếu có lỗi, thử lấy dữ liệu đã lưu từ storage
      return await BookingList.getFromStorage(channelToken: channelToken);
    }
  }

  @override
  Future<BookingStatus> getBookingStats({String? channelToken}) async {
    try {
      log.log('\n===== BOOKING REPOSITORY: getBookingStats =====');
      log.log('Starting request with channel token: $channelToken');

      // Lấy ngày hiện tại
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      // Chuyển đổi ngày thành định dạng YYYY-MM-DD (chuẩn cho Date)
      final startDateStr =
          '${startOfDay.year}-${startOfDay.month.toString().padLeft(2, '0')}-${startOfDay.day.toString().padLeft(2, '0')}';
      final endDateStr =
          '${endOfDay.year}-${endOfDay.month.toString().padLeft(2, '0')}-${endOfDay.day.toString().padLeft(2, '0')}';

      log.log('Date range: $startDateStr to $endDateStr');

      const query = '''
        query GetBookingStats(\$startDate: Date!, \$endDate: Date!) {
          getBookingExpectedRevenue(
            options: {
              filter: {
                booking_date: {
                  between: {
                    start: \$startDate
                    end: \$endDate
                  }
                }
              }
            }
          ) {
            revenueDate
            revenue
          }
          GetTotalBooking(
            options: {
              filter: {
                booking_date: {
                  between: {
                    start: \$startDate
                    end: \$endDate
                  }
                }
              }
            }
          ) {
            totalItems
          }
        }
      ''';

      final response = await _apiClient.query<Map<String, dynamic>>(
        query,
        variables: {'startDate': startDateStr, 'endDate': endDateStr},
        channelToken: channelToken ?? 'demo-channel',
        converter: (json) => json,
      );

      if (response == null) {
        log.log('Response is null');
        return _getOrCreateBookingStatus({
          'totalBookings': 0,
          'totalRevenue': 0.0,
        }, channelToken: channelToken);
      }

      final data = response['data'];
      if (data == null) {
        log.log('Data is null');
        return _getOrCreateBookingStatus({
          'totalBookings': 0,
          'totalRevenue': 0.0,
        }, channelToken: channelToken);
      }

      // Lấy doanh thu từ getBookingExpectedRevenue
      final revenueData = data['getBookingExpectedRevenue'];
      final revenue =
          revenueData != null && revenueData is List && revenueData.isNotEmpty
              ? _parseDouble(revenueData[0]['revenue'])
              : 0.0;

      // Lấy tổng số đơn từ GetTotalBooking
      final totalBookingData = data['GetTotalBooking'];
      final totalBookings =
          totalBookingData != null ? totalBookingData['totalItems'] ?? 0 : 0;

      log.log('Result: Revenue = $revenue, Total bookings = $totalBookings');
      log.log('===== END BOOKING REPOSITORY =====\n');

      final bookingData = {
        'totalBookings': totalBookings,
        'totalRevenue': revenue,
      };

      // Tạo đối tượng BookingStatus và lưu vào storage
      return _getOrCreateBookingStatus(bookingData, channelToken: channelToken);
    } catch (e) {
      log.log('Error fetching booking stats: $e');
      log.log('===== END BOOKING REPOSITORY WITH ERROR =====\n');

      // Nếu có lỗi, thử lấy dữ liệu đã lưu từ storage
      return await _getStoredBookingStatus(channelToken: channelToken);
    }
  }

  // Lấy BookingStatus từ dữ liệu API hoặc tạo mới
  Future<BookingStatus> _getOrCreateBookingStatus(
    Map<String, dynamic> data, {
    String? channelToken,
  }) async {
    // Tạo đối tượng BookingStatus từ dữ liệu API
    final bookingStatus = BookingStatus.fromMap(
      data,
      channelToken: channelToken,
    );

    // Lưu vào storage
    await bookingStatus.saveBookingData();

    return bookingStatus;
  }

  // Lấy dữ liệu BookingStatus đã lưu từ storage
  Future<BookingStatus> _getStoredBookingStatus({String? channelToken}) async {
    return await BookingStatus.getFromStorage(channelToken: channelToken);
  }

  // Hàm hỗ trợ chuyển đổi giá trị sang double
  double _parseDouble(dynamic value) {
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
}
