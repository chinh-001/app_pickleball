import 'package:app_pickleball/models/payment_status_model.dart';

abstract class IPaymentStatusService {
  Future<PaymentStatusResult> getAllPaymentStatus();
}
