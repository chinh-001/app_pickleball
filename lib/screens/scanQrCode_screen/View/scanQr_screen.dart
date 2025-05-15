import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

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
                    _handleScannedCode(code);
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

                // Bottom actions
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBottomAction(
                        AppLocalizations.of(context).translate('galleryPhoto'),
                        Icons.photo_library,
                        () => _pickPhotoFromGallery(),
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

  // Function to handle the scanned QR code
  Future<void> _handleScannedCode(String code) async {
    developer.log('Scanned QR code: $code');

    // Check if the code is a URL
    if (_isValidUrl(code)) {
      // Show a brief toast indicating we're opening the URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('openingUrlInBrowser'),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Try to launch the URL
      final result = await _launchUrl(code);

      if (!result) {
        // If we couldn't launch the URL, show the result dialog
        _showResultDialog(code);
      } else {
        // Reset the scanner after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _hasScanned = false;
            });
          }
        });
      }
    } else {
      // If not a URL, show the result dialog
      _showResultDialog(code);
    }
  }

  // Check if the string is a valid URL
  bool _isValidUrl(String text) {
    // More lenient URL pattern
    return text.startsWith('http://') || text.startsWith('https://');
  }

  // Launch URL in browser
  Future<bool> _launchUrl(String urlString) async {
    try {
      developer.log('Attempting to launch URL: $urlString');
      final Uri url = Uri.parse(urlString);

      // First try with universal_links mode
      bool result = await launchUrl(url, mode: LaunchMode.externalApplication);

      developer.log('URL launch result: $result');
      return result;
    } catch (e) {
      developer.log('Error launching URL: $e');
      return false;
    }
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
              // Add a button to open URL if it looks like a URL but couldn't be launched automatically
              if (_isValidUrl(code) ||
                  code.contains('.com') ||
                  code.contains('.org') ||
                  code.contains('.net'))
                TextButton(
                  onPressed: () async {
                    // If it doesn't start with http/https, add https://
                    String urlToLaunch = code;
                    if (!code.startsWith('http://') &&
                        !code.startsWith('https://')) {
                      urlToLaunch = 'https://$code';
                    }

                    Navigator.of(context).pop();
                    final Uri url = Uri.parse(urlToLaunch);
                    try {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      developer.log('Error launching URL from dialog: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not open URL: $urlToLaunch'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('openUrl'),
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
