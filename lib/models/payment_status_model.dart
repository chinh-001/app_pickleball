class PaymentStatusResult {
  final int totalItems;
  final List<PaymentStatus> items;

  PaymentStatusResult({required this.totalItems, required this.items});

  factory PaymentStatusResult.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResult(
      totalItems: json['totalItems'] ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => PaymentStatus.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class PaymentStatus {
  final String id;
  final String name;
  final String code;

  PaymentStatus({required this.id, required this.name, required this.code});

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code};
  }

  @override
  String toString() {
    return 'PaymentStatus(id: $id, name: $name, code: $code)';
  }
}
