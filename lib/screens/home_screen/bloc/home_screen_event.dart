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
