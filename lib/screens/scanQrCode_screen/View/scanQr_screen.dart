import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/scanqr_screen_bloc.dart';
import 'dart:developer' as developer;

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({Key? key}) : super(key: key);

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;
  bool _hasCameraPermission = false;
  late ScanqrScreenBloc _scanqrScreenBloc;

  @override
  void initState() {
    super.initState();
    _scanqrScreenBloc = ScanqrScreenBloc();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    developer.log('Requesting camera permission');
    final status = await Permission.camera.request();
    developer.log('Camera permission status: $status');

    setState(() {
      _hasCameraPermission = status.isGranted;
    });

    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).translate('cameraPermissionRequired'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Cài đặt',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _scanqrScreenBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _scanqrScreenBloc,
      child: BlocListener<ScanqrScreenBloc, ScanqrScreenState>(
        listener: (context, state) {
          if (state is ScannedCodeState) {
            _showResultDialog(state.code);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              // QR Scanner or error message based on permission
              _hasCameraPermission
                  ? MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      developer.log(
                        'Barcode detected: ${capture.barcodes.length} codes',
                      );

                      if (!_hasScanned) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String? code = barcodes.first.rawValue;
                          developer.log('Scanned code: $code');

                          if (code != null) {
                            setState(() {
                              _hasScanned = true;
                            });
                            _scanqrScreenBloc.add(HandleScannedCodeEvent(code));
                          }
                        }
                      }
                    },
                  )
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không có quyền truy cập camera',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _requestCameraPermission(),
                          child: const Text('Cấp quyền'),
                        ),
                      ],
                    ),
                  ),

              // Overlay UI
              SafeArea(
                child: Column(
                  children: [
                    // Top header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).translate('scanNewQrCode'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // For balance
                        ],
                      ),
                    ),

                    // Middle section with action buttons
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: Colors.black.withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            AppLocalizations.of(context).translate('qr'),
                            Icons.qr_code,
                          ),
                          _buildActionButton(
                            AppLocalizations.of(context).translate('website'),
                            Icons.language,
                          ),
                        ],
                      ),
                    ),

                    // Scanner viewport
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent),
                            ),
                            child: Stack(
                              children: [
                                // Corner indicators
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: _buildCorner(
                                    BorderSide.top,
                                    BorderSide.left,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: _buildCorner(
                                    BorderSide.top,
                                    BorderSide.right,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: _buildCorner(
                                    BorderSide.bottom,
                                    BorderSide.left,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: _buildCorner(
                                    BorderSide.bottom,
                                    BorderSide.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom section - removed galleryPhoto
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(BorderSide vertical, BorderSide horizontal) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(painter: CornerPainter(vertical, horizontal)),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  void _showResultDialog(String code) {
    final bool isUrl =
        _scanqrScreenBloc.isValidUrl(code) ||
        code.contains('.com') ||
        code.contains('.org') ||
        code.contains('.net');

    String urlToLaunch = code;
    if (isUrl && !code.startsWith('http://') && !code.startsWith('https://')) {
      urlToLaunch = 'https://$code';
    }

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with Icon
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Title
                  Text(
                    AppLocalizations.of(context).translate('qrCodeResult'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Content
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      code,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Buttons
                  Row(
                    children: [
                      // Quét lại button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _hasScanned = false;
                            });
                            _scanqrScreenBloc.add(ResetScannerEvent());
                          },
                          child: Text(
                            AppLocalizations.of(context).translate('scanAgain'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Mở đường dẫn button (chỉ hiển thị nếu là URL)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUrl ? Colors.green : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed:
                              isUrl
                                  ? () async {
                                    Navigator.of(context).pop();
                                    final result = await _scanqrScreenBloc
                                        .launchUrl(urlToLaunch);
                                    if (!result && mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Không thể mở URL: $urlToLaunch',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                  : null,
                          child: Text(
                            AppLocalizations.of(context).translate('openUrl'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final BorderSide vertical;
  final BorderSide horizontal;

  CornerPainter(this.vertical, this.horizontal);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    if (vertical == BorderSide.top && horizontal == BorderSide.left) {
      canvas.drawLine(Offset.zero, Offset(25, 0), paint);
      canvas.drawLine(Offset.zero, Offset(0, 25), paint);
    } else if (vertical == BorderSide.top && horizontal == BorderSide.right) {
      canvas.drawLine(Offset(size.width, 0), Offset(size.width - 25, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, 25), paint);
    } else if (vertical == BorderSide.bottom && horizontal == BorderSide.left) {
      canvas.drawLine(Offset(0, size.height), Offset(25, size.height), paint);
      canvas.drawLine(
        Offset(0, size.height),
        Offset(0, size.height - 25),
        paint,
      );
    } else if (vertical == BorderSide.bottom &&
        horizontal == BorderSide.right) {
      canvas.drawLine(
        Offset(size.width, size.height),
        Offset(size.width - 25, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(size.width, size.height),
        Offset(size.width, size.height - 25),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum BorderSide { top, bottom, left, right }
