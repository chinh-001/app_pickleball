part of 'menu_function_screen_bloc.dart';

abstract class MenuFunctionScreenEvent extends Equatable {
  const MenuFunctionScreenEvent();

  @override
  List<Object> get props => [];
}

class SelectPeriodicBookingEvent extends MenuFunctionScreenEvent {}

class SelectRetailBookingEvent extends MenuFunctionScreenEvent {}

class SelectScanQrCodeEvent extends MenuFunctionScreenEvent {}
