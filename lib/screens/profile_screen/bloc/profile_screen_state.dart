part of 'profile_screen_bloc.dart';

abstract class ProfileScreenState extends Equatable {
  const ProfileScreenState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu
class ProfileInitialState extends ProfileScreenState {}

// Trạng thái chỉnh sửa
class ProfileEditableState extends ProfileScreenState {
  final String name;
  final String email;
  final String phone;

  const ProfileEditableState({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}

// Trạng thái chỉ đọc
class ProfileReadOnlyState extends ProfileScreenState {
  final String name;
  final String email;
  final String phone;

  const ProfileReadOnlyState({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}
