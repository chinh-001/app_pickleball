abstract class IAuthService {
  Future<bool> login(String username, String password);
  Future<String> getToken();
  Future<void> logout();
}