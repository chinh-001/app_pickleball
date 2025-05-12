import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'menu_function_screen_event.dart';
part 'menu_function_screen_state.dart';

class MenuFunctionScreenBloc extends Bloc<MenuFunctionScreenEvent, MenuFunctionScreenState> {
  MenuFunctionScreenBloc() : super(MenuFunctionScreenInitial());

  @override
  Stream<MenuFunctionScreenState> mapEventToState(
    MenuFunctionScreenEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
