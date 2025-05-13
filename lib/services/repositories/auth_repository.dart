import '../interfaces/i_auth_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../../utils/auth_helper.dart';
import '../../models/userAccount_model.dart';
// import '../../model/userPermissions_model.dart';
import '../repositories/userPermissions_repository.dart';

class AuthRepository implements IAuthService {
  final ApiClient _apiClient;
  final UserPermissionsRepository _permissionsRepository;

  AuthRepository({
    ApiClient? apiClient,
    UserPermissionsRepository? permissionsRepository,
  }) : _apiClient = apiClient ?? ApiClient.instance,
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository();

  @override
  Future<UserAccount?> login(String username, String password) async {
    try {
      final response = await _apiClient.query<Map<String, dynamic>>(
        'mutation Login(\$username: String!, \$password: String!) { login(username: \$username, password: \$password) { ... on CurrentUser { id identifier } } }',
        variables: {'username': username, 'password': password},
        converter: (json) => json,
      );

      if (response == null) {
        log.log('Login response is null');
        return null;
      }

      final data = response['data'];
      if (data == null) {
        log.log('Login data is null');
        return null;
      }

      final loginData = data['login'];
      if (loginData == null) {
        log.log('Login result is null');
        return null;
      }

      // Check if login was successful
      if (loginData['id'] != null) {
        // Create user model from response
        final user = UserAccount.fromMap(loginData);

        // User model sẽ tự xử lý lưu dữ liệu đăng nhập
        final saved = await user.saveLoginData();
        if (!saved) {
          log.log('User data không được lưu thành công');
        }

        log.log('Đăng nhập thành công và đã lưu thông tin người dùng');

        // Sau khi đăng nhập thành công, thực hiện truy vấn "query Me" bằng UserPermissionsRepository
        await _permissionsRepository.fetchUserPermissionsAfterLogin();

        return user;
      }

      return null;
    } catch (e) {
      log.log('Lỗi đăng nhập: $e');
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // Đánh dấu cần reset các bloc trước khi xóa dữ liệu
      AuthHelper.markBlocsForReset();

      // Xóa token trong ApiClient
      await _apiClient.clearAuth();

      // Xóa tất cả dữ liệu đăng nhập đã lưu (đã bao gồm xóa dữ liệu quyền hạn)
      await AuthHelper.clearUserData();

      // Make sure we completely clear any cached permissions data
      await AuthHelper.clearUserPermissionsData();

      log.log('Đăng xuất thành công và đã xóa trạng thái');
      return true;
    } catch (e) {
      log.log('Lỗi đăng xuất: $e');
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
