part of 'add_order_screen_bloc.dart';

abstract class AddOrderState extends Equatable {
  const AddOrderState();

  @override
  List<Object?> get props => [];
}

class AddOrderInitial extends AddOrderState {}

class AddOrderLoading extends AddOrderState {}

class AddOrderSuccess extends AddOrderState {}

class AddOrderFailure extends AddOrderState {
  final String error;

  const AddOrderFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AddOrderTimeSelected extends AddOrderState {
  final String time;

  const AddOrderTimeSelected(this.time);

  @override
  List<Object?> get props => [time];
}
