import '../interfaces/i_choose_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../../models/product_with_courts_model.dart';

class ChooseRepository implements IChooseService {
  final ApiClient _apiClient;

  ChooseRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<ProductsWithCourtsResponse> getProductsWithCourts() async {
    const String query = '''
      query GetProductsWithCourts {
        getProductsWithCourts {
          totalItems
          items {
            id
            name
          }
        }
      }
    ''';

    try {
      final jsonResponse = await _apiClient.query<Map<String, dynamic>>(
        query,
        converter: (json) => json,
      );

      if (jsonResponse == null) {
        log.log('Response is null for getProductsWithCourts');
        throw Exception('No data returned from getProductsWithCourts query');
      }

      final data = jsonResponse['data'];
      if (data == null) {
        log.log('Data is null for getProductsWithCourts');
        throw Exception('No data returned from getProductsWithCourts query');
      }

      final productsData = data['getProductsWithCourts'];
      if (productsData == null) {
        throw Exception('No getProductsWithCourts field in response data');
      }

      return ProductsWithCourtsResponse.fromJson(productsData);
    } catch (e) {
      log.log('Error fetching products with courts: $e');
      throw Exception('Failed to get products with courts: ${e.toString()}');
    }
  }
}
