import '../../model/userPermissions_model.dart';

abstract class IUserPermissionsService {
  Future<UserPermissions?> getUserPermissions();
  Future<bool> hasPermission(String permissionCode);
  Future<List<String>> getUserChannelCodes();
  Future<bool> saveUserPermissions(UserPermissions permissions);
}
