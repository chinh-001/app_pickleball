part of 'complete_booking_screen_bloc.dart';

abstract class CompleteBookingScreenState extends Equatable {
  const CompleteBookingScreenState();

  @override
  List<Object> get props => [];
}

class CompleteBookingScreenInitial extends CompleteBookingScreenState {}

class CompleteBookingScreenLoaded extends CompleteBookingScreenState {
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<BookingDetail> bookingDetails;
  final String price;

  const CompleteBookingScreenLoaded({
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.bookingDetails,
    required this.price,
  });

  @override
  List<Object> get props => [
    customerName,
    customerEmail,
    customerPhone,
    bookingDetails,
    price,
  ];
}

class BookingDetail {
  final String court;
  final String bookingTime;
  final String bookingDate;
  final String price;
  final String bookingCode;

  const BookingDetail({
    required this.court,
    required this.bookingTime,
    required this.bookingDate,
    required this.price,
    required this.bookingCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingDetail &&
          runtimeType == other.runtimeType &&
          court == other.court &&
          bookingTime == other.bookingTime &&
          bookingDate == other.bookingDate &&
          price == other.price &&
          bookingCode == other.bookingCode;

  @override
  int get hashCode =>
      court.hashCode ^
      bookingTime.hashCode ^
      bookingDate.hashCode ^
      price.hashCode ^
      bookingCode.hashCode;
}
