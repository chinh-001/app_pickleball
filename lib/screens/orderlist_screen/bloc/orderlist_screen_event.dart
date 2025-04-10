part of 'orderlist_screen_bloc.dart';

abstract class OrderListEvent extends Equatable {
  const OrderListEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderListEvent extends OrderListEvent {}

class SearchOrderListEvent extends OrderListEvent {
  final String query;

  const SearchOrderListEvent(this.query);

  @override
  List<Object?> get props => [query];
}
