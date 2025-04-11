import '../interfaces/i_booking_service.dart';
import '../api/api_client.dart';

class BookingRepository implements IBookingService {
  final ApiClient _apiClient;

  BookingRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<Map<String, dynamic>> getBookingStats({String? channelToken}) async {
    try {
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

      print('Start date: $startDateStr');
      print('End date: $endDateStr');
      print('Channel token in repository: $channelToken');

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

      final response = await _apiClient.query(
        query,
        variables: {'startDate': startDateStr, 'endDate': endDateStr},
        channelToken: channelToken ?? 'demo-channel',
      );

      if (response == null) {
        print('Response is null');
        return {'totalBookings': 0, 'totalRevenue': 0.0};
      }

      final data = response['data'];
      if (data == null) {
        print('Data is null');
        return {'totalBookings': 0, 'totalRevenue': 0.0};
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

      print('Revenue: $revenue');
      print('Total bookings: $totalBookings');

      return {'totalBookings': totalBookings, 'totalRevenue': revenue};
    } catch (e) {
      print('Error fetching booking stats: $e');
      return {'totalBookings': 0, 'totalRevenue': 0.0};
    }
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
        print('Error parsing string to double: $value');
        return 0.0;
      }
    }
    return 0.0;
  }
}
