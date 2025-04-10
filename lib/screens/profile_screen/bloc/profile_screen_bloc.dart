import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_screen_event.dart';
part 'profile_screen_state.dart';

class ProfileScreenBloc extends Bloc<ProfileScreenEvent, ProfileScreenState> {
  ProfileScreenBloc()
      : super(const ProfileReadOnlyState(
          name: "Nguyen Van A",
          email: "nguyenvana@example.com",
          phone: "0123456789",
        )) {
    on<EnableEditEvent>(_onEnableEdit);
    on<SaveInfoEvent>(_onSaveInfo);
  }

  void _onEnableEdit(
    EnableEditEvent event,
    Emitter<ProfileScreenState> emit,
  ) {
    if (state is ProfileReadOnlyState) {
      final currentState = state as ProfileReadOnlyState;
      emit(ProfileEditableState(
        name: currentState.name,
        email: currentState.email,
        phone: currentState.phone,
      ));
    }
  }

  void _onSaveInfo(
    SaveInfoEvent event,
    Emitter<ProfileScreenState> emit,
  ) {
    emit(ProfileReadOnlyState(
      name: event.name,
      email: event.email,
      phone: event.phone,
    ));
  }
}
