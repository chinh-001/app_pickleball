import '../../models/multiple_bookings_model.dart';

abstract class IMultipleBookingsService {
  Future<MultipleBookingsResponse> createMultipleBookings({
    required String channelToken,
    required MultipleBookingsInput input,
  });
}
