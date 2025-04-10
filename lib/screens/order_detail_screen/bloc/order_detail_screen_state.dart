part of 'order_detail_screen_bloc.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {}

class StatusUpdatedState extends OrderDetailState {
  final String status;

  const StatusUpdatedState(this.status);

  @override
  List<Object?> get props => [status];
}

class PaymentStatusUpdatedState extends OrderDetailState {
  final String paymentStatus;

  const PaymentStatusUpdatedState(this.paymentStatus);

  @override
  List<Object?> get props => [paymentStatus];
}

class TimeSelectedState extends OrderDetailState {
  final String time;

  const TimeSelectedState(this.time);

  @override
  List<Object?> get props => [time];
}

class ImagePickedState extends OrderDetailState {
  final File image;

  const ImagePickedState(this.image);

  @override
  List<Object?> get props => [image];
}

class OrderDetailSuccess extends OrderDetailState {}

class OrderDetailFailure extends OrderDetailState {
  final String error;

  const OrderDetailFailure(this.error);

  @override
  List<Object?> get props => [error];
}
