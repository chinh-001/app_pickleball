part of 'orderlist_screen_bloc.dart';

abstract class OrderListScreenState extends Equatable {
  final String selectedChannel;
  final List<String> availableChannels;

  const OrderListScreenState({
    this.selectedChannel = 'Default channel',
    this.availableChannels = const ['Default channel'],
  });

  @override
  List<Object> get props => [selectedChannel, availableChannels];
}

class OrderListScreenInitial extends OrderListScreenState {
  const OrderListScreenInitial({
    String selectedChannel = 'Default channel',
    List<String> availableChannels = const ['Default channel'],
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
       );
}

class OrderListScreenLoading extends OrderListScreenState {
  const OrderListScreenLoading({
    required super.selectedChannel,
    required super.availableChannels,
  });
}

class OrderListScreenLoaded extends OrderListScreenState {
  final List<Map<String, String>> items;
  final BookingOrderList? bookingOrderList;

  const OrderListScreenLoaded({
    required super.selectedChannel,
    required super.availableChannels,
    required this.items,
    this.bookingOrderList,
  });

  @override
  List<Object> get props => [
    selectedChannel,
    availableChannels,
    items,
    if (bookingOrderList != null) bookingOrderList!,
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
