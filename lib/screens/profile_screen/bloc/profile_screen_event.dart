part of 'profile_screen_bloc.dart';

abstract class ProfileScreenEvent extends Equatable {
  const ProfileScreenEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện chuyển sang chế độ chỉnh sửa
class EnableEditEvent extends ProfileScreenEvent {}

// Sự kiện lưu thông tin
class SaveInfoEvent extends ProfileScreenEvent {
  final String name;
  final String email;

  const SaveInfoEvent({required this.name, required this.email});

  @override
  List<Object> get props => [name, email];
}

class LoadProfileEvent extends ProfileScreenEvent {
  const LoadProfileEvent();
}

// Sự kiện đăng xuất
class LogoutEvent extends ProfileScreenEvent {
  const LogoutEvent();
}
