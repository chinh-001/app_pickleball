import 'dart:io';
import '../../models/available_cour_for_booking_model.dart';
import '../interfaces/i_available_cour_for_booking_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;

class AvailableCourForBookingRepository
    implements IAvailableCourForBookingService {
  final ApiClient _apiClient;

  AvailableCourForBookingRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<List<AvailableCourForBookingModel>> getAvailableCourForBooking(
    AvailableCourInputModel input,
  ) async {
    try {
      const query = '''
        query GetAvailableCourtForBooking(
          \$bookingDates: [String!]!,
          \$start_time: String!,
          \$end_time: String!,
          \$productId: String!,
          \$quantityCourt: Int!
        ) {
          getAvailableCourtForBooking(
            input: {
              bookingDates: \$bookingDates,
              start_time: \$start_time,
              end_time: \$end_time,
              productId: \$productId,
              quantityCourt: \$quantityCourt
            }
          ) {
            bookingDate
            courts {
              id
              name
              status
              price
              start_time
              end_time
            }
          }
        }
      ''';

      final variables = {
        'bookingDates': input.bookingDates,
        'start_time': input.startTime,
        'end_time': input.endTime,
        'productId': input.productId,
        'quantityCourt': input.quantityCourt,
      };

      final jsonResponse = await _apiClient.query<List<dynamic>>(
        query,
        variables: variables,
        converter: (json) {
          final data = json['data']?['getAvailableCourtForBooking'];
          if (data == null) return [];
          return data as List<dynamic>;
        },
      );

      if (jsonResponse == null) {
        log.log('Response is null');
        return [];
      }

      return jsonResponse
          .map((item) => AvailableCourForBookingModel.fromJson(item))
          .toList();
    } on SocketException catch (_) {
      throw Exception('No Internet connection');
    } catch (e) {
      log.log('Error fetching available courts: $e');
      throw Exception('Failed to get available courts: ${e.toString()}');
    }
  }
}
