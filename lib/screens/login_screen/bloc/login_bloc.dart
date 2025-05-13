import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_pickleball/enum/CallApiStatus.dart';
import 'package:app_pickleball/services/interfaces/i_auth_service.dart';
import 'package:app_pickleball/models/userAccount_model.dart';
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
      emit(state.copyWith(status: CallApiStatus.loading));

      final user = await _authRepository.login(event.email, event.password);

      if (user != null) {
        emit(state.copyWith(status: CallApiStatus.success, currentUser: user));
      } else {
        emit(state.copyWith(status: CallApiStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(status: CallApiStatus.failure));
    }
  }
}
