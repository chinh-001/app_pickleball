import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/enum/CallApiStatus.dart';
import 'package:app_pickleball/services/interfaces/i_auth_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthService _authRepository;

  LoginBloc({required IAuthService authRepository})
    : _authRepository = authRepository,
      super(const LoginState()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    try {
      final success = await _authRepository.login(event.email, event.password);

      if (success) {
        emit(state.copyWith(status: CallApiStatus.success));
      } else {
        emit(state.copyWith(status: CallApiStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(status: CallApiStatus.failure));
    }
  }
}
