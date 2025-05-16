import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'dart:developer' as developer;

part 'scanqr_screen_event.dart';
part 'scanqr_screen_state.dart';

class ScanqrScreenBloc extends Bloc<ScanqrScreenEvent, ScanqrScreenState> {
  ScanqrScreenBloc() : super(ScanqrScreenInitial()) {
    on<HandleScannedCodeEvent>(_onHandleScannedCodeEvent);
    on<ResetScannerEvent>(_onResetScannerEvent);
  }

  void _onHandleScannedCodeEvent(
    HandleScannedCodeEvent event,
    Emitter<ScanqrScreenState> emit,
  ) {
    developer.log('Scanned QR code: ${event.code}');
    emit(ScannedCodeState(event.code));
  }

  void _onResetScannerEvent(
    ResetScannerEvent event,
    Emitter<ScanqrScreenState> emit,
  ) {
    emit(ScanningState());
  }

  // Check if the string is a valid URL
  bool isValidUrl(String text) {
    // More lenient URL pattern
    return text.startsWith('http://') || text.startsWith('https://');
  }

  // Launch URL in browser
  Future<bool> launchUrl(String urlString) async {
    try {
      developer.log('Attempting to launch URL: $urlString');
      final Uri url = Uri.parse(urlString);

      // First try with universal_links mode
      bool result = await url_launcher.launchUrl(
        url,
        mode: url_launcher.LaunchMode.externalApplication,
      );

      developer.log('URL launch result: $result');
      return result;
    } catch (e) {
      developer.log('Error launching URL: $e');
      return false;
    }
  }
}
