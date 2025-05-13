import 'dart:developer' as log;
import '../utils/auth_helper.dart';
import '../services/api/api_client.dart';

class UserAccount {
  final int id;
  final String identifier;
  final String token; // Calculated from id:identifier

  UserAccount({required this.id, required this.identifier})
    : token = '$id:$identifier';

  // Create User model from API response
  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      identifier: map['identifier']?.toString() ?? '',
    );
  }

  // Convert User model to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'identifier': identifier, 'token': token};
  }

  // Create an empty user
  factory UserAccount.empty() {
    return UserAccount(id: 0, identifier: '');
  }

  // Save user login data and return success status
  Future<bool> saveLoginData() async {
    try {
      // Save login status
      await AuthHelper.saveUserLoggedInStatus(true);

      // Save user token
      await AuthHelper.saveUserToken(token);

      // Save username if available
      if (identifier.isNotEmpty) {
        await AuthHelper.saveUserName(identifier);
      }

      // Update API client with token
      ApiClient.instance.setAuthToken(token);

      log.log('Login successful and data saved by User model');
      return true;
    } catch (e) {
      log.log('Error saving login data in User model: $e');
      return false;
    }
  }
}
