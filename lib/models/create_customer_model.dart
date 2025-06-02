class CreateCustomerInput {
  final String title;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String emailAddress;

  CreateCustomerInput({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.emailAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
    };
  }
}

class Customer {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String emailAddress;

  Customer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.emailAddress,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      emailAddress: json['emailAddress'] as String,
    );
  }
}

class CreateCustomerResponse {
  final Customer? customer;
  final List<Map<String, dynamic>>? errors;

  CreateCustomerResponse({this.customer, this.errors});

  factory CreateCustomerResponse.fromJson(Map<String, dynamic> json) {
    final createCustomerData = json['createCustomer'];

    if (createCustomerData != null &&
        createCustomerData is Map<String, dynamic>) {
      return CreateCustomerResponse(
        customer: Customer.fromJson(createCustomerData),
      );
    } else if (json.containsKey('errors')) {
      return CreateCustomerResponse(
        errors: List<Map<String, dynamic>>.from(json['errors']),
      );
    }

    return CreateCustomerResponse();
  }

  factory CreateCustomerResponse.empty() {
    return CreateCustomerResponse();
  }

  bool get isSuccess => customer != null;
}
