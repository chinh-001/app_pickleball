import '../interfaces/i_work_time_service.dart';
import '../api/api_client.dart';
import 'dart:developer' as log;
import '../../models/workTime_model.dart';

class WorkTimeRepository implements IWorkTimeService {
  final ApiClient _apiClient;

  WorkTimeRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<WorkTimeModel> getStartAndEndTime() async {
    const String query = '''
      query GetStartAndEndTime {
        getStartAndEndTime {
          end_time
          start_time
        }
      }
    ''';

    try {
      final jsonResponse = await _apiClient.query<Map<String, dynamic>>(
        query,
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

      return WorkTimeModel.fromJson(workTimeData);
    } catch (e) {
      log.log('Error fetching work time: $e');
      throw Exception('Failed to get work time: ${e.toString()}');
    }
  }
}
