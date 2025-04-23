part of 'splash_screen_bloc.dart';

abstract class SplashScreenEvent extends Equatable {
  const SplashScreenEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện bắt đầu splash screen
class SplashStartedEvent extends SplashScreenEvent {}

// Sự kiện chuyển đến màn hình đăng nhập
class NavigateToLoginEvent extends SplashScreenEvent {}

// Sự kiện chuyển đến màn hình trang chủ (đã đăng nhập)
class NavigateToHomeEvent extends SplashScreenEvent {}
