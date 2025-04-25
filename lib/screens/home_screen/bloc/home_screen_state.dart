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
  final BookingList bookingList;
  final BookingStatus bookingStatus;

  const HomeScreenLoaded({
    required this.totalOrders,
    required this.totalSales,
    required this.bookingList,
    required String selectedChannel,
    required List<String> availableChannels,
    required this.bookingStatus,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
       );

  List<Map<String, dynamic>> get items {
    return bookingList.courts.map((court) => court.toJson()).toList();
  }

  @override
  List<Object> get props => [
    totalOrders,
    totalSales,
    bookingList,
    selectedChannel,
    availableChannels,
    bookingStatus,
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
