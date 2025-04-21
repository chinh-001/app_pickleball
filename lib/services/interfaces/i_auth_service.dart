abstract class IAuthService {
  Future<bool> login(String username, String password);
  Future<String> getToken();
  Future<bool> logout();
  Future<bool> isLoggedIn();
}
