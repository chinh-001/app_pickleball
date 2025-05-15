class AvailableCourForBookingModel {
  final String bookingDate;
  final List<Court> courts;

  AvailableCourForBookingModel({
    required this.bookingDate,
    required this.courts,
  });

  factory AvailableCourForBookingModel.fromJson(Map<String, dynamic> json) {
    return AvailableCourForBookingModel(
      bookingDate: json['bookingDate'] ?? '',
      courts:
          json['courts'] != null
              ? List<Court>.from(
                json['courts'].map((court) => Court.fromJson(court)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingDate': bookingDate,
      'courts': courts.map((court) => court.toJson()).toList(),
    };
  }
}

class Court {
  final String id;
  final String name;
  final String status;
  final double price;
  final String startTime;
  final String endTime;

  Court({
    required this.id,
    required this.name,
    required this.status,
    required this.price,
    required this.startTime,
    required this.endTime,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'price': price,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class AvailableCourInputModel {
  final List<String> bookingDates;
  final String startTime;
  final String endTime;
  final String productId;
  final int quantityCourt;

  AvailableCourInputModel({
    required this.bookingDates,
    required this.startTime,
    required this.endTime,
    required this.productId,
    required this.quantityCourt,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingDates': bookingDates,
      'start_time': startTime,
      'end_time': endTime,
      'productId': productId,
      'quantityCourt': quantityCourt,
    };
  }
}
