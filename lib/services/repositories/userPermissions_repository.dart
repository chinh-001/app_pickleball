import '../interfaces/i_userPermissions_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../../utils/auth_helper.dart';
import '../../model/userPermissions_model.dart';

class UserPermissionsRepository implements IUserPermissionsService {
  final ApiClient _apiClient;

  UserPermissionsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  Future<void> fetchUserPermissionsAfterLogin() async {
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

      // Lưu toàn bộ response vào SharedPreferences để các màn hình khác có thể sử dụng
      if (response.containsKey('data') && response['data'] != null) {
        if (response['data'].containsKey('me') &&
            response['data']['me'] != null) {
          // Lưu nguyên dữ liệu "me" vào SharedPreferences
          await AuthHelper.saveUserPermissionsData(response['data']['me']);
          log.log('Đã lưu dữ liệu "me" vào SharedPreferences');
        }
      }

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

      // Lưu permissions vào bộ nhớ cục bộ
      await saveUserPermissions(permissions);

      // Log thông tin chi tiết về quyền hạn của người dùng
      log.log(
        'Thông tin người dùng - ID: ${permissions.id}, Identifier: ${permissions.identifier}',
      );
      log.log('Số lượng channel: ${permissions.channels.length}');

      for (final channel in permissions.channels) {
        log.log('Channel - ID: ${channel.id}, Code: ${channel.code}');
        log.log('Permissions: ${channel.permissions.join(", ")}');
      }
    } catch (e) {
      log.log('Lỗi khi thực hiện truy vấn "query Me": $e');
    }
  }

  @override
  Future<UserPermissions?> getUserPermissions() async {
    try {
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
        log.log('User permissions response is null');
        return null;
      }

      final data = response['data'];
      if (data == null) {
        log.log('User permissions data is null');
        return null;
      }

      final meData = data['me'];
      if (meData == null) {
        log.log('User permissions me data is null');
        return null;
      }

      // Create permissions model from response
      final permissions = UserPermissions.fromMap(meData);

      // Save permissions data
      await saveUserPermissions(permissions);

      return permissions;
    } catch (e) {
      log.log('Get user permissions error: $e');
      return null;
    }
  }

  @override
  Future<bool> hasPermission(String permissionCode) async {
    final permissions = await getUserPermissions();
    if (permissions == null) {
      return false;
    }

    for (final channel in permissions.channels) {
      if (channel.permissions.contains(permissionCode)) {
        return true;
      }
    }

    return false;
  }

  @override
  Future<List<String>> getUserChannelCodes() async {
    final permissions = await getUserPermissions();
    if (permissions == null) {
      return [];
    }

    return permissions.channels.map((channel) => channel.code).toList();
  }

  @override
  Future<bool> saveUserPermissions(UserPermissions permissions) async {
    try {
      // Save permissions in local storage
      final permissionsJson = permissions.toJson();
      await AuthHelper.saveUserPermissionsData(permissionsJson);

      log.log('User permissions saved successfully');
      return true;
    } catch (e) {
      log.log('Error saving user permissions: $e');
      return false;
    }
  }

  // Phương thức mới để lấy danh sách channel của người dùng
  Future<List<String>> getAvailableChannels() async {
    try {
      final permissions = await getUserPermissions();
      if (permissions == null || permissions.channels.isEmpty) {
        log.log('Không có channel nào cho người dùng');
        return [];
      }

      // Lấy danh sách channel code
      final channelCodes =
          permissions.channels.map((channel) => channel.code).toList();
      log.log('Các channel có sẵn cho người dùng: $channelCodes');
      return channelCodes;
    } catch (e) {
      log.log('Lỗi khi lấy danh sách channel: $e');
      return [];
    }
  }

  // Phương thức mới để lấy token của channel dựa trên code
  Future<String> getChannelToken(String channelCode) async {
    try {
      final permissions = await getUserPermissions();
      if (permissions == null || permissions.channels.isEmpty) {
        log.log('Không có channel nào cho người dùng');
        return '';
      }

      // Tìm channel dựa trên code
      final channel = permissions.channels.firstWhere(
        (channel) => channel.code == channelCode,
        orElse: () => Channel(id: 0, token: '', code: '', permissions: []),
      );

      if (channel.token.isEmpty) {
        log.log('Không tìm thấy token cho channel: $channelCode');
        return '';
      }

      log.log('Đã tìm thấy token cho channel: $channelCode');
      return channel.token;
    } catch (e) {
      log.log('Lỗi khi lấy token cho channel: $e');
      return '';
    }
  }
}
