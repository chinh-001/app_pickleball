import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as log;

class ConnectivityService {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  static ConnectivityService get instance => _instance;

  // Private constructor
  ConnectivityService._internal();

  // Stream controller
  final _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityResult>.broadcast();

  // Stream to listen to
  Stream<ConnectivityResult> get connectivityStream => _controller.stream;

  // Initialize connectivity service
  void initialize() {
    log.log('Initializing ConnectivityService...');

    // Check initial connectivity status
    _connectivity.checkConnectivity().then(_updateConnectionStatus);

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    log.log('Connectivity status changed: $result');
    _controller.add(result);
  }

  // Check if currently connected
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Check if connected to WiFi
  Future<bool> isWifiConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  // Check if connected to mobile network
  Future<bool> isMobileConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }

  // Dispose resources
  void dispose() {
    _controller.close();
  }
}
