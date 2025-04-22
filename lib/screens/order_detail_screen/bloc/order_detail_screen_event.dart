part of 'order_detail_screen_bloc.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class UpdateStatusEvent extends OrderDetailEvent {
  final String status;

  const UpdateStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class UpdatePaymentStatusEvent extends OrderDetailEvent {
  final String paymentStatus;

  const UpdatePaymentStatusEvent(this.paymentStatus);

  @override
  List<Object?> get props => [paymentStatus];
}

class PickImageEvent extends OrderDetailEvent {}

class SelectTimeEvent extends OrderDetailEvent {
  final BuildContext context;

  const SelectTimeEvent(this.context);

  @override
  List<Object?> get props => [context];
}

class SubmitOrderDetailEvent extends OrderDetailEvent {
  final String customerName;
  final String courtName;
  final String time;
  final String status;
  final String paymentStatus;
  final String note;
  final String phoneNumber;
  final String emailAddress;
  final String totalPrice;

  const SubmitOrderDetailEvent({
    required this.customerName,
    required this.courtName,
    required this.time,
    required this.status,
    required this.paymentStatus,
    required this.note,
    this.phoneNumber = '',
    this.emailAddress = '',
    this.totalPrice = '',
  });

  @override
  List<Object?> get props => [
    customerName,
    courtName,
    time,
    status,
    paymentStatus,
    note,
    phoneNumber,
    emailAddress,
    totalPrice,
  ];
}
