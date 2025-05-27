import 'package:app_pickleball/models/payment_methods_model.dart';

abstract class IPaymentMethodsService {
  Future<PaymentMethodsResult> getPaymentMethods();
}
