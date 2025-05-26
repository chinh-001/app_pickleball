part of 'home_screen_bloc.dart';

abstract class HomeScreenState extends Equatable {
  final String selectedChannel;
  final List<String> availableChannels;
  final List<DateTime>? selectedDates;

  const HomeScreenState({
    this.selectedChannel = 'Default channel',
    this.availableChannels = const ['Default channel'],
    this.selectedDates,
  });

  @override
  List<Object> get props => [
    selectedChannel,
    availableChannels,
    selectedDates ?? [],
  ];
}

class HomeScreenInitial extends HomeScreenState {
  const HomeScreenInitial() : super();
}

class HomeScreenLoading extends HomeScreenState {
  const HomeScreenLoading({
    required String selectedChannel,
    required List<String> availableChannels,
    List<DateTime>? selectedDates,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
         selectedDates: selectedDates,
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
    List<DateTime>? selectedDates,
  }) : super(
         selectedChannel: selectedChannel,
         availableChannels: availableChannels,
         selectedDates: selectedDates,
       );

  List<Map<String, dynamic>> get items {
    return bookingList.courts;
  }

  @override
  List<Object> get props => [
    totalOrders,
    totalSales,
    bookingList,
    selectedChannel,
    availableChannels,
    bookingStatus,
    selectedDates ?? [],
  ];
}

class HomeScreenError extends HomeScreenState {
  final String message;

  const HomeScreenError({
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
  List<Object> get props => [
    message,
    selectedChannel,
    availableChannels,
    selectedDates ?? [],
  ];
}
