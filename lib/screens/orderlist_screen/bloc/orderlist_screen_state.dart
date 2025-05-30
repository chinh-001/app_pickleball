part of 'orderlist_screen_bloc.dart';

abstract class OrderListScreenState extends Equatable {
  final String selectedChannel;
  final List<String> availableChannels;
  final List<DateTime>? selectedDates;

  const OrderListScreenState({
    required this.selectedChannel,
    required this.availableChannels,
    this.selectedDates,
  });

  @override
  List<Object?> get props => [
    selectedChannel,
    availableChannels,
    selectedDates,
  ];
}

class OrderListScreenInitial extends OrderListScreenState {
  const OrderListScreenInitial({
    String selectedChannel = 'Default channel',
    List<String> availableChannels = const ['Default channel'],
    List<DateTime>? selectedDates,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
         selectedDates: selectedDates,
       );
}

class OrderListScreenLoading extends OrderListScreenState {
  const OrderListScreenLoading({
    required String selectedChannel,
    required List<String> availableChannels,
    List<DateTime>? selectedDates,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
         selectedDates: selectedDates,
       );
}

class OrderListScreenLoaded extends OrderListScreenState {
  final List<Map<String, String>> items;
  final BookingOrderList? bookingOrderList;

  const OrderListScreenLoaded({
    required String selectedChannel,
    required List<String> availableChannels,
    required this.items,
    required this.bookingOrderList,
    List<DateTime>? selectedDates,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
         selectedDates: selectedDates,
       );

  @override
  List<Object?> get props => [
    selectedChannel,
    availableChannels,
    items,
    bookingOrderList,
    selectedDates,
  ];

  OrderListScreenLoaded copyWith({
    String? selectedChannel,
    List<String>? availableChannels,
    List<Map<String, String>>? items,
    BookingOrderList? bookingOrderList,
    List<DateTime>? selectedDates,
  }) {
    return OrderListScreenLoaded(
      selectedChannel: selectedChannel ?? this.selectedChannel,
      availableChannels: availableChannels ?? this.availableChannels,
      items: items ?? this.items,
      bookingOrderList: bookingOrderList ?? this.bookingOrderList,
      selectedDates: selectedDates ?? this.selectedDates,
    );
  }
}

class OrderListScreenError extends OrderListScreenState {
  final String message;

  const OrderListScreenError({
    required this.message,
    required String selectedChannel,
    required List<String> availableChannels,
    List<DateTime>? selectedDates,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
         selectedDates: selectedDates,
       );

  @override
  List<Object?> get props => [
    selectedChannel,
    availableChannels,
    message,
    selectedDates,
  ];
}
