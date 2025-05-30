part of 'orderlist_screen_bloc.dart';

abstract class OrderListScreenEvent extends Equatable {
  const OrderListScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadOrderListEvent extends OrderListScreenEvent {
  final String channelToken;

  const LoadOrderListEvent({this.channelToken = ''});

  @override
  List<Object> get props => [channelToken];
}

class SearchOrderListEvent extends OrderListScreenEvent {
  final String query;

  const SearchOrderListEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ChangeChannelEvent extends OrderListScreenEvent {
  final String channelName;

  const ChangeChannelEvent({required this.channelName});

  @override
  List<Object> get props => [channelName];
}

class FetchBookingsEvent extends OrderListScreenEvent {
  final String channelToken;
  final DateTime date;

  const FetchBookingsEvent({required this.channelToken, required this.date});

  @override
  List<Object> get props => [channelToken, date];
}

class InitializeOrderListScreenEvent extends OrderListScreenEvent {}

class SyncChannelEvent extends OrderListScreenEvent {
  final String channelName;

  const SyncChannelEvent({required this.channelName});

  @override
  List<Object> get props => [channelName];
}

class FilterByDateRangeEvent extends OrderListScreenEvent {
  final List<DateTime> selectedDates;

  const FilterByDateRangeEvent({required this.selectedDates});

  @override
  List<Object> get props => [selectedDates];
}

class ClearDateFilterEvent extends OrderListScreenEvent {
  const ClearDateFilterEvent();
}
