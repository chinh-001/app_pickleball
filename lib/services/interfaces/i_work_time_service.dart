import '../../models/workTime_model.dart';

abstract class IWorkTimeService {
  Future<WorkTimeModel> getStartAndEndTime({String? channelToken});
}
