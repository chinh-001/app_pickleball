import '../interfaces/i_administrator_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../../model/userInfo_model.dart';

class AdministratorRepository implements IAdministratorService {
  final ApiClient _apiClient;

  AdministratorRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<Map<String, dynamic>> getActiveAdministratorRaw() async {
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

      final response = await _apiClient.query<Map<String, dynamic>>(
        query,
        converter: (json) => json,
      );
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

  @override
  Future<UserInfo> getActiveAdministrator() async {
    try {
      log.log('Fetching active administrator using UserInfo model');

      // Kiểm tra cache
      final cachedInfo = await UserInfo.loadFromStorage();
      if (cachedInfo.name.isNotEmpty &&
          cachedInfo.email.isNotEmpty &&
          !cachedInfo.isExpired()) {
        log.log(
          'Returning cached user info: ${cachedInfo.name}, ${cachedInfo.email}',
        );
        return cachedInfo;
      }

      // Lấy dữ liệu thô từ repository
      final rawData = await getActiveAdministratorRaw();

      if (rawData.isEmpty) {
        log.log('No data returned from API');
        return UserInfo.empty();
      }

      // Tạo model từ dữ liệu API
      final userInfo = UserInfo.fromMap(rawData);

      // Lưu vào storage
      await userInfo.saveUserInfo();

      log.log(
        'UserInfo created and saved: ${userInfo.name}, ${userInfo.email}',
      );
      return userInfo;
    } catch (e) {
      log.log('Error creating UserInfo: $e');

      // Nếu có lỗi, thử dùng dữ liệu đã lưu (kể cả đã hết hạn)
      try {
        final cachedInfo = await UserInfo.loadFromStorage();
        if (cachedInfo.name.isNotEmpty || cachedInfo.email.isNotEmpty) {
          log.log('Using expired cached data due to error');
          return cachedInfo;
        }
      } catch (storageError) {
        log.log('Error loading from storage: $storageError');
      }

      return UserInfo.empty();
    }
  }
}
