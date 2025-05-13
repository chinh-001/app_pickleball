part of 'menu_function_screen_bloc.dart';

abstract class MenuFunctionScreenState extends Equatable {
  const MenuFunctionScreenState();

  @override
  List<Object> get props => [];
}

class MenuFunctionScreenInitial extends MenuFunctionScreenState {}

class PeriodicBookingSelectedState extends MenuFunctionScreenState {}

class RetailBookingSelectedState extends MenuFunctionScreenState {}
