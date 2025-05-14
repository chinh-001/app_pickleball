import '../interfaces/i_work_time_service.dart';
import '../api/api_client.dart';
import '../channel_sync_service.dart';
import '../repositories/userPermissions_repository.dart';
import 'dart:developer' as log;
import '../../models/workTime_model.dart';

class WorkTimeRepository implements IWorkTimeService {
  final ApiClient _apiClient;
  final ChannelSyncService _channelSyncService = ChannelSyncService.instance;
  final UserPermissionsRepository _permissionsRepository;

  WorkTimeRepository({
    ApiClient? apiClient,
    UserPermissionsRepository? permissionsRepository,
  }) : _apiClient = apiClient ?? ApiClient.instance,
       _permissionsRepository =
           permissionsRepository ?? UserPermissionsRepository();

  @override
  Future<WorkTimeModel> getStartAndEndTime({String? channelToken}) async {
    const String query = '''
      query GetStartAndEndTime {
        getStartAndEndTime {
          end_time
          start_time
        }
      }
    ''';

    try {
      // If no channelToken provided, get it from the selected channel
      String tokenToUse = channelToken ?? '';

      if (tokenToUse.isEmpty) {
        // Get the currently selected channel from ChannelSyncService
        final selectedChannel = _channelSyncService.selectedChannel;
        log.log('Getting workTime for channel: $selectedChannel');

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

      log.log('Querying getStartAndEndTime with channel token: $tokenToUse');

      final jsonResponse = await _apiClient.query<Map<String, dynamic>>(
        query,
        channelToken: tokenToUse,
        converter: (json) => json,
      );

      if (jsonResponse == null) {
        log.log('Response is null for getStartAndEndTime');
        throw Exception('No data returned from getStartAndEndTime query');
      }

      final data = jsonResponse['data'];
      if (data == null) {
        log.log('Data is null for getStartAndEndTime');
        throw Exception('No data returned from getStartAndEndTime query');
      }

      final workTimeData = data['getStartAndEndTime'];
      if (workTimeData == null) {
        throw Exception('No getStartAndEndTime field in response data');
      }

      final result = WorkTimeModel.fromJson(workTimeData);
      log.log('Got work time for channel token $tokenToUse: $result');
      return result;
    } catch (e) {
      log.log('Error fetching work time: $e');
      throw Exception('Failed to get work time: ${e.toString()}');
    }
  }
}
