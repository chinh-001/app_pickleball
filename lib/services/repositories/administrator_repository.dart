import '../interfaces/i_administrator_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;

class AdministratorRepository implements IAdministratorService {
  final ApiClient _apiClient;

  AdministratorRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<Map<String, dynamic>> getActiveAdministrator() async {
    try {
      const query = '''
        query ActiveAdministrator {
          activeAdministrator {
            firstName
            lastName
            emailAddress
          }
        }
      ''';

      final response = await _apiClient.query(query);
      if (response == null) {
        log.log('ActiveAdministrator response is null');
        return {};
      }

      final data = response['data'];
      if (data == null) {
        log.log('ActiveAdministrator data is null');
        return {};
      }

      final administrator = data['activeAdministrator'];
      if (administrator == null) {
        log.log('ActiveAdministrator object is null');
        return {};
      }

      // Format the administrator data
      final formattedData = {
        'name': '${administrator['firstName']} ${administrator['lastName']}',
        'email': administrator['emailAddress'],
      };

      log.log('Successfully fetched administrator data: $formattedData');
      return formattedData;
    } catch (e) {
      log.log('Cannot fetch active administrator: $e');
      return {};
    }
  }
}
