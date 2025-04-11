abstract class IBookingService {
  Future<Map<String, dynamic>> getBookingStats({String? channelToken});
}
