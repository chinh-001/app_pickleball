import 'package:app_pickleball/models/payment_methods_model.dart';
import 'package:app_pickleball/services/interfaces/i_payment_methods_service.dart';
import 'package:app_pickleball/services/api/api_client.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'dart:developer' as log;

class PaymentMethodsRepository implements IPaymentMethodsService {
  final ApiClient _apiClient;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  final UserPermissionsRepository _permissionsRepository;

  PaymentMethodsRepository({
    ApiClient? apiClient,
    UserPermissionsRepository? permissionsRepository,
  }) : _apiClient = apiClient ?? ApiClient.instance,
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository();

  @override
  Future<PaymentMethodsResult> getPaymentMethods() async {
    try {
      log.log('\n=== REPOSITORY: PAYMENT METHODS ===');

      const query = '''
      query PaymentMethods {
          paymentMethods {
              totalItems
              items {
                  id
                  name
                  code
                  description
                  enabled
                  customFields
              }
          }
      }
      ''';

      // Lấy channel token từ channel hiện tại
      String tokenToUse = '';
      final selectedChannel = _channelSyncService.selectedChannel;
      log.log('Lấy phương thức thanh toán cho channel: $selectedChannel');

      if (selectedChannel.isNotEmpty) {
        // Xử lý đặc biệt cho Pikachu
        if (selectedChannel == 'Pikachu Pickleball Xuân Hoà') {
          tokenToUse = 'pikachu';
        } else {
          // Lấy token cho channel hiện tại
          tokenToUse = await _permissionsRepository.getChannelToken(
            selectedChannel,
          );
        }
      }

      final result = await _apiClient.queryField<PaymentMethodsResult>(
        query,
        channelToken: tokenToUse,
        fieldPath: 'paymentMethods',
        converter: (json) => PaymentMethodsResult.fromJson(json),
      );

      if (result != null) {
        log.log(
          'Lấy phương thức thanh toán thành công: ${result.totalItems} phương thức',
        );
        return result;
      } else {
        throw Exception('Không thể lấy phương thức thanh toán');
      }
    } catch (e) {
      log.log('Lỗi trong getPaymentMethods: $e');
      throw Exception('Lỗi trong getPaymentMethods: $e');
    }
  }
}
