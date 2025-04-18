import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as log;
import 'api_endpoints.dart';
import 'api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  String? _authToken;
  final http.Client _client;
  final CookieJar _cookieJar;

  ApiClient._internal() : _client = http.Client(), _cookieJar = CookieJar();

  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        instance._authToken = token;
      }

      // Load saved cookies
      final savedCookies = prefs.getString('cookies');
      if (savedCookies != null) {
        final cookies =
            savedCookies.split('; ').map((cookie) {
              final parts = cookie.split('=');
              return Cookie(parts[0], parts[1]);
            }).toList();

        await instance._cookieJar.saveFromResponse(
          Uri.parse(ApiConstants.baseUrl),
          cookies,
        );
      }
    } catch (e) {
      log.log('Error initializing ApiClient: $e');
    }
  }

  Future<Map<String, dynamic>?> query(
    String query, {
    Map<String, dynamic>? variables,
    String? channelToken,
  }) async {
    try {
      log.log('\n=== API REQUEST ===');
      log.log('GraphQL Endpoint: ${ApiEndpoints.graphql}');
      log.log('GraphQL Query: $query');
      log.log('Variables: $variables');
      log.log('Channel Token: $channelToken');

      // Tạo body request để in ra
      final requestBody = json.encode({'query': query, 'variables': variables});
      log.log('Request Body: $requestBody');

      // Kiểm tra nếu là query lấy booking stats thì gọi API thật
      if (query.contains('getBookingExpectedRevenue') ||
          query.contains('GetTotalBooking')) {
        // Lấy headers
        final headers = await _getHeaders(channelToken: channelToken);
        log.log('Request Headers: $headers');

        final response = await _client.post(
          Uri.parse(ApiEndpoints.graphql),
          headers: headers,
          body: requestBody,
        );

        await _saveCookies(response);
        return _handleResponse(response);
      }

      // Giữ lại mock data cho các trường hợp khác
      if (channelToken == 'demo-channel') {
        log.log('Using mock data for demo-channel');
        return {
          'data': {
            // Các mock data khác ở đây
          },
        };
      }

      // Lấy headers
      final headers = await _getHeaders(channelToken: channelToken);
      log.log('Request Headers: $headers');

      final response = await _client.post(
        Uri.parse(ApiEndpoints.graphql),
        headers: headers,
        body: requestBody,
      );

      // log.log('\n=== API RESPONSE ===');
      // log.log('Response Status Code: ${response.statusCode}');
      // log.log('Response Headers: ${response.headers}');
      // log.log('Response Body: ${response.body}');
      // log.log('==============================\n');

      await _saveCookies(response);
      return _handleResponse(response);
    } catch (e) {
      log.log('\n=== API ERROR ===');
      log.log('Error details: $e');
      log.log('==============================\n');
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders({String? channelToken}) async {
    final headers = {'Content-Type': 'application/json'};

    // Xử lý channel token
    if (channelToken != null) {
      headers['vendure-token'] = channelToken;
    } else {
      // Mặc định sử dụng 'vendure-token': 'demo-channel' nếu không có token cụ thể
      headers['vendure-token'] = 'demo-channel';
    }

    log.log('Using vendure-token: ${headers['vendure-token']}');

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final cookies = await _cookieJar.loadForRequest(
      Uri.parse(ApiConstants.baseUrl),
    );

    if (cookies.isNotEmpty) {
      headers['Cookie'] = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    }

    log.log('Request headers: $headers');
    return headers;
  }

  Future<void> _saveCookies(http.Response response) async {
    try {
      final cookieHeader = response.headers['set-cookie'];
      if (cookieHeader != null) {
        final cookies =
            cookieHeader.split(',').map((cookie) {
              return Cookie.fromSetCookieValue(cookie.trim());
            }).toList();

        await _cookieJar.saveFromResponse(
          Uri.parse(ApiConstants.baseUrl),
          cookies,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'cookies',
          cookies.map((c) => '${c.name}=${c.value}').join('; '),
        );
      }
    } catch (e) {
      log.log('Error saving cookies: $e');
    }
  }

  Map<String, dynamic>? _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        if (data.containsKey('errors')) {
          // Vẫn trả về data ngay cả khi có lỗi, để lớp cao hơn có thể xử lý dữ liệu một phần
          log.log('GraphQL Errors: ${data['errors']}');
          return data;
        }
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return data;
        }
      }
      log.log('Invalid response: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      log.log('Error handling response: $e');
      return null;
    }
  }

  void setAuthToken(String token) => _authToken = token;

  Future<void> clearAuth() async {
    try {
      _authToken = null;
      await _cookieJar.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('cookies');
    } catch (e) {
      log.log('Error clearing auth: $e');
    }
  }
}
