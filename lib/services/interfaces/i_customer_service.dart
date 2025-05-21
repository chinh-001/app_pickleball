import 'package:app_pickleball/models/customer_model.dart';

abstract class ICustomerService {
  Future<CustomerResponse> getCustomers({required String channelToken});
}
