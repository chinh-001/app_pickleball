import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'setting_screen_event.dart';
part 'setting_screen_state.dart';

class SettingScreenBloc extends Bloc<SettingScreenEvent, SettingScreenState> {
  SettingScreenBloc() : super(SettingScreenInitial()) {
    on<SettingScreenEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
