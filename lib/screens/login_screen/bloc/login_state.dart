part of 'login_bloc.dart';

class LoginState extends Equatable {
  final CallApiStatus status;
  final bool isPasswordVisible;

  const LoginState({
    this.status = CallApiStatus.initial,
    this.isPasswordVisible = false,
  });

  LoginState copyWith({CallApiStatus? status, bool? isPasswordVisible}) {
    return LoginState(
      status: status ?? this.status,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

  @override
  List<Object?> get props => [status, isPasswordVisible];
}
