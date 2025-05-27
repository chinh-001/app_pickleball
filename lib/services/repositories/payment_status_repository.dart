import 'package:app_pickleball/models/payment_status_model.dart';
import 'package:app_pickleball/services/interfaces/i_payment_status_service.dart';
import 'package:app_pickleball/services/api/api_client.dart';
import 'package:app_pickleball/services/channel_sync_service.dart';
import 'package:app_pickleball/services/repositories/userPermissions_repository.dart';
import 'dart:developer' as log;

class PaymentStatusRepository implements IPaymentStatusService {
  final ApiClient _apiClient;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  final UserPermissionsRepository _permissionsRepository;

  PaymentStatusRepository({
    ApiClient? apiClient,
    UserPermissionsRepository? permissionsRepository,
  }) : _apiClient = apiClient ?? ApiClient.instance,
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository();

  @override
  Future<PaymentStatusResult> getAllPaymentStatus() async {
    try {
      log.log('\n=== REPOSITORY: PAYMENT STATUS ===');

      const query = '''
      query GetAllPaymentStatus {
          getAllPaymentStatus {
              totalItems
              items {
                  id
                  name
                  code
              }
          }
      }
      ''';

      // Lấy channel token từ channel hiện tại
      String tokenToUse = '';
      final selectedChannel = _channelSyncService.selectedChannel;
      log.log('Lấy trạng thái thanh toán cho channel: $selectedChannel');

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

      final result = await _apiClient.queryField<PaymentStatusResult>(
        query,
        channelToken: tokenToUse,
        fieldPath: 'getAllPaymentStatus',
        converter: (json) => PaymentStatusResult.fromJson(json),
      );

      if (result != null) {
        log.log(
          'Lấy trạng thái thanh toán thành công: ${result.totalItems} trạng thái',
        );
        return result;
      } else {
        throw Exception('Không thể lấy trạng thái thanh toán');
      }
    } catch (e) {
      log.log('Lỗi trong getAllPaymentStatus: $e');
      throw Exception('Lỗi trong getAllPaymentStatus: $e');
    }
  }
}
