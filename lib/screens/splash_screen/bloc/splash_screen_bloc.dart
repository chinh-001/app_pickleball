import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';

part 'splash_screen_event.dart';
part 'splash_screen_state.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  final int splashDuration;

  SplashScreenBloc({this.splashDuration = 3}) : super(SplashInitialState()) {
    on<SplashStartedEvent>(_onSplashStarted);
    on<NavigateToLoginEvent>(_onNavigateToLogin);
  }

  void _onSplashStarted(
    SplashStartedEvent event,
    Emitter<SplashScreenState> emit,
  ) async {
    emit(SplashLoadingState());

    // Chờ khoảng thời gian hiển thị splash screen
    await Future.delayed(Duration(seconds: splashDuration));

    // Kích hoạt sự kiện chuyển đến màn hình login
    add(NavigateToLoginEvent());
  }

  void _onNavigateToLogin(
    NavigateToLoginEvent event,
    Emitter<SplashScreenState> emit,
  ) {
    emit(SplashNavigateToLoginState());
  }
}
