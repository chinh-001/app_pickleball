class ApiConstants {
  static const String baseUrl = 'https://dev-vendure-gamora.aegona.net';
  static const String adminApiPath = '/admin-api';
  static const int timeoutSeconds = 30;
  static const int maxRetries = 3;

  // Auth related
  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer';
  static const String contentType = 'application/json';

  // Cookie related
  static const String cookieHeader = 'Cookie';
  static const String setCookieHeader = 'set-cookie';

  // Error messages
  static const String networkError = 'Network error occurred';
  static const String invalidResponse = 'Invalid response format';
  static const String unauthorized = 'Unauthorized access';
}
