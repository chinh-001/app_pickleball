part of 'profile_screen_bloc.dart';

abstract class ProfileScreenState extends Equatable {
  const ProfileScreenState();

  @override
  List<Object> get props => [];
}

// Trạng thái ban đầu
class ProfileScreenInitial extends ProfileScreenState {}

// Trạng thái chỉnh sửa
class ProfileEditableState extends ProfileScreenState {
  final String name;
  final String email;

  const ProfileEditableState({required this.name, required this.email});

  @override
  List<Object> get props => [name, email];
}

// Trạng thái chỉ đọc
class ProfileReadOnlyState extends ProfileScreenState {
  final String name;
  final String email;

  const ProfileReadOnlyState({required this.name, required this.email});

  @override
  List<Object> get props => [name, email];
}

class ProfileScreenLoading extends ProfileScreenState {}

class ProfileScreenLoaded extends ProfileScreenState {
  final String name;
  final String email;

  const ProfileScreenLoaded({required this.name, required this.email});

  @override
  List<Object> get props => [name, email];
}

class ProfileScreenError extends ProfileScreenState {
  final String message;

  const ProfileScreenError(this.message);

  @override
  List<Object> get props => [message];
}
