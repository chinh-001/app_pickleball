import '../interfaces/i_auth_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;

class AuthRepository implements IAuthService {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.query(
        'mutation Login(\$username: String!, \$password: String!) { login(username: \$username, password: \$password) { ... on CurrentUser { id identifier } } }',
        variables: {'username': username, 'password': password},
      );

      if (response == null) {
        log.log('Login response is null');
        return false;
      }

      final data = response['data'];
      if (data == null) {
        log.log('Login data is null');
        return false;
      }

      final loginData = data['login'];
      if (loginData == null) {
        log.log('Login result is null');
        return false;
      }

      return loginData['id'] != null;
    } catch (e) {
      log.log('Login error: $e');
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _apiClient.clearAuth();
      return true;
    } catch (e) {
      log.log('Logout error: $e');
      return false;
    }
  }

  @override
  Future<String> getToken() async {
    // Implementation for getting stored token
    return '';
  }
}
