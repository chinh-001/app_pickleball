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
  final List<BookingDetail> bookingDetails;
  final String price;

  const LoadCompleteBookingData({
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
