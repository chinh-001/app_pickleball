part of 'scanqr_screen_bloc.dart';

abstract class ScanqrScreenState extends Equatable {
  const ScanqrScreenState();

  @override
  List<Object> get props => [];
}

class ScanqrScreenInitial extends ScanqrScreenState {}

class ScanningState extends ScanqrScreenState {}

class ScannedCodeState extends ScanqrScreenState {
  final String code;

  const ScannedCodeState(this.code);

  @override
  List<Object> get props => [code];
}

class ScanErrorState extends ScanqrScreenState {
  final String error;

  const ScanErrorState(this.error);

  @override
  List<Object> get props => [error];
}
