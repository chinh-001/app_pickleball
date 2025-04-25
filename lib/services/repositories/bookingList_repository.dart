import 'package:app_pickleball/services/interfaces/i_bookingList_service.dart';
import 'package:app_pickleball/services/api/api_client.dart';
import 'dart:developer' as log;
import 'dart:convert';
import 'package:app_pickleball/model/bookingList_model.dart';

class BookingListRepository implements IBookingListService {
  final ApiClient _apiClient;

  BookingListRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<Map<String, dynamic>> getAllBookingsRaw({
    required String channelToken,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      final query = '''
        query GetAllBooking {
          getAllBooking(
            options: {
              filter: {
                booking_date: {
                  between: {
                    start: "${startOfDay.toIso8601String()}"
                    end: "${endOfDay.toIso8601String()}"
                  }
                }
              }
            }
          ) {
            totalItems
            items {
              booking_date
              start_time
              end_time
              total_price
              type
              payment_method
              customer {
                firstName
                lastName
                phoneNumber
                emailAddress
              }
              court {
                name
              }
              paymentstatus {
                name
              }
              status {
                name
              }
            }
          }
        }
      ''';

      log.log('\n***** BOOKING LIST REPOSITORY: getAllBookingsRaw *****');
      log.log('Channel Token: $channelToken');
      log.log('Date: $date');
      log.log('Query: $query');

      final response = await _apiClient.query(
        query,
        variables: {},
        channelToken: channelToken,
      );

      if (response == null) {
        throw Exception('Failed to get booking list');
      }

      // Log detailed response
      log.log('\n=== API RESPONSE DETAILS ===');
      log.log('Raw Response: ${json.encode(response)}');

      if (response['data'] != null) {
        final data = response['data'];
        log.log('\nTotal Items: ${data['getAllBooking']?['totalItems']}');

        final items = data['getAllBooking']?['items'] as List?;
        if (items != null) {
          log.log('\nBooking Items: found ${items.length} items');
          for (var i = 0; i < items.length; i++) {
            final item = items[i];
            log.log('Booking #${i + 1} type: ${item['type']}');
          }
        }
      }

      log.log('\n=== END API RESPONSE DETAILS ===');
      log.log('***** END BOOKING LIST REPOSITORY *****\n');

      return response;
    } catch (e) {
      log.log('Error in getAllBookingsRaw: $e');
      rethrow;
    }
  }

  @override
  Future<BookingOrderList> getAllBookings({
    required String channelToken,
    required DateTime date,
  }) async {
    try {
      log.log('\n***** BOOKING LIST REPOSITORY: getAllBookings *****');

      // Kiểm tra xem có dữ liệu đã lưu trong storage không và có còn hiệu lực
      final storedData = await BookingOrderList.getFromStorage(
        channelToken: channelToken,
        bookingDate: date,
      );

      // Nếu có dữ liệu đã lưu và chưa hết hạn, trả về dữ liệu đó
      if (storedData.orders.isNotEmpty && !storedData.isExpired()) {
        log.log(
          'Sử dụng dữ liệu đặt sân đã lưu từ storage cho channel: $channelToken, ngày: ${date.toIso8601String()}',
        );
        log.log('Số lượng đơn đặt sân: ${storedData.orders.length}');
        return storedData;
      }

      // Nếu không có dữ liệu hoặc dữ liệu đã hết hạn, gọi API
      log.log('Không có dữ liệu trong cache hoặc đã hết hạn, gọi API mới');
      final response = await getAllBookingsRaw(
        channelToken: channelToken,
        date: date,
      );

      // Chuyển đổi response thành BookingOrderList
      final bookingOrderList = BookingOrderList.fromApiResponse(
        response,
        channelToken: channelToken,
        bookingDate: date,
      );

      // Lưu dữ liệu vào storage
      await bookingOrderList.saveOrderListData();

      log.log('Đã xử lý và lưu ${bookingOrderList.orders.length} đơn đặt sân');
      log.log('***** END BOOKING LIST REPOSITORY *****\n');

      return bookingOrderList;
    } catch (e) {
      log.log('Error in getAllBookings: $e');

      // Nếu có lỗi, thử lấy dữ liệu từ storage (kể cả đã hết hạn)
      try {
        final storedData = await BookingOrderList.getFromStorage(
          channelToken: channelToken,
          bookingDate: date,
        );

        if (storedData.orders.isNotEmpty) {
          log.log('Sử dụng dữ liệu dự phòng từ storage do lỗi API');
          return storedData;
        }
      } catch (storageError) {
        log.log('Lỗi khi lấy dữ liệu dự phòng: $storageError');
      }

      // Nếu không có dữ liệu dự phòng, trả về danh sách trống
      return BookingOrderList(
        orders: [],
        channelToken: channelToken,
        bookingDate: date,
      );
    }
  }
}
