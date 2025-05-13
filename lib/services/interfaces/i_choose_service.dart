import '../../models/product_with_courts_model.dart';

abstract class IChooseService {
  Future<ProductsWithCourtsResponse> getProductsWithCourts();
}
