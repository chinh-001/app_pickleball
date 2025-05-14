import 'dart:convert';

/// Đại diện cho response của API getProductsWithCourts
class ProductsWithCourtsResponse {
  /// Tổng số sản phẩm có sẵn
  final int totalItems;

  /// Danh sách các sản phẩm
  final List<ProductItem> items;

  /// Constructor với các tham số bắt buộc
  ProductsWithCourtsResponse({required this.totalItems, required this.items});

  /// Tạo từ JSON response
  factory ProductsWithCourtsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsWithCourtsResponse(
      totalItems: json['totalItems'] as int,
      items:
          (json['items'] as List<dynamic>)
              .map((item) => ProductItem.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }

  /// Chuyển đổi model thành Map
  Map<String, dynamic> toMap() => {
    'totalItems': totalItems,
    'items': items.map((item) => item.toMap()).toList(),
  };

  /// Chuyển đổi model thành chuỗi JSON
  String toJson() => json.encode(toMap());

  @override
  String toString() => 'ProductsWithCourtsResponse(totalItems: $totalItems)';
}

/// Thông tin cơ bản của sản phẩm từ API
class ProductItem {
  /// ID của sản phẩm
  final String id;

  /// Tên của sản phẩm
  final String name;

  /// Constructor với các tham số bắt buộc
  ProductItem({required this.id, required this.name});

  /// Tạo từ JSON response
  factory ProductItem.fromJson(Map<String, dynamic> json) =>
      ProductItem(id: json['id'] as String, name: json['name'] as String);

  /// Chuyển đổi model thành Map
  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  /// Chuyển đổi model thành chuỗi JSON
  String toJson() => json.encode(toMap());

  @override
  String toString() => 'ProductItem(id: $id, name: $name)';
}
