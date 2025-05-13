import '../../models/bookingList_model.dart';

abstract class IBookingListService {
  Future<Map<String, dynamic>> getAllBookingsRaw({
    required String channelToken,
    required DateTime date,
  });

  Future<BookingOrderList> getAllBookings({
    required String channelToken,
    required DateTime date,
  });
}
