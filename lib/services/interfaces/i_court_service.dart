abstract class ICourtService {
  Future<List<Map<String, dynamic>>> getCourts();
  Future<Map<String, dynamic>> getCourtById(String id);
  Future<bool> bookCourt(Map<String, dynamic> bookingData);
}