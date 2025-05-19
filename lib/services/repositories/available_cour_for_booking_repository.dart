import 'dart:io';
import '../../models/available_cour_for_booking_model.dart';
import '../interfaces/i_available_cour_for_booking_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../channel_sync_service.dart';
import '../repositories/userPermissions_repository.dart';

class AvailableCourForBookingRepository
    implements IAvailableCourForBookingService {
  final ApiClient _apiClient;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  final UserPermissionsRepository _permissionsRepository;

  AvailableCourForBookingRepository({
    ApiClient? apiClient,
    UserPermissionsRepository? permissionsRepository,
  }) : _apiClient = apiClient ?? ApiClient.instance,
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository();

  @override
  Future<List<AvailableCourForBookingModel>> getAvailableCourForBooking(
    AvailableCourInputModel input,
  ) async {
    try {
      log.log('\n=== REPOSITORY: AVAILABLE COURT FOR BOOKING ===');
      log.log('Bắt đầu gọi API getAvailableCourtForBooking');
      log.log('Input: ${input.toJson()}');

      // Lấy channel token từ channel hiện tại
      String tokenToUse = '';
      final selectedChannel = _channelSyncService.selectedChannel;
      log.log('Kiểm tra sân có sẵn cho channel: $selectedChannel');

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

        // Nếu vẫn trống, sử dụng token mặc định
        if (tokenToUse.isEmpty) {
          tokenToUse = 'demo-channel';
        }
      } else {
        tokenToUse = 'demo-channel';
      }

      log.log('Sử dụng channel token: $tokenToUse');

      const query = '''
        query GetAvailableCourtForBooking(
          \$bookingDates: [String!]!,
          \$start_time: String!,
          \$end_time: String!,
          \$productId: ID!,
          \$quantityCourt: Int!
        ) {
          getAvailableCourtForBooking(
            input: {
              bookingDates: \$bookingDates,
              start_time: \$start_time,
              end_time: \$end_time,
              productId: \$productId,
              quantityCourt: \$quantityCourt
            }
          ) {
            bookingDate
            courts {
              id
              name
              status
              price
              start_time
              end_time
            }
          }
        }
      ''';

      final variables = {
        'bookingDates': input.bookingDates,
        'start_time': input.startTime,
        'end_time': input.endTime,
        'productId': input.productId,
        'quantityCourt': input.quantityCourt,
      };

      log.log('Query GraphQL: $query');
      log.log('Variables: $variables');

      final jsonResponse = await _apiClient.query<List<dynamic>>(
        query,
        variables: variables,
        channelToken: tokenToUse, // Thêm token vào request
        converter: (json) {
          final data = json['data']?['getAvailableCourtForBooking'];
          if (data == null) {
            log.log('Kết quả converter: null hoặc không có dữ liệu');
            return [];
          }

          // Log đầy đủ response
          log.log('Dữ liệu nhận được từ API: $data');
          return data as List<dynamic>;
        },
      );

      if (jsonResponse == null) {
        log.log('Response is null');
        return [];
      }

      log.log('Số phần tử JSON nhận được: ${jsonResponse.length}');

      final result =
          jsonResponse
              .map((item) => AvailableCourForBookingModel.fromJson(item))
              .toList();

      log.log('Số phần tử model đã chuyển đổi: ${result.length}');
      log.log('=== KẾT THÚC REPOSITORY: AVAILABLE COURT FOR BOOKING ===\n');

      return result;
    } on SocketException catch (_) {
      log.log('Lỗi kết nối: No Internet connection');
      throw Exception('No Internet connection');
    } catch (e) {
      log.log('Lỗi trong getAvailableCourForBooking: $e');
      throw Exception('Failed to get available courts: ${e.toString()}');
    }
  }
}
