import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'menu_function_screen_event.dart';
part 'menu_function_screen_state.dart';

class MenuFunctionScreenBloc
    extends Bloc<MenuFunctionScreenEvent, MenuFunctionScreenState> {
  MenuFunctionScreenBloc() : super(MenuFunctionScreenInitial()) {
    on<SelectPeriodicBookingEvent>(_onSelectPeriodicBooking);
    on<SelectRetailBookingEvent>(_onSelectRetailBooking);
  }

  void _onSelectPeriodicBooking(
    SelectPeriodicBookingEvent event,
    Emitter<MenuFunctionScreenState> emit,
  ) {
    emit(PeriodicBookingSelectedState());
  }

  void _onSelectRetailBooking(
    SelectRetailBookingEvent event,
    Emitter<MenuFunctionScreenState> emit,
  ) {
    emit(RetailBookingSelectedState());
  }
}
