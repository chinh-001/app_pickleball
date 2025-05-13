import '../../models/bookingStatus_model.dart';
import '../../models/bookingList_model.dart';

abstract class IBookingService {
  Future<BookingStatus> getBookingStats({String? channelToken});
  Future<BookingList> getCourtItems({String? channelToken});
}
