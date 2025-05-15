import '../../models/courtsForProduct_model.dart';

/// Interface cho dịch vụ lấy danh sách sân cho sản phẩm
abstract class ICourtsForProductService {
  /// Lấy danh sách sân cho sản phẩm theo productId
  Future<CourtsForProductResponse> getCourtsForProduct({
    required String productId,
  });
}
