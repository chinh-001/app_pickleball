class EnvConstants {
  // API endpoints
  static const String apiBaseUrl = 'https://api.pickleball.example.com';
  static const String graphqlEndpoint = '$apiBaseUrl/graphql';

  // Channel constants
  static const String defaultChannelCode = 'DEFAULT';

  // Permission constants
  static const String viewBookingsPermission = 'VIEW_BOOKINGS';
  static const String createBookingPermission = 'CREATE_BOOKING';
  static const String cancelBookingPermission = 'CANCEL_BOOKING';
  static const String manageUsersPermission = 'MANAGE_USERS';
  static const String adminPermission = 'ADMIN';

  // Token related
  static const int tokenExpiryHours = 24;
  static const String authHeaderName = 'Authorization';
  static const String authHeaderPrefix = 'Bearer';
}
