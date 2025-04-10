part of 'login_bloc.dart';

class LoginState extends Equatable {
  final CallApiStatus status;

  const LoginState({
    this.status = CallApiStatus.initial,
  });

  LoginState copyWith({
    CallApiStatus? status,
  }) {
    return LoginState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}