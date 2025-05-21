import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as log;
import 'api_endpoints.dart';
import 'api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../../utils/auth_helper.dart';

/// Định nghĩa kiểu hàm chuyển đổi từ JSON sang kiểu T
typedef JsonConverter<T> = T Function(Map<String, dynamic> json);

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  String? _authToken;
  final http.Client _client;
  final CookieJar _cookieJar;

  ApiClient._internal() : _client = http.Client(), _cookieJar = CookieJar();

  static Future<void> initialize() async {
    try {
      // Sử dụng AuthHelper để lấy token đã lưu
      final token = await AuthHelper.getUserToken();
      if (token.isNotEmpty) {
        log.log('Khởi tạo ApiClient với token đã lưu: $token');
        instance._authToken = token;

        // Xác minh token có hợp lệ không bằng cách log token
        log.log('Token được đặt thành công: ${instance._authToken}');
      } else {
        log.log('Không tìm thấy token đã lưu');
      }

      // Load saved cookies
      final prefs = await SharedPreferences.getInstance();
      final savedCookies = prefs.getString('cookies');
      if (savedCookies != null && savedCookies.isNotEmpty) {
        try {
          final cookies =
              savedCookies
                  .split(';')
                  .map((cookie) {
                    final parts = cookie.trim().split('=');
                    if (parts.length >= 2) {
                      return Cookie(
                        parts[0],
                        parts.join('=').substring(parts[0].length + 1),
                      );
                    }
                    // log.log('Bỏ qua cookie không hợp lệ: $cookie');
                    return null;
                  })
                  .where((c) => c != null)
                  .cast<Cookie>()
                  .toList();

          if (cookies.isNotEmpty) {
            // log.log('Đã tải ${cookies.length} cookies từ SharedPreferences');
            await instance._cookieJar.saveFromResponse(
              Uri.parse(ApiConstants.baseUrl),
              cookies,
            );
          }
        } catch (e) {
          log.log('Lỗi khi phân tích cookies: $e');
        }
      }
    } catch (e) {
      log.log('Error initializing ApiClient: $e');
    }
  }

  /// Query GraphQL và trả về kiểu T
  /// [converter] là hàm chuyển đổi từ JSON sang kiểu T
  Future<T?> query<T>(
    String query, {
    Map<String, dynamic>? variables,
    String? channelToken,
    required JsonConverter<T> converter,
  }) async {
    try {
      log.log('\n=== API CLIENT: QUERY GRAPHQL ===');
      log.log('Thực hiện truy vấn GraphQL');

      final requestBody = json.encode({'query': query, 'variables': variables});
      // log.log('Request Body: $requestBody');

      // Lấy headers
      final headers = await _getHeaders(channelToken: channelToken);
      log.log('Channel Token: $channelToken');
      // log.log('Request Headers: $headers');

      log.log('Gửi request đến: ${ApiEndpoints.graphql}');
      final response = await _client.post(
        Uri.parse(ApiEndpoints.graphql),
        headers: headers,
        body: requestBody,
      );

      log.log('Response Status Code: ${response.statusCode}');

      await _saveCookies(response);
      final jsonResponse = _handleResponse(response);

      if (jsonResponse != null) {
        log.log('Truy vấn thành công, chuyển đổi response');
        final result = converter(jsonResponse);
        log.log('=== KẾT THÚC API CLIENT: QUERY GRAPHQL THÀNH CÔNG ===\n');
        return result;
      } else {
        log.log('Truy vấn thất bại, jsonResponse là null');
        log.log('=== KẾT THÚC API CLIENT: QUERY GRAPHQL THẤT BẠI ===\n');
      }
      return null;
    } catch (e) {
      log.log('\n=== API ERROR ===');
      log.log('Error details: $e');
      log.log('==============================\n');
      return null;
    }
  }

  /// Query với đường dẫn đến field data cụ thể trong GraphQL response
  /// Tiện ích khi bạn chỉ quan tâm đến một phần nhỏ của response
  Future<T?> queryField<T>(
    String query, {
    Map<String, dynamic>? variables,
    String? channelToken,
    required String fieldPath,
    required JsonConverter<T> converter,
  }) async {
    try {
      // Sử dụng query<Map<String, dynamic>> thay vì queryMap
      final Map<String, dynamic>? response = await this
          .query<Map<String, dynamic>>(
            query,
            variables: variables,
            channelToken: channelToken,
            converter: (json) => json,
          );

      if (response == null || !response.containsKey('data')) {
        return null;
      }

      // Hỗ trợ đường dẫn với dấu chấm, ví dụ "me.channels"
      final pathParts = fieldPath.split('.');
      dynamic data = response['data'];

      for (final part in pathParts) {
        if (data is! Map<String, dynamic> || !data.containsKey(part)) {
          // log.log('Field path không hợp lệ: $fieldPath');
          return null;
        }
        data = data[part];
      }

      if (data == null) {
        return null;
      }

      return converter(data is Map<String, dynamic> ? data : {'result': data});
    } catch (e) {
      log.log('Error querying field: $e');
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders({String? channelToken}) async {
    final headers = {'Content-Type': 'application/json'};

    // Add channel token if provided
    if (channelToken != null) {
      headers['vendure-token'] = channelToken;
    } else {
      // Default channel token
      headers['vendure-token'] = 'demo-channel';
    }

    // Add auth token if available
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    } else {
      // Try to get token from AuthHelper
      final token = await AuthHelper.getUserToken();
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _authToken = token; // Update token for future requests
      }
    }

    // Add cookies if available
    final cookies = await _cookieJar.loadForRequest(
      Uri.parse(ApiConstants.baseUrl),
    );

    if (cookies.isNotEmpty) {
      headers['Cookie'] = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    }

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
          cookies.map((c) => '${c.name}=${c.value}').join(';'),
        );
      }
    } catch (e) {
      log.log('Error saving cookies: $e');
    }
  }

  Map<String, dynamic>? _handleResponse(http.Response response) {
    try {
      // log.log('\n=== API CLIENT: HANDLE RESPONSE ===');
      // log.log('Đang xử lý response với status code: ${response.statusCode}');

      final data = json.decode(response.body);
      // log.log('Đã decode JSON response thành công');

      if (data is Map<String, dynamic>) {
        if (data.containsKey('errors')) {
          // Vẫn trả về data ngay cả khi có lỗi, để lớp cao hơn có thể xử lý dữ liệu một phần
          log.log('GraphQL Errors: ${data['errors']}');
          return data;
        }
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // log.log('Response hợp lệ, status: ${response.statusCode}');
          // Kiểm tra và log cấu trúc data
          if (data.containsKey('data')) {
            // log.log('Response có field data');
            final dataField = data['data'];
            if (dataField is Map<String, dynamic>) {
              for (var key in dataField.keys) {
                log.log('Data có field: $key');
              }
              // Log để debug getAvailableCourtForBooking
              if (dataField.containsKey('getAvailableCourtForBooking')) {
                final courtData = dataField['getAvailableCourtForBooking'];
                log.log('getAvailableCourtForBooking data: $courtData');
              }
            }
          }
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

  void setAuthToken(String token) {
    // log.log('Setting auth token: $token');
    _authToken = token;
  }

  Future<void> clearAuth() async {
    try {
      _authToken = null;
      await _cookieJar.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cookies');
      // AuthHelper sẽ xóa token trong SharedPreferences
      // nên không cần xóa 'auth_token' ở đây
    } catch (e) {
      log.log('Error clearing auth: $e');
    }
  }
}
