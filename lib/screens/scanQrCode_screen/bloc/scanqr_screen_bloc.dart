import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'scanqr_screen_event.dart';
part 'scanqr_screen_state.dart';

class ScanqrScreenBloc extends Bloc<ScanqrScreenEvent, ScanqrScreenState> {
  ScanqrScreenBloc() : super(ScanqrScreenInitial());

  @override
  Stream<ScanqrScreenState> mapEventToState(
    ScanqrScreenEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
