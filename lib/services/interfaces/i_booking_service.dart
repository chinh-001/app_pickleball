import '../../model/bookingStatus_model.dart';
import '../../model/bookingList_model.dart';

abstract class IBookingService {
  Future<BookingStatus> getBookingStats({String? channelToken});
  Future<BookingList> getCourtItems({String? channelToken});
}
