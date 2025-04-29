import '../interfaces/i_auth_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../../utils/auth_helper.dart';
import '../../model/userAccount_model.dart';
import '../../model/userPermissions_model.dart';
import '../../utils/env_helper.dart';

class AuthRepository implements IAuthService {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

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

        // Sau khi đăng nhập thành công, thực hiện truy vấn "query Me"
        await _fetchUserPermissions();

        return user;
      }

      return null;
    } catch (e) {
      log.log('Lỗi đăng nhập: $e');
      return null;
    }
  }

  // Phương thức để thực hiện truy vấn "query Me" và log kết quả
  Future<void> _fetchUserPermissions() async {
    try {
      log.log(
        'Đang thực hiện truy vấn "query Me" sau khi đăng nhập thành công...',
      );

      final response = await _apiClient.query<Map<String, dynamic>>(
        '''
        query Me {
            me {
                id
                identifier
                channels {
                    id
                    token
                    code
                    permissions
                }
            }
        }
        ''',
        variables: {},
        converter: (json) => json,
      );

      if (response == null) {
        log.log('Kết quả truy vấn "query Me" trả về null');
        return;
      }

      // Log toàn bộ kết quả truy vấn "query Me" ra console
      log.log('Kết quả truy vấn "query Me": $response');

      final data = response['data'];
      if (data == null) {
        log.log('Dữ liệu từ truy vấn "query Me" là null');
        return;
      }

      final meData = data['me'];
      if (meData == null) {
        log.log('Dữ liệu "me" từ truy vấn là null');
        return;
      }

      // Chuyển đổi dữ liệu thành đối tượng UserPermissions để dễ sử dụng
      final permissions = UserPermissions.fromMap(meData);

      // Lưu kết quả vào bộ nhớ cục bộ thông qua AuthHelper
      await AuthHelper.saveUserPermissionsData(permissions.toJson());

      // Log thông tin chi tiết về quyền hạn của người dùng
      log.log(
        'Thông tin người dùng - ID: ${permissions.id}, Identifier: ${permissions.identifier}',
      );
      log.log('Số lượng channel: ${permissions.channels.length}');

      for (final channel in permissions.channels) {
        log.log('Channel - ID: ${channel.id}, Code: ${channel.code}');
        log.log('Permissions: ${channel.permissions.join(", ")}');
      }

      // So sánh với giá trị mặc định từ .env file
      final defaultPermissions = EnvHelper.getDefaultUserPermissions();
      log.log('So sánh với quyền hạn mặc định từ file .env:');
      log.log(
        'Channel mặc định từ .env: ${defaultPermissions.channels.map((c) => c.code).join(", ")}',
      );
    } catch (e) {
      log.log('Lỗi khi thực hiện truy vấn "query Me": $e');
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
