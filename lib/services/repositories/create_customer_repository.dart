import 'dart:io';
import 'package:app_pickleball/models/create_customer_model.dart';
import 'package:app_pickleball/services/interfaces/i_create_customer_service.dart';
import 'package:app_pickleball/services/api/api_endpoints.dart';
import 'package:app_pickleball/services/api/api_client.dart';
import 'dart:developer' as log;

class CreateCustomerRepository implements ICreateCustomerService {
  final String baseUrl = ApiEndpoints.base;
  final ApiClient _apiClient = ApiClient.instance;

  @override
  Future<CreateCustomerResponse> createCustomer({
    required String channelToken,
    required CreateCustomerInput input,
  }) async {
    try {
      // Kiểm tra internet connection
      final bool hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        log.log(
          'CreateCustomerRepository - createCustomer: No internet connection',
        );
        return CreateCustomerResponse.empty();
      }

      // GraphQL mutation để tạo khách hàng mới
      final mutation = '''
      mutation CreateCustomer {
        createCustomer(
          input: {
            title: "${_escapeString(input.title)}"
            firstName: "${_escapeString(input.firstName)}"
            lastName: "${_escapeString(input.lastName)}"
            phoneNumber: "${_escapeString(input.phoneNumber)}"
            emailAddress: "${_escapeString(input.emailAddress)}"
          }
        ) {
          ... on Customer {
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

      // Log token để debug (ẩn một phần của token)
      String maskedToken = channelToken;
      if (channelToken.length > 10) {
        maskedToken =
            "${channelToken.substring(0, 5)}...${channelToken.substring(channelToken.length - 5)}";
      }
      log.log('CreateCustomerRepository - Using channel token: $maskedToken');

      log.log(
        'CreateCustomerRepository - Sử dụng ApiClient để thực hiện mutation (tự động xử lý session và cookies)',
      );

      // Thực hiện GraphQL mutation
      final response = await _apiClient.query<Map<String, dynamic>>(
        mutation,
        variables: {},
        channelToken: channelToken,
        converter: (json) => json,
      );

      if (response != null && response.containsKey('data')) {
        log.log('CreateCustomerRepository - Mutation thành công');
        return CreateCustomerResponse.fromJson(response['data']);
      } else if (response != null && response.containsKey('errors')) {
        final errorMessage = response['errors'][0]['message'];
        final errorCode = response['errors'][0]['extensions']['code'];
        log.log(
          'CreateCustomerRepository - GraphQL error: $errorMessage, Code: $errorCode',
        );
        return CreateCustomerResponse(
          errors: List<Map<String, dynamic>>.from(response['errors']),
        );
      }

      log.log(
        'CreateCustomerRepository - Không nhận được dữ liệu hợp lệ từ API',
      );
      return CreateCustomerResponse.empty();
    } catch (e) {
      log.log('CreateCustomerRepository - createCustomer: Exception $e');
      return CreateCustomerResponse.empty();
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
