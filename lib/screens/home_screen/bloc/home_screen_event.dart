part of 'home_screen_bloc.dart';

abstract class HomeScreenEvent extends Equatable {
  const HomeScreenEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrdersEvent extends HomeScreenEvent {
  final String? channelToken;

  const FetchOrdersEvent({this.channelToken});

  @override
  List<Object?> get props => [channelToken];
}

class ChangeChannelEvent extends HomeScreenEvent {
  final String channelName;

  const ChangeChannelEvent({required this.channelName});

  @override
  List<Object?> get props => [channelName];
}

class InitializeHomeScreenEvent extends HomeScreenEvent {
  const InitializeHomeScreenEvent();
}

class SyncChannelEvent extends HomeScreenEvent {
  final String channelName;

  const SyncChannelEvent({required this.channelName});

  @override
  List<Object?> get props => [channelName];
}

class FilterByDateRangeEvent extends HomeScreenEvent {
  final List<DateTime> selectedDates;

  const FilterByDateRangeEvent({required this.selectedDates});

  @override
  List<Object?> get props => [selectedDates];
}

class ClearDateFilterEvent extends HomeScreenEvent {
  const ClearDateFilterEvent();
}
