part of 'home_screen_bloc.dart';

abstract class HomeScreenState extends Equatable {
  final String selectedChannel;
  final List<String> availableChannels;

  const HomeScreenState({
    this.selectedChannel = 'Default channel',
    this.availableChannels = const [],
  });

  @override
  List<Object> get props => [selectedChannel, availableChannels];
}

class HomeScreenInitial extends HomeScreenState {
  const HomeScreenInitial() : super();
}

class HomeScreenLoading extends HomeScreenState {
  const HomeScreenLoading({
    required String selectedChannel,
    required List<String> availableChannels,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
       );
}

class HomeScreenLoaded extends HomeScreenState {
  final int totalOrders;
  final double totalSales;
  final List<Map<String, dynamic>> items;

  const HomeScreenLoaded({
    required this.totalOrders,
    required this.totalSales,
    required this.items,
    required String selectedChannel,
    required List<String> availableChannels,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
       );

  @override
  List<Object> get props => [
    totalOrders,
    totalSales,
    items,
    selectedChannel,
    availableChannels,
  ];
}

class HomeScreenError extends HomeScreenState {
  final String message;

  const HomeScreenError({
    required this.message,
    required String selectedChannel,
    required List<String> availableChannels,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
       );

  @override
  List<Object> get props => [message, selectedChannel, availableChannels];
}
