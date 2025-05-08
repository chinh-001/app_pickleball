import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'add_order_retail_step_1_screen_event.dart';
part 'add_order_retail_step_1_screen_state.dart';

class AddOrderRetailStep_1ScreenBloc
    extends
        Bloc<AddOrderRetailStep_1ScreenEvent, AddOrderRetailStep_1ScreenState> {
  AddOrderRetailStep_1ScreenBloc() : super(AddOrderRetailStep_1ScreenInitial());

  @override
  Stream<AddOrderRetailStep_1ScreenState> mapEventToState(
    AddOrderRetailStep_1ScreenEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
