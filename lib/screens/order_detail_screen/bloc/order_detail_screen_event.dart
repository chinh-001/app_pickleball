part of 'order_detail_screen_bloc.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class InitializeOrderDetailEvent extends OrderDetailEvent {
  final Map<String, String> orderData;
  final BuildContext context;

  const InitializeOrderDetailEvent({
    required this.orderData,
    required this.context,
  });

  @override
  List<Object?> get props => [orderData, context];
}

class UpdateTypeEvent extends OrderDetailEvent {
  final String type;

  const UpdateTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
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

class FormatPriceEvent extends OrderDetailEvent {
  final String price;
  final BuildContext context;

  const FormatPriceEvent(this.price, this.context);

  @override
  List<Object?> get props => [price, context];
}

class PickImageEvent extends OrderDetailEvent {}

class SelectTimeEvent extends OrderDetailEvent {
  final BuildContext context;

  const SelectTimeEvent(this.context);

  @override
  List<Object?> get props => [context];
}

class TranslateValuesForUIEvent extends OrderDetailEvent {
  final BuildContext context;
  final String type;
  final String status;
  final String paymentStatus;

  const TranslateValuesForUIEvent({
    required this.context,
    required this.type,
    required this.status,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [context, type, status, paymentStatus];
}

class TranslateValuesForSubmitEvent extends OrderDetailEvent {
  final BuildContext context;
  final String type;
  final String status;
  final String paymentStatus;
  final String? timeToSubmit;

  const TranslateValuesForSubmitEvent({
    required this.context,
    required this.type,
    required this.status,
    required this.paymentStatus,
    this.timeToSubmit,
  });

  @override
  List<Object?> get props => [
    context,
    type,
    status,
    paymentStatus,
    timeToSubmit,
  ];
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
