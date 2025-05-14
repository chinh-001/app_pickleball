import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as log;
import 'package:app_pickleball/services/repositories/work_time_repository.dart';
import 'package:app_pickleball/services/repositories/choose_repository.dart';

part 'menu_function_screen_event.dart';
part 'menu_function_screen_state.dart';

class MenuFunctionScreenBloc
    extends Bloc<MenuFunctionScreenEvent, MenuFunctionScreenState> {
  final WorkTimeRepository _workTimeRepository;
  final ChooseRepository _chooseRepository;

  MenuFunctionScreenBloc({
    WorkTimeRepository? workTimeRepository,
    ChooseRepository? chooseRepository,
  }) : _workTimeRepository = workTimeRepository ?? WorkTimeRepository(),
       _chooseRepository = chooseRepository ?? ChooseRepository(),
       super(MenuFunctionScreenInitial()) {
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
  ) async {
    try {
      // Emit loading state
      emit(MenuFunctionScreenLoading());

      // Call WorkTimeRepository's API
      final workTimeResult = await _workTimeRepository.getStartAndEndTime();
      log.log('Work Time API result: $workTimeResult');

      // Call ChooseRepository's API
      final productsResult = await _chooseRepository.getProductsWithCourts();
      log.log('Products with Courts API result: $productsResult');

      emit(RetailBookingSelectedState());
    } catch (e) {
      log.log('Error fetching data: $e');
      emit(RetailBookingSelectedState());
    }
  }
}
