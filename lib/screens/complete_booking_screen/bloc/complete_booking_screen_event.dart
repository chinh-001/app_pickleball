part of 'complete_booking_screen_bloc.dart';

abstract class CompleteBookingScreenEvent extends Equatable {
  const CompleteBookingScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadCompleteBookingData extends CompleteBookingScreenEvent {
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String bookingCode;
  final String court;
  final String bookingTime;
  final String bookingDate;
  final String price;

  const LoadCompleteBookingData({
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.bookingCode,
    required this.court,
    required this.bookingTime,
    required this.bookingDate,
    required this.price,
  });

  @override
  List<Object> get props => [
    customerName,
    customerEmail,
    customerPhone,
    bookingCode,
    court,
    bookingTime,
    bookingDate,
    price,
  ];
}
