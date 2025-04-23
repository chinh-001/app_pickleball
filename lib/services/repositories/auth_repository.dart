import '../interfaces/i_auth_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../../utils/auth_helper.dart';

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

      // Kiểm tra đăng nhập thành công
      final successful = loginData['id'] != null;
      if (successful) {
        // Lưu trạng thái đăng nhập
        await AuthHelper.saveUserLoggedInStatus(true);
        
        // Lưu thông tin người dùng nếu có
        final id = loginData['id']?.toString() ?? '';
        final identifier = loginData['identifier']?.toString() ?? '';
        
        if (id.isNotEmpty) {
          // Tạo token từ ID và identifier
          final token = '$id:$identifier';
          await AuthHelper.saveUserToken(token);
          
          // Lưu tên người dùng nếu có thông tin
          if (identifier.isNotEmpty) {
            await AuthHelper.saveUserName(identifier);
          }
          
          // Cập nhật token trong ApiClient để sử dụng cho các request tiếp theo
          _apiClient.setAuthToken(token);
        }
        
        log.log('Đăng nhập thành công và đã lưu trạng thái');
      }
      
      return successful;
    } catch (e) {
      log.log('Login error: $e');
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // Xóa token trong ApiClient
      await _apiClient.clearAuth();
      
      // Xóa tất cả dữ liệu đăng nhập đã lưu
      await AuthHelper.clearUserData();
      
      log.log('Đăng xuất thành công và đã xóa trạng thái');
      return true;
    } catch (e) {
      log.log('Logout error: $e');
      return false;
    }
  }

  @override
  Future<String> getToken() async {
    // Lấy token đã lưu từ SharedPreferences
    return await AuthHelper.getUserToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    // Kiểm tra trạng thái đăng nhập từ SharedPreferences
    final loggedIn = await AuthHelper.getUserLoggedInStatus();
    
    // Double-check: nếu loggedIn = true nhưng token không tồn tại thì vẫn coi là chưa đăng nhập
    if (loggedIn) {
      final token = await AuthHelper.getUserToken();
      if (token.isEmpty) {
        // Token không tồn tại, cập nhật lại trạng thái
        await AuthHelper.saveUserLoggedInStatus(false);
        return false;
      }
      return true;
    }
    
    return false;
  }
}
