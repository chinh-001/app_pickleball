part of 'add_order_screen_bloc.dart';

 
abstract class AddOrderEvent extends Equatable {
  const AddOrderEvent();

  @override
  List<Object?> get props => [];
}

class AddOrderSubmitEvent extends AddOrderEvent {
  final String customerName;
  final String courtName;
  final String time;
  final String status;
  final String paymentMethod;
  final String bookingType;
  final String note;
  final File? image;

  const AddOrderSubmitEvent({
    required this.customerName,
    required this.courtName,
    required this.time,
    required this.status,
    required this.paymentMethod,
    required this.bookingType,
    required this.note,
    this.image,
  });

  @override
  List<Object?> get props => [
        customerName,
        courtName,
        time,
        status,
        paymentMethod,
        bookingType,
        note,
        image,
      ];
}

class AddOrderPickImageEvent extends AddOrderEvent {}

class AddOrderSelectTimeEvent extends AddOrderEvent {
  final BuildContext context;

  const AddOrderSelectTimeEvent(this.context);

  @override
  List<Object?> get props => [context];
}
