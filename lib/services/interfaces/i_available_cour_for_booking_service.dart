import 'package:app_pickleball/models/available_cour_for_booking_model.dart';

abstract class IAvailableCourForBookingService {
  Future<List<AvailableCourForBookingModel>> getAvailableCourForBooking(
    AvailableCourInputModel input,
  );
}
