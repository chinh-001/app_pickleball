import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_order_retail_step_2_screen_event.dart';
part 'add_order_retail_step_2_screen_state.dart';

class AddOrderRetailStep_2ScreenBloc extends Bloc<AddOrderRetailStep_2ScreenEvent, AddOrderRetailStep_2ScreenState> {
  AddOrderRetailStep_2ScreenBloc() : super(AddOrderRetailStep_2ScreenInitial()) {
    on<AddOrderRetailStep_2ScreenEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
