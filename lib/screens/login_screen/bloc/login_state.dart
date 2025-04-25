part of 'login_bloc.dart';

class LoginState extends Equatable {
  final CallApiStatus status;
  final bool isPasswordVisible;
  final UserAccount? currentUser;

  const LoginState({
    this.status = CallApiStatus.initial,
    this.isPasswordVisible = false,
    this.currentUser,
  });

  LoginState copyWith({
    CallApiStatus? status,
    bool? isPasswordVisible,
    UserAccount? currentUser,
  }) {
    return LoginState(
      status: status ?? this.status,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      currentUser: currentUser ?? this.currentUser,
    );
  }

  @override
  List<Object?> get props => [status, isPasswordVisible, currentUser];
}
