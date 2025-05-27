class PaymentMethodsResult {
  final int totalItems;
  final List<PaymentMethod> items;

  PaymentMethodsResult({required this.totalItems, required this.items});

  factory PaymentMethodsResult.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsResult(
      totalItems: json['totalItems'] ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => PaymentMethod.fromJson(item))
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

class PaymentMethod {
  final String id;
  final String name;
  final String code;
  final String? description;
  final bool enabled;
  final Map<String, dynamic>? customFields;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.enabled,
    this.customFields,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      enabled: json['enabled'] ?? false,
      customFields: json['customFields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'enabled': enabled,
      'customFields': customFields,
    };
  }

  @override
  String toString() {
    return 'PaymentMethod(id: $id, name: $name, code: $code, enabled: $enabled)';
  }
}
