import 'api_constants.dart';

class ApiEndpoints {
  static String get base => ApiConstants.baseUrl;
  
  static String get graphql => '${ApiConstants.baseUrl}${ApiConstants.adminApiPath}';
  
  // Auth endpoints
  static String get login => '$graphql/auth/login';
  static String get logout => '$graphql/auth/logout';
  static String get refreshToken => '$graphql/auth/refresh';
  
  // Order endpoints
  static String get orders => '$graphql/orders';
  static String get orderStats => '$graphql/order-stats';
  
  // Court endpoints
  static String get courts => '$graphql/courts';
  static String get courtBookings => '$graphql/court-bookings';
  
  // Profile endpoints
  static String get profile => '$graphql/profile';
  static String get updateProfile => '$graphql/profile/update';
}