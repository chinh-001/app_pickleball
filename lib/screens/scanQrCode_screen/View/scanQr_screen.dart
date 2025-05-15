import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({Key? key}) : super(key: key);

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (!_hasScanned) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  setState(() {
                    _hasScanned = true;
                  });

                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
                    _showResultDialog(code);
                  }
                }
              }
            },
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        AppLocalizations.of(context).translate('scanNewQrCode'),
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
                      _buildActionButton('IETOR', Icons.qr_code),
                      _buildActionButton('website', Icons.language),
                      _buildActionButton('Zalo', Icons.chat),
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
                    child: Stack(
                      children: [
                        // Corner indicators
                        Positioned(
                          top: 0,
                          left: 0,
                          child: _buildCorner(BorderSide.top, BorderSide.left),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: _buildCorner(BorderSide.top, BorderSide.right),
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

                // Bottom actions
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomAction(
                        AppLocalizations.of(context).translate('galleryPhoto'),
                        Icons.photo_library,
                        () => _pickPhotoFromGallery(),
                      ),
                      _buildBottomAction(
                        AppLocalizations.of(context).translate('recentScans'),
                        Icons.history,
                        () => _showRecentScans(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(BorderSide vertical, BorderSide horizontal) {
    return SizedBox(
      width: 50,
      height: 50,
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

  Widget _buildBottomAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _pickPhotoFromGallery() {
    // TODO: Implement photo picking functionality
  }

  void _showRecentScans() {
    // TODO: Implement recent scans display
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).translate('qrCodeResult')),
            content: Text(code),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _hasScanned = false;
                  });
                },
                child: Text(
                  AppLocalizations.of(context).translate('scanAgain'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).translate('done')),
              ),
            ],
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
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    if (vertical == BorderSide.top && horizontal == BorderSide.left) {
      canvas.drawLine(Offset.zero, Offset(30, 0), paint);
      canvas.drawLine(Offset.zero, Offset(0, 30), paint);
    } else if (vertical == BorderSide.top && horizontal == BorderSide.right) {
      canvas.drawLine(Offset(size.width, 0), Offset(size.width - 30, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, 30), paint);
    } else if (vertical == BorderSide.bottom && horizontal == BorderSide.left) {
      canvas.drawLine(Offset(0, size.height), Offset(30, size.height), paint);
      canvas.drawLine(
        Offset(0, size.height),
        Offset(0, size.height - 30),
        paint,
      );
    } else if (vertical == BorderSide.bottom &&
        horizontal == BorderSide.right) {
      canvas.drawLine(
        Offset(size.width, size.height),
        Offset(size.width - 30, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(size.width, size.height),
        Offset(size.width, size.height - 30),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum BorderSide { top, bottom, left, right }
