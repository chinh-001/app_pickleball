part of 'orderlist_screen_bloc.dart';

abstract class OrderListScreenState extends Equatable {
  final String selectedChannel;
  final List<String> availableChannels;

  const OrderListScreenState({
    required this.selectedChannel,
    required this.availableChannels,
  });

  @override
  List<Object> get props => [selectedChannel, availableChannels];
}

class OrderListScreenInitial extends OrderListScreenState {
  const OrderListScreenInitial({
    required super.selectedChannel,
    required super.availableChannels,
  });
}

class OrderListScreenLoading extends OrderListScreenState {
  const OrderListScreenLoading({
    required super.selectedChannel,
    required super.availableChannels,
  });
}

class OrderListScreenLoaded extends OrderListScreenState {
  final List<Map<String, String>> items;
  final Map<String, dynamic>? bookingData;

  const OrderListScreenLoaded({
    required super.selectedChannel,
    required super.availableChannels,
    required this.items,
    this.bookingData,
  });

  @override
  List<Object> get props => [
    selectedChannel,
    availableChannels,
    items,
    bookingData ?? {},
  ];
}

class OrderListScreenError extends OrderListScreenState {
  final String message;

  const OrderListScreenError({
    required super.selectedChannel,
    required super.availableChannels,
    required this.message,
  });

  @override
  List<Object> get props => [selectedChannel, availableChannels, message];
}
