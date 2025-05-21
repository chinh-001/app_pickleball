import 'dart:convert';

class CustomerResponse {
  final int totalItems;
  final List<Customer> items;

  CustomerResponse({required this.totalItems, required this.items});

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      totalItems: json['customers']['totalItems'] ?? 0,
      items:
          (json['customers']['items'] as List<dynamic>?)
              ?.map((item) => Customer.fromJson(item))
              .toList() ??
          [],
    );
  }

  factory CustomerResponse.empty() {
    return CustomerResponse(totalItems: 0, items: []);
  }
}

class Customer {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? title;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? emailAddress;

  Customer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.emailAddress,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      title: json['title'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'],
      emailAddress: json['emailAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'title': title,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
    };
  }

  String get fullName {
    final titleStr = title != null && title!.isNotEmpty ? '$title ' : '';
    return '$titleStr$firstName $lastName'.trim();
  }

  @override
  String toString() {
    return 'Customer{id: $id, name: $fullName, phone: $phoneNumber, email: $emailAddress}';
  }
}
