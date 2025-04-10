part of 'home_screen_bloc.dart';

abstract class HomeScreenState extends Equatable {
  const HomeScreenState();

  @override
  List<Object> get props => [];
}

class HomeScreenInitial extends HomeScreenState {}

class HomeScreenLoading extends HomeScreenState {}

class HomeScreenLoaded extends HomeScreenState {
  final int totalOrders;
  final double totalSales;
  final List<Map<String, dynamic>> items;

  const HomeScreenLoaded({
    required this.totalOrders,
    required this.totalSales,
    required this.items,
  });

  @override
  List<Object> get props => [totalOrders, totalSales, items];
}

class HomeScreenError extends HomeScreenState {
  final String message;

  const HomeScreenError(this.message);

  @override
  List<Object> get props => [message];
}
