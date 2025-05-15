part of 'scanqr_screen_bloc.dart';

abstract class ScanqrScreenEvent extends Equatable {
  const ScanqrScreenEvent();

  @override
  List<Object> get props => [];
}

class ScanQrCodeEvent extends ScanqrScreenEvent {}

class HandleScannedCodeEvent extends ScanqrScreenEvent {
  final String code;

  const HandleScannedCodeEvent(this.code);

  @override
  List<Object> get props => [code];
}

class ResetScannerEvent extends ScanqrScreenEvent {}
