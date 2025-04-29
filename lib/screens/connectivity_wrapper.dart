import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/connectivity_service.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isConnected = true;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    // Listen to connectivity changes
    ConnectivityService.instance.connectivityStream.listen((result) {
      _updateConnectivityStatus(result);
    });

    // Check initial status
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final isConnected = await ConnectivityService.instance.isConnected();
    setState(() {
      _isConnected = isConnected;
    });

    if (!_isConnected) {
      _showConnectivitySnackbar();
    }
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    final isConnected = result != ConnectivityResult.none;

    setState(() {
      _isConnected = isConnected;
    });

    // Show message only when connection is lost
    if (wasConnected && !isConnected) {
      _showConnectivitySnackbar();
    } else if (!wasConnected && isConnected) {
      // Remove any existing connection message when connection is restored
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
      // Optionally show "connection restored" message
      _showConnectionRestoredSnackbar();
    }
  }

  void _showConnectivitySnackbar() {
    if (!mounted) return;

    // Đóng bất kỳ SnackBar hiện tại nào
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Không có kết nối mạng, vui lòng kiểm tra lại',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(days: 365), // "Permanent" until dismissed
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showConnectionRestoredSnackbar() {
    if (!mounted) return;

    // Đóng bất kỳ SnackBar hiện tại nào
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Kết nối mạng đã được khôi phục',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
