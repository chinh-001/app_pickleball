import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../services/repositories/administrator_repository.dart';
import '../../../services/repositories/auth_repository.dart';
import '../../../models/userInfo_model.dart';
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
       super(ProfileReadOnlyState(name: '', email: '', userInfo: null)) {
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

      // Xóa thông tin người dùng khỏi storage
      await UserInfo.clearUserInfo();

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
      // Sử dụng UserInfo model
      final userInfo = await _administratorRepository.getActiveAdministrator();

      if (userInfo.name.isEmpty && userInfo.email.isEmpty) {
        emit(ProfileReadOnlyState(name: '', email: '', userInfo: userInfo));
        return;
      }

      emit(
        ProfileReadOnlyState(
          name: userInfo.name,
          email: userInfo.email,
          userInfo: userInfo,
        ),
      );
    } catch (e) {
      log.log('Error loading profile: $e');
      emit(ProfileReadOnlyState(name: '', email: '', userInfo: null));
    }
  }

  void _onEnableEdit(EnableEditEvent event, Emitter<ProfileScreenState> emit) {
    if (state is ProfileReadOnlyState) {
      final currentState = state as ProfileReadOnlyState;
      emit(
        ProfileEditableState(
          name: currentState.name,
          email: currentState.email,
          userInfo: currentState.userInfo,
        ),
      );
    }
  }

  Future<void> _onSaveInfo(
    SaveInfoEvent event,
    Emitter<ProfileScreenState> emit,
  ) async {
    try {
      log.log('Saving profile info: ${event.name}, ${event.email}');

      // Nếu có UserInfo hiện tại, cập nhật nó
      UserInfo? updatedUserInfo;
      if (state is ProfileEditableState) {
        final currentState = state as ProfileEditableState;
        if (currentState.userInfo != null) {
          updatedUserInfo = await currentState.userInfo!.updateUserInfo(
            name: event.name,
            email: event.email,
          );
        } else {
          // Tạo mới nếu không có
          updatedUserInfo = UserInfo(name: event.name, email: event.email);
          await updatedUserInfo.saveUserInfo();
        }
      } else {
        // Tạo mới nếu không có
        updatedUserInfo = UserInfo(name: event.name, email: event.email);
        await updatedUserInfo.saveUserInfo();
      }

      // TODO: Implement save to API repository here

      emit(
        ProfileReadOnlyState(
          name: event.name,
          email: event.email,
          userInfo: updatedUserInfo,
        ),
      );

      log.log('Profile info saved successfully');
    } catch (e) {
      log.log('Error saving profile: $e');
      // Keep the current state if save fails
    }
  }
}
