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
    // Tiện ích để chuyển đổi kiểu dữ liệu
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (_) {
          return 0.0;
        }
      }
      return 0.0;
    }

    String _parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    bool _parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    return MultipleBookingsResponse(
      id: _parseString(json['id']),
      createdAt: _parseString(json['createdAt']),
      updatedAt: _parseString(json['updatedAt']),
      code: _parseString(json['code']),
      qrCode: _parseString(json['qr_code']),
      bookingDate: _parseString(json['booking_date']),
      startTime: _parseString(json['start_time']),
      endTime: _parseString(json['end_time']),
      totalPrice: _parseDouble(json['total_price']),
      startDate: _parseString(json['start_date']),
      depositAmount: _parseDouble(json['deposit_amount']),
      depositPaid: _parseBool(json['deposit_paid']),
      endDate: _parseString(json['end_date']),
      noteAdmin: _parseString(json['noteAdmin']),
      noteCustomer: _parseString(json['noteCustomer']),
      hexCode: _parseString(json['hex_code']),
      source: _parseString(json['source']),
      type: _parseString(json['type']),
      paymentMethod: _parseString(json['payment_method']),
      product:
          json['product'] != null
              ? ProductResponse.fromJson(json['product'])
              : ProductResponse(
                id: '',
                createdAt: '',
                updatedAt: '',
                languageCode: '',
                name: '',
                slug: '',
                description: '',
                enabled: false,
              ),
      court:
          json['court'] != null
              ? CourtResponse.fromJson(json['court'])
              : CourtResponse(
                id: '',
                createdAt: '',
                updatedAt: '',
                name: '',
                addressCourt: '',
                phoneCourt: '',
                slug: '',
                description: '',
                startTime: '',
                endTime: '',
                hexCode: '',
                qrCode: '',
                enabled: false,
              ),
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
    String _parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    bool _parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    return ProductResponse(
      id: _parseString(json['id']),
      createdAt: _parseString(json['createdAt']),
      updatedAt: _parseString(json['updatedAt']),
      languageCode: _parseString(json['languageCode']),
      name: _parseString(json['name']),
      slug: _parseString(json['slug']),
      description: _parseString(json['description']),
      enabled: _parseBool(json['enabled']),
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
    String _parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    bool _parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    return CourtResponse(
      id: _parseString(json['id']),
      createdAt: _parseString(json['createdAt']),
      updatedAt: _parseString(json['updatedAt']),
      name: _parseString(json['name']),
      addressCourt: _parseString(json['addressCourt']),
      phoneCourt: _parseString(json['phoneCourt']),
      slug: _parseString(json['slug']),
      description: _parseString(json['description']),
      startTime: _parseString(json['start_time']),
      endTime: _parseString(json['end_time']),
      hexCode: _parseString(json['hex_code']),
      qrCode: _parseString(json['qr_code']),
      enabled: _parseBool(json['enabled']),
    );
  }
}
