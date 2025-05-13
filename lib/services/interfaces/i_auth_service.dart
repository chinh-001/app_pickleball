import '../../models/userAccount_model.dart';

abstract class IAuthService {
  Future<UserAccount?> login(String username, String password);
  Future<String> getToken();
  Future<bool> logout();
  Future<bool> isLoggedIn();
}
