import 'package:http/http.dart' as http;
import 'dart:convert';
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
      print('Error initializing ApiClient: $e');
    }
  }

  Future<Map<String, dynamic>?> query(
    String query, {
    Map<String, dynamic>? variables,
    String? channelToken,
  }) async {
    try {
      print('Sending GraphQL query: $query');
      print('Variables: $variables');
      print('Channel Token: $channelToken');

      // Kiểm tra nếu là query lấy booking stats thì gọi API thật
      if (query.contains('getBookingExpectedRevenue') ||
          query.contains('GetTotalBooking')) {
        final response = await _client.post(
          Uri.parse(ApiEndpoints.graphql),
          headers: await _getHeaders(channelToken: channelToken),
          body: json.encode({'query': query, 'variables': variables}),
        );

        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        await _saveCookies(response);
        return _handleResponse(response);
      }

      // Giữ lại mock data cho các trường hợp khác
      if (channelToken == 'demo-channel') {
        print('Using mock data for demo-channel');
        return {
          'data': {
            // Các mock data khác ở đây
          },
        };
      }

      final response = await _client.post(
        Uri.parse(ApiEndpoints.graphql),
        headers: await _getHeaders(channelToken: channelToken),
        body: json.encode({'query': query, 'variables': variables}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      await _saveCookies(response);
      return _handleResponse(response);
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders({String? channelToken}) async {
    final headers = {'Content-Type': 'application/json'};

    // Xử lý channel token
    if (channelToken != null) {
      // Nếu là Pikachu Pickleball Xuân Hoà, sử dụng token 'pikachu'
      if (channelToken == 'Pikachu Pickleball Xuân Hoà') {
        headers['vendure-token'] = 'pikachu';
      } else {
        headers['vendure-token'] = channelToken;
      }
    } else {
      // Mặc định sử dụng 'vendure-token': 'demo-channel' nếu không có token cụ thể
      headers['vendure-token'] = 'demo-channel';
    }

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final cookies = await _cookieJar.loadForRequest(
      Uri.parse(ApiConstants.baseUrl),
    );

    if (cookies.isNotEmpty) {
      headers['Cookie'] = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    }

    print('Request headers: $headers');
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
      print('Error saving cookies: $e');
    }
  }

  Map<String, dynamic>? _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          if (data.containsKey('errors')) {
            print('GraphQL Errors: ${data['errors']}');
            return null;
          }
          return data;
        }
      }
      print('Invalid response: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Error handling response: $e');
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
      print('Error clearing auth: $e');
    }
  }
}
