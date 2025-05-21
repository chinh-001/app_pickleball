import 'dart:convert';
import 'dart:io';
import 'package:app_pickleball/models/customer_model.dart';
import 'package:app_pickleball/services/interfaces/i_customer_service.dart';
import 'package:app_pickleball/enum/CallApiStatus.dart';
import 'package:app_pickleball/services/api/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as log;
import 'package:app_pickleball/utils/auth_helper.dart';

class CustomerRepository implements ICustomerService {
  final String baseUrl = ApiEndpoints.base;

  @override
  Future<CustomerResponse> getCustomers({required String channelToken}) async {
    try {
      // Kiểm tra internet connection
      final bool hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        log.log('CustomerRepository - getCustomers: No internet connection');
        return CustomerResponse.empty();
      }

      final String query = '''
      query Customers {
        customers {
          totalItems
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

      final response = await http.post(
        Uri.parse('$baseUrl/shop-api'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $channelToken',
          'Accept-Language': 'vi', // mặc định sử dụng tiếng Việt
        },
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('data')) {
          return CustomerResponse.fromJson(responseData['data']);
        } else if (responseData.containsKey('errors')) {
          final errorMessage = responseData['errors'][0]['message'];
          log.log(
            'CustomerRepository - getCustomers: GraphQL error: $errorMessage',
          );
          return CustomerResponse.empty();
        }
      }

      log.log(
        'CustomerRepository - getCustomers: Failed with status ${response.statusCode}',
      );
      return CustomerResponse.empty();
    } catch (e) {
      log.log('CustomerRepository - getCustomers: Exception $e');
      return CustomerResponse.empty();
    }
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
