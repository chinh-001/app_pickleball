import 'dart:convert';

/// Đại diện cho response của API getCourtsForProduct
class CourtsForProductResponse {
  /// Danh sách các sân cho sản phẩm
  final List<CourtItem> courts;

  /// Constructor với các tham số bắt buộc
  CourtsForProductResponse({required this.courts});

  /// Tạo từ JSON response
  factory CourtsForProductResponse.fromJson(Map<String, dynamic> json) {
    return CourtsForProductResponse(
      courts:
          (json['getCourtsForProduct'] as List<dynamic>)
              .map((item) => CourtItem.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }

  /// Chuyển đổi model thành Map
  Map<String, dynamic> toMap() => {
    'courts': courts.map((court) => court.toMap()).toList(),
  };

  /// Chuyển đổi model thành chuỗi JSON
  String toJson() => json.encode(toMap());

  @override
  String toString() => 'CourtsForProductResponse(courts: ${courts.length})';
}

/// Thông tin cơ bản của sân từ API
class CourtItem {
  /// ID của sân
  final String id;

  /// Tên của sân
  final String name;

  /// Constructor với các tham số bắt buộc
  CourtItem({required this.id, required this.name});

  /// Tạo từ JSON response
  factory CourtItem.fromJson(Map<String, dynamic> json) =>
      CourtItem(id: json['id'] as String, name: json['name'] as String);

  /// Chuyển đổi model thành Map
  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  /// Chuyển đổi model thành chuỗi JSON
  String toJson() => json.encode(toMap());

  @override
  String toString() => 'CourtItem(id: $id, name: $name)';
}
