import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:app_pickleball/services/repositories/auth_repository.dart';

part 'splash_screen_event.dart';
part 'splash_screen_state.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  final int splashDuration;
  final AuthRepository _authRepository;

  SplashScreenBloc({this.splashDuration = 3, AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(SplashInitialState()) {
    on<SplashStartedEvent>(_onSplashStarted);
    on<NavigateToLoginEvent>(_onNavigateToLogin);
    on<NavigateToHomeEvent>(_onNavigateToHome);
  }

  void _onSplashStarted(
    SplashStartedEvent event,
    Emitter<SplashScreenState> emit,
  ) async {
    emit(SplashLoadingState());

    // Chờ khoảng thời gian hiển thị splash screen
    await Future.delayed(Duration(seconds: splashDuration));

    // Kiểm tra trạng thái đăng nhập
    final isLoggedIn = await _authRepository.isLoggedIn();
    
    // Điều hướng người dùng dựa trên trạng thái đăng nhập
    if (isLoggedIn) {
      add(NavigateToHomeEvent()); // Đã đăng nhập -> chuyển đến trang chủ
    } else {
      add(NavigateToLoginEvent()); // Chưa đăng nhập -> chuyển đến trang đăng nhập
    }
  }

  void _onNavigateToLogin(
    NavigateToLoginEvent event,
    Emitter<SplashScreenState> emit,
  ) {
    emit(SplashNavigateToLoginState());
  }
  
  void _onNavigateToHome(
    NavigateToHomeEvent event,
    Emitter<SplashScreenState> emit,
  ) {
    emit(SplashNavigateToHomeState());
  }
}
