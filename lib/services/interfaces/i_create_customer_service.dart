import 'package:app_pickleball/models/create_customer_model.dart';

abstract class ICreateCustomerService {
  Future<CreateCustomerResponse> createCustomer({
    required String channelToken,
    required CreateCustomerInput input,
  });
}
