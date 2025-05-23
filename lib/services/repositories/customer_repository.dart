import 'dart:io';
import 'package:app_pickleball/models/customer_model.dart';
import 'package:app_pickleball/services/interfaces/i_customer_service.dart';
import 'package:app_pickleball/services/api/api_endpoints.dart';
import 'package:app_pickleball/services/api/api_client.dart';
import 'dart:developer' as log;

class CustomerRepository implements ICustomerService {
  final String baseUrl = ApiEndpoints.base;
  final ApiClient _apiClient = ApiClient.instance;

  @override
  Future<CustomerResponse> getCustomers({
    required String channelToken,
    String? searchQuery,
  }) async {
    try {
      // Kiểm tra internet connection
      final bool hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        log.log('CustomerRepository - getCustomers: No internet connection');
        return CustomerResponse.empty();
      }

      // Escape searchQuery để tránh lỗi khi có ký tự đặc biệt
      String? escapedSearchQuery;
      if (searchQuery != null && searchQuery.length >= 3) {
        escapedSearchQuery = _escapeString(searchQuery);
        log.log(
          'CustomerRepository - searchQuery: "$searchQuery", escaped: "$escapedSearchQuery"',
        );
      }

      String query;

      if (escapedSearchQuery != null) {
        // Truy vấn với điều kiện tìm kiếm
        query = '''
        query Customers {
          customers(
            options: {
              filter: {
                _or: [
                  { firstName: { contains: "$escapedSearchQuery" } }
                  { lastName: { contains: "$escapedSearchQuery" } }
                  { phoneNumber: { contains: "$escapedSearchQuery" } }
                  { emailAddress: { contains: "$escapedSearchQuery" } }
                ]
              }
            }
          ) {
            items {
              id
              createdAt
              updatedAt
              title
              firstName
              lastName
              phoneNumber
              emailAddress
            }
          }
        }
        ''';
      } else {
        // Truy vấn mặc định
        query = '''
        query Customers {
          customers(
            options: {
              filter: {
                _or: [
                  { firstName: { contains: null } }
                  { lastName: { contains: null } }
                  { phoneNumber: { contains: null } }
                  { emailAddress: { contains: null } }
                ]
              }
            }
          ) {
            items {
              id
              createdAt
              updatedAt
              title
              firstName
              lastName
              phoneNumber
              emailAddress
            }
          }
        }
        ''';
      }

      // Ghi log query để debug
      log.log('CustomerRepository - GraphQL query: $query');

      // Log token để debug (ẩn một phần của token)
      String maskedToken = channelToken;
      if (channelToken.length > 10) {
        maskedToken =
            "${channelToken.substring(0, 5)}...${channelToken.substring(channelToken.length - 5)}";
      }
      log.log('CustomerRepository - Using channel token: $maskedToken');

      log.log(
        'CustomerRepository - Sử dụng ApiClient để thực hiện truy vấn (tự động xử lý session và cookies)',
      );
      final response = await _apiClient.query<Map<String, dynamic>>(
        query,
        variables: {},
        channelToken: channelToken,
        converter: (json) => json,
      );

      if (response != null && response.containsKey('data')) {
        if (response['data'] != null &&
            response['data'].containsKey('customers')) {
          log.log('CustomerRepository - Truy vấn thành công với ApiClient');
          return CustomerResponse.fromJson(response['data']);
        } else if (response.containsKey('errors')) {
          final errorMessage = response['errors'][0]['message'];
          final errorCode = response['errors'][0]['extensions']['code'];
          log.log(
            'CustomerRepository - GraphQL error: $errorMessage, Code: $errorCode',
          );
        }
      }

      log.log('CustomerRepository - Không nhận được dữ liệu hợp lệ từ API');
      return CustomerResponse.empty();
    } catch (e) {
      log.log('CustomerRepository - getCustomers: Exception $e');
      return CustomerResponse.empty();
    }
  }

  // Hàm escape chuỗi cho GraphQL query
  String _escapeString(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  // Private helper method để kiểm tra kết nối internet
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
