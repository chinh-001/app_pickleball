import '../interfaces/i_booking_service.dart';
import '../api/api_client.dart';

class BookingRepository implements IBookingService {
  final ApiClient _apiClient;

  BookingRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<Map<String, dynamic>> getBookingStats() async {
    try {
      // Lấy ngày hiện tại
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      // Format datetime theo định dạng ISO 8601 với 'Z' để chỉ định UTC
      final startDateStr = startOfDay.toUtc().toIso8601String();
      final endDateStr = endOfDay.toUtc().toIso8601String();

      print('Start date: $startDateStr');
      print('End date: $endDateStr');

      const query = '''
        query GetBookingStats(\$startDate: DateTime!, \$endDate: DateTime!) {
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
              ? revenueData[0]['revenue'] ?? 0.0
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
}
