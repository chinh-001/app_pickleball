import '../interfaces/i_court_service.dart';
import '../api/api_client.dart';

class CourtRepository implements ICourtService {
  final ApiClient _apiClient;

  CourtRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<List<Map<String, dynamic>>> getCourts() async {
    try {
      const query = '''
        query Courts {
          courts {
            items {
              id
              name
              status
              price
              image
            }
          }
        }
      ''';

      final response = await _apiClient.query(query);
      if (response == null) {
        print('Courts response is null');
        return [];
      }

      final data = response['data'];
      if (data == null) {
        print('Courts data is null');
        return [];
      }

      final courts = data['courts'];
      if (courts == null) {
        print('Courts object is null');
        return [];
      }

      final items = courts['items'];
      if (items == null) {
        print('Courts items is null');
        return [];
      }

      if (items is! List) {
        print('Courts items is not a List');
        return [];
      }

      return items.map((court) {
        if (court == null) return <String, dynamic>{};
        return Map<String, dynamic>.from(court);
      }).toList();
    } catch (e) {
      print('Cannot fetch courts: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getCourtById(String id) async {
    try {
      const query = '''
        query Court(\$id: ID!) {
          court(id: \$id) {
            id
            name
            status
            price
            image
          }
        }
      ''';

      final response = await _apiClient.query(query, variables: {'id': id});
      if (response == null) {
        print('Court response is null');
        return {};
      }

      final data = response['data'];
      if (data == null) {
        print('Court data is null');
        return {};
      }

      final court = data['court'];
      if (court == null) {
        print('Court object is null');
        return {};
      }

      return Map<String, dynamic>.from(court);
    } catch (e) {
      print('Cannot fetch court: $e');
      return {};
    }
  }

  @override
  Future<bool> bookCourt(Map<String, dynamic> bookingData) async {
    try {
      const mutation = '''
        mutation BookCourt(\$input: BookCourtInput!) {
          bookCourt(input: \$input) {
            id
          }
        }
      ''';

      final response = await _apiClient.query(
        mutation,
        variables: {'input': bookingData},
      );

      if (response == null) {
        print('Booking response is null');
        return false;
      }

      final data = response['data'];
      if (data == null) {
        print('Booking data is null');
        return false;
      }

      final bookCourt = data['bookCourt'];
      if (bookCourt == null) {
        print('Booking result is null');
        return false;
      }

      return bookCourt['id'] != null;
    } catch (e) {
      print('Cannot book court: $e');
      return false;
    }
  }
}
