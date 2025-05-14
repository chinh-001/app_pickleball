import '../interfaces/i_choose_service.dart';
import '../api/api_client.dart';
import '../channel_sync_service.dart';
import '../repositories/userPermissions_repository.dart';
import 'dart:developer' as log;
import '../../models/productWithCourts_Model.dart';

class ChooseRepository implements IChooseService {
  final ApiClient _apiClient;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  final UserPermissionsRepository _permissionsRepository;

  ChooseRepository({
    ApiClient? apiClient,
    UserPermissionsRepository? permissionsRepository,
  }) : _apiClient = apiClient ?? ApiClient.instance,
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository();

  @override
  Future<ProductsWithCourtsResponse> getProductsWithCourts({
    String? channelToken,
  }) async {
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
      // If no channelToken provided, get it from the selected channel
      String tokenToUse = channelToken ?? '';

      if (tokenToUse.isEmpty) {
        // Get the currently selected channel from ChannelSyncService
        final selectedChannel = _channelSyncService.selectedChannel;
        log.log('Getting products with courts for channel: $selectedChannel');

        if (selectedChannel.isNotEmpty) {
          // If channel is Pikachu, use special token
          if (selectedChannel == 'Pikachu Pickleball Xuân Hoà') {
            tokenToUse = 'pikachu';
          } else {
            // Get token for the selected channel
            tokenToUse = await _permissionsRepository.getChannelToken(
              selectedChannel,
            );
          }
        }

        // If still empty, use a default
        if (tokenToUse.isEmpty) {
          tokenToUse = 'demo-channel';
        }
      }

      log.log('Querying getProductsWithCourts with channel token: $tokenToUse');

      final jsonResponse = await _apiClient.query<Map<String, dynamic>>(
        query,
        channelToken: tokenToUse,
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

      final result = ProductsWithCourtsResponse.fromJson(productsData);
      log.log(
        'Got products for channel token $tokenToUse: ${result.totalItems} products',
      );
      return result;
    } catch (e) {
      log.log('Error fetching products with courts: $e');
      throw Exception('Failed to get products with courts: ${e.toString()}');
    }
  }
}
