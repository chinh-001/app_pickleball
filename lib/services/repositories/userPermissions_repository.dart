import '../interfaces/i_userPermissions_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../../utils/auth_helper.dart';
import '../../model/userPermissions_model.dart';

class UserPermissionsRepository implements IUserPermissionsService {
  final ApiClient _apiClient;

  UserPermissionsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

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
}
