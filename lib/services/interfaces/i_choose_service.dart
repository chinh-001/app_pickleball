import '../../models/productWithCourts_Model.dart';

abstract class IChooseService {
  Future<ProductsWithCourtsResponse> getProductsWithCourts({
    String? channelToken,
  });
}
