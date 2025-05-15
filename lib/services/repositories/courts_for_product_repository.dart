import '../interfaces/i_courts_for_product_service.dart';
import '../api/api_client.dart';
import '../channel_sync_service.dart';
import '../repositories/userPermissions_repository.dart';
import 'dart:developer' as log;
import '../../models/courtsForProduct_model.dart';

class CourtsForProductRepository implements ICourtsForProductService {
  final ApiClient _apiClient;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  final UserPermissionsRepository _permissionsRepository;

  CourtsForProductRepository({
    ApiClient? apiClient,
    UserPermissionsRepository? permissionsRepository,
  }) : _apiClient = apiClient ?? ApiClient.instance,
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository();

  @override
  Future<CourtsForProductResponse> getCourtsForProduct({
    required String productId,
    String? channelToken,
  }) async {
    final String query = '''
      query GetCourtsForProduct {
        getCourtsForProduct(productId: "$productId") {
          name
          id
        }
      }
    ''';

    try {
      // If no channelToken provided, get it from the selected channel
      String tokenToUse = channelToken ?? '';

      if (tokenToUse.isEmpty) {
        // Get the currently selected channel from ChannelSyncService
        final selectedChannel = _channelSyncService.selectedChannel;
        log.log(
          'Getting courts for product ID $productId from channel: $selectedChannel',
        );

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

      log.log(
        'Querying getCourtsForProduct for productId: $productId with channel token: $tokenToUse',
      );

      final jsonResponse = await _apiClient.query<Map<String, dynamic>>(
        query,
        channelToken: tokenToUse,
        converter: (json) => json,
      );

      if (jsonResponse == null) {
        log.log('Response is null for getCourtsForProduct');
        throw Exception('No data returned from getCourtsForProduct query');
      }

      final data = jsonResponse['data'];
      if (data == null) {
        log.log('Data is null for getCourtsForProduct');
        throw Exception('No data returned from getCourtsForProduct query');
      }

      final result = CourtsForProductResponse.fromJson(data);
      log.log(
        'Got courts for product ID $productId: ${result.courts.length} courts',
      );
      return result;
    } catch (e) {
      log.log('Error fetching courts for product: $e');
      throw Exception('Failed to get courts for product: ${e.toString()}');
    }
  }
}
