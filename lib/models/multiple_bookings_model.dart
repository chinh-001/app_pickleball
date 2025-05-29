import 'dart:convert';

class MultipleBookingsInput {
  final List<BookingInput> bookings;

  MultipleBookingsInput({required this.bookings});

  Map<String, dynamic> toJson() => {
    'bookings': bookings.map((booking) => booking.toJson()).toList(),
  };

  factory MultipleBookingsInput.fromJson(Map<String, dynamic> json) {
    return MultipleBookingsInput(
      bookings:
          (json['bookings'] as List)
              .map((booking) => BookingInput.fromJson(booking))
              .toList(),
    );
  }
}

class BookingInput {
  final String startTime;
  final String product;
  final String endTime;
  final double totalPrice;
  final String paymentStatus;
  final String bookingDate;
  final String court;
  final String paymentMethod;
  final String status;
  final String customer;

  BookingInput({
    required this.startTime,
    required this.product,
    required this.endTime,
    required this.totalPrice,
    required this.paymentStatus,
    required this.bookingDate,
    required this.court,
    required this.paymentMethod,
    required this.status,
    required this.customer,
  });

  Map<String, dynamic> toJson() => {
    'start_time': startTime,
    'product': product,
    'end_time': endTime,
    'total_price': totalPrice,
    'paymentstatus': paymentStatus,
    'booking_date': bookingDate,
    'court': court,
    'payment_method': paymentMethod,
    'status': status,
    'customer': customer,
  };

  factory BookingInput.fromJson(Map<String, dynamic> json) {
    return BookingInput(
      startTime: json['start_time'],
      product: json['product'],
      endTime: json['end_time'],
      totalPrice: json['total_price'],
      paymentStatus: json['paymentstatus'],
      bookingDate: json['booking_date'],
      court: json['court'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      customer: json['customer'],
    );
  }
}

class MultipleBookingsResponse {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String code;
  final String qrCode;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final double totalPrice;
  final String startDate;
  final double depositAmount;
  final bool depositPaid;
  final String endDate;
  final String noteAdmin;
  final String noteCustomer;
  final String hexCode;
  final String source;
  final String type;
  final String paymentMethod;
  final ProductResponse product;
  final CourtResponse court;

  MultipleBookingsResponse({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.code,
    required this.qrCode,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.startDate,
    required this.depositAmount,
    required this.depositPaid,
    required this.endDate,
    required this.noteAdmin,
    required this.noteCustomer,
    required this.hexCode,
    required this.source,
    required this.type,
    required this.paymentMethod,
    required this.product,
    required this.court,
  });

  factory MultipleBookingsResponse.fromJson(Map<String, dynamic> json) {
    return MultipleBookingsResponse(
      id: json['id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      code: json['code'],
      qrCode: json['qr_code'],
      bookingDate: json['booking_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalPrice: json['total_price'],
      startDate: json['start_date'],
      depositAmount: json['deposit_amount'],
      depositPaid: json['deposit_paid'],
      endDate: json['end_date'],
      noteAdmin: json['noteAdmin'],
      noteCustomer: json['noteCustomer'],
      hexCode: json['hex_code'],
      source: json['source'],
      type: json['type'],
      paymentMethod: json['payment_method'],
      product: ProductResponse.fromJson(json['product']),
      court: CourtResponse.fromJson(json['court']),
    );
  }
}

class ProductResponse {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String languageCode;
  final String name;
  final String slug;
  final String description;
  final bool enabled;

  ProductResponse({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.languageCode,
    required this.name,
    required this.slug,
    required this.description,
    required this.enabled,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      languageCode: json['languageCode'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      enabled: json['enabled'],
    );
  }
}

class CourtResponse {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String name;
  final String addressCourt;
  final String phoneCourt;
  final String slug;
  final String description;
  final String startTime;
  final String endTime;
  final String hexCode;
  final String qrCode;
  final bool enabled;

  CourtResponse({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.addressCourt,
    required this.phoneCourt,
    required this.slug,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.hexCode,
    required this.qrCode,
    required this.enabled,
  });

  factory CourtResponse.fromJson(Map<String, dynamic> json) {
    return CourtResponse(
      id: json['id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      name: json['name'],
      addressCourt: json['addressCourt'],
      phoneCourt: json['phoneCourt'],
      slug: json['slug'],
      description: json['description'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      hexCode: json['hex_code'],
      qrCode: json['qr_code'],
      enabled: json['enabled'],
    );
  }
}
