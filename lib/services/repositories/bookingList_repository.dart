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
              noteCustomer
              id
              code
            }
          }
        }
      ''';

      // Only log the channel being requested, not the query itself
      log.log(
        '\n***** BOOKING LIST REPOSITORY: Getting data for channel: $channelToken *****',
      );

      final response = await _apiClient.query<Map<String, dynamic>>(
        query,
        variables: {},
        channelToken: channelToken,
        converter: (json) => json,
      );

      if (response == null) {
        throw Exception('Failed to get booking list');
      }

      // Log the complete API response
      log.log('\n===== COMPLETE API RESPONSE FOR CHANNEL: $channelToken =====');
      log.log(json.encode(response));
      log.log('===== END COMPLETE API RESPONSE =====\n');

      // Also log a more user-friendly summary of the items
      if (response['data'] != null &&
          response['data']['getAllBooking'] != null &&
          response['data']['getAllBooking']['items'] != null) {
        final data = response['data'];
        final totalItems = data['getAllBooking']['totalItems'];
        final items = data['getAllBooking']['items'] as List;

        log.log('\n===== BOOKING ITEMS SUMMARY =====');
        log.log('Total items found: $totalItems');
        log.log('Number of items retrieved: ${items.length}\n');

        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final customer = item['customer'] as Map<String, dynamic>;
          final court = item['court'] as Map<String, dynamic>;
          final status = item['status'] as Map<String, dynamic>;
          final paymentStatus = item['paymentstatus'] as Map<String, dynamic>;

          log.log('BOOKING #${i + 1}:');
          log.log('ID: ${item['id']}');
          log.log('Code: ${item['code']}');
          log.log('Customer: ${customer['firstName']} ${customer['lastName']}');
          log.log('Phone: ${customer['phoneNumber']}');
          log.log('Court: ${court['name']}');
          log.log('Time: ${item['start_time']} - ${item['end_time']}');
          log.log('Type: ${item['type']}');
          log.log('Status: ${status['name']}');
          log.log('Payment Status: ${paymentStatus['name']}');
          log.log('Total Price: ${item['total_price']}');
          log.log('Note: ${item['noteCustomer']}');
          log.log('-----------------------------------\n');
        }
      }

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
      // log.log('\n***** BOOKING LIST REPOSITORY: getAllBookings *****');

      // Kiểm tra xem có dữ liệu đã lưu trong storage không và có còn hiệu lực
      final storedData = await BookingOrderList.getFromStorage(
        channelToken: channelToken,
        bookingDate: date,
      );

      // Nếu có dữ liệu đã lưu và chưa hết hạn, trả về dữ liệu đó
      if (storedData.orders.isNotEmpty && !storedData.isExpired()) {
        // log.log(
        //   'Sử dụng dữ liệu đặt sân đã lưu từ storage cho channel: $channelToken, ngày: ${date.toIso8601String()}',
        // );
        ('Số lượng đơn đặt sân: ${storedData.orders.length}');
        return storedData;
      }

      // Nếu không có dữ liệu hoặc dữ liệu đã hết hạn, gọi API
      // log.log('Không có dữ liệu trong cache hoặc đã hết hạn, gọi API mới');
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

      // log.log('Đã xử lý và lưu ${bookingOrderList.orders.length} đơn đặt sân');
      // log.log('***** END BOOKING LIST REPOSITORY *****\n');

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
          // log.log('Sử dụng dữ liệu dự phòng từ storage do lỗi API');
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
