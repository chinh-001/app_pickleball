import 'package:app_pickleball/services/interfaces/i_bookingList_service.dart';
import 'package:app_pickleball/services/api/api_client.dart';
import 'dart:developer' as log;
import 'dart:convert';

class BookingListRepository implements IBookingListService {
  final ApiClient _apiClient;

  BookingListRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<Map<String, dynamic>> getAllBookings({
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
            }
          }
        }
      ''';

      log.log('\n***** BOOKING LIST REPOSITORY: getAllBookings *****');
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
          log.log('\nBooking Items:');
          for (var i = 0; i < items.length; i++) {
            final item = items[i];
            // log.log('\nBooking #${i + 1}:');
            // log.log('Date: ${item['booking_date']}');
            // log.log('Time: ${item['start_time']} - ${item['end_time']}');
            // log.log('Price: ${item['total_price']}');
            // log.log('Type: ${item['type']}');
            // log.log('Payment Method: ${item['payment_method']}');
            // log.log('Payment Status: ${item['paymentstatus']?['name']}');
            log.log('type ${item['type']}');
            final customer = item['customer'];
            // log.log('Customer:');
            // log.log('  Name: ${customer['firstName']} ${customer['lastName']}');
            // log.log('  Phone: ${customer['phoneNumber']}');
            // log.log('  Email: ${customer['emailAddress']}');

            // final court = item['court'];
            // log.log('Court: ${court['name']}');
          }
        }
      }

      log.log('\n=== END API RESPONSE DETAILS ===');
      log.log('***** END BOOKING LIST REPOSITORY *****\n');

      return response;
    } catch (e) {
      log.log('Error in getAllBookings: $e');
      rethrow;
    }
  }
}
