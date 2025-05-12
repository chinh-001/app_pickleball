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
                id
              }
              status {
                name
                id
              }
              noteCustomer
              id
              code
            }
          }
        }
      ''';

      // Only log the channel being requested, not the query itself
      // log.log(
      //   '\n***** BOOKING LIST REPOSITORY: Getting data for channel: $channelToken *****',
      // );

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
        // final data = response['data'];
        // final totalItems = data['getAllBooking']['totalItems'];
        // final items = data['getAllBooking']['items'] as List;

        // log.log('\n===== BOOKING ITEMS SUMMARY =====');
        // log.log('Total items found: $totalItems');
        // log.log('Number of items retrieved: ${items.length}\n');

        // for (var i = 0; i < items.length; i++) {
        //   final item = items[i];
        //   final customer = item['customer'] as Map<String, dynamic>;
        //   final court = item['court'] as Map<String, dynamic>;
        //   final status = item['status'] as Map<String, dynamic>;
        //   final paymentStatus = item['paymentstatus'] as Map<String, dynamic>;

        //   log.log('BOOKING #${i + 1}:');
        //   log.log('ID: ${item['id']}');
        //   log.log('Code: ${item['code']}');
        //   log.log('Customer: ${customer['firstName']} ${customer['lastName']}');
        //   log.log('Phone: ${customer['phoneNumber']}');
        //   log.log('Court: ${court['name']}');
        //   log.log('Time: ${item['start_time']} - ${item['end_time']}');
        //   log.log('Type: ${item['type']}');
        //   log.log('Status: ${status['name']} (ID: ${status['id']})');
        //   log.log(
        //     'Payment Status: ${paymentStatus['name']} (ID: ${paymentStatus['id']})',
        //   );
        //   log.log('Total Price: ${item['total_price']}');
        //   log.log('Note: ${item['noteCustomer']}');
        //   log.log('-----------------------------------\n');
        // }
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
      log.log('\n***** BOOKING LIST REPOSITORY: getAllBookings *****');

      // Clear the cache before fetching new data to prevent stale data issues
      await BookingOrderList.clearCache(
        channelToken: channelToken,
        bookingDate: date,
      );

      // Get fresh data from the API
      log.log('Fetching fresh data from API');
      final response = await getAllBookingsRaw(
        channelToken: channelToken,
        date: date,
      );

      // Convert response to BookingOrderList
      final bookingOrderList = BookingOrderList.fromApiResponse(
        response,
        channelToken: channelToken,
        bookingDate: date,
      );

      // Save data to storage
      await bookingOrderList.saveOrderListData();

      log.log(
        'Processed and saved ${bookingOrderList.orders.length} booking orders',
      );
      log.log('***** END BOOKING LIST REPOSITORY *****\n');

      return bookingOrderList;
    } catch (e) {
      log.log('Error in getAllBookings: $e');

      // If error, try to get data from storage (even if expired)
      try {
        final storedData = await BookingOrderList.getFromStorage(
          channelToken: channelToken,
          bookingDate: date,
        );

        if (storedData.orders.isNotEmpty) {
          log.log('Using fallback data from storage due to API error');
          return storedData;
        }
      } catch (storageError) {
        log.log('Error fetching fallback data: $storageError');
      }

      // If no fallback data, return empty list
      return BookingOrderList(
        orders: [],
        channelToken: channelToken,
        bookingDate: date,
      );
    }
  }
}
