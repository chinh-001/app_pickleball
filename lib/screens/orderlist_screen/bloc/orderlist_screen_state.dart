part of 'orderlist_screen_bloc.dart';

abstract class OrderListState extends Equatable {
  const OrderListState();

  @override
  List<Object?> get props => [];
}

class OrderListInitial extends OrderListState {}

class OrderListLoading extends OrderListState {}

class OrderListLoaded extends OrderListState {
  final List<Map<String, String>> items;

  const OrderListLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class OrderListError extends OrderListState {
  final String error;

  const OrderListError(this.error);

  @override
  List<Object?> get props => [error];
}
