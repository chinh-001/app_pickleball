abstract class IBookingListService {
  Future<Map<String, dynamic>> getAllBookings({
    required String channelToken,
    required DateTime date,
  });
}
