import '../../model/userInfo_model.dart';

abstract class IAdministratorService {
  Future<Map<String, dynamic>> getActiveAdministratorRaw();
  Future<UserInfo> getActiveAdministrator();
}
