import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../services/repositories/administrator_repository.dart';
import '../../../services/repositories/auth_repository.dart';
import 'dart:developer' as log;

part 'profile_screen_event.dart';
part 'profile_screen_state.dart';

class ProfileScreenBloc extends Bloc<ProfileScreenEvent, ProfileScreenState> {
  final AdministratorRepository _administratorRepository;
  final AuthRepository _authRepository;

  ProfileScreenBloc({
    AdministratorRepository? administratorRepository,
    AuthRepository? authRepository,
  }) : _administratorRepository =
           administratorRepository ?? AdministratorRepository(),
       _authRepository = authRepository ?? AuthRepository(),
       super(ProfileReadOnlyState(name: '', email: '')) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<EnableEditEvent>(_onEnableEdit);
    on<SaveInfoEvent>(_onSaveInfo);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfileScreenState> emit,
  ) async {
    try {
      log.log('Processing logout...');
      final success = await _authRepository.logout();
      if (success) {
        log.log('Logout successful');
        emit(ProfileLoggedOutState());
      } else {
        log.log('Logout failed');
        // Nếu đăng xuất không thành công, có thể hiển thị thông báo lỗi
        emit(ProfileScreenError('Đăng xuất không thành công'));
      }
    } catch (e) {
      log.log('Error during logout: $e');
      emit(ProfileScreenError('Đăng xuất không thành công: $e'));
    }
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileScreenState> emit,
  ) async {
    try {
      final administrator =
          await _administratorRepository.getActiveAdministrator();
      if (administrator.isEmpty) {
        emit(ProfileReadOnlyState(name: '', email: ''));
        return;
      }

      emit(
        ProfileReadOnlyState(
          name: administrator['name'] ?? '',
          email: administrator['email'] ?? '',
        ),
      );
    } catch (e) {
      log.log('Error loading profile: $e');
      emit(ProfileReadOnlyState(name: '', email: ''));
    }
  }

  void _onEnableEdit(EnableEditEvent event, Emitter<ProfileScreenState> emit) {
    if (state is ProfileReadOnlyState) {
      final currentState = state as ProfileReadOnlyState;
      emit(
        ProfileEditableState(
          name: currentState.name,
          email: currentState.email,
        ),
      );
    }
  }

  Future<void> _onSaveInfo(
    SaveInfoEvent event,
    Emitter<ProfileScreenState> emit,
  ) async {
    try {
      // TODO: Implement save to repository
      emit(ProfileReadOnlyState(name: event.name, email: event.email));
    } catch (e) {
      log.log('Error saving profile: $e');
      // Keep the current state if save fails
    }
  }
}
