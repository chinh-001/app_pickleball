part of 'profile_screen_bloc.dart';

abstract class ProfileScreenEvent extends Equatable {
  const ProfileScreenEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện chuyển sang chế độ chỉnh sửa
class EnableEditEvent extends ProfileScreenEvent {}

// Sự kiện lưu thông tin
class SaveInfoEvent extends ProfileScreenEvent {
  final String name;
  final String email;
  final String phone;

  const SaveInfoEvent({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}
