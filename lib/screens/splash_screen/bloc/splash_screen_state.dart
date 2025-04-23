part of 'splash_screen_bloc.dart';

abstract class SplashScreenState extends Equatable {
  const SplashScreenState();

  @override
  List<Object> get props => [];
}

// Trạng thái ban đầu của splash screen
class SplashInitialState extends SplashScreenState {}

// Trạng thái hiển thị splash screen
class SplashLoadingState extends SplashScreenState {}

// Trạng thái sẵn sàng để chuyển đến màn hình login
class SplashNavigateToLoginState extends SplashScreenState {}

// Trạng thái sẵn sàng để chuyển đến màn hình trang chủ (đã đăng nhập)
class SplashNavigateToHomeState extends SplashScreenState {}
