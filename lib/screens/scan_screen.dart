import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../route/app_route.dart';
import '../widgets/bottom_nav_bar.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanning = true;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_isScanning && scanData.code != null) {
        _isScanning = false;
        _handleScannedCode(scanData.code!);
      }
    });
  }

  void _handleScannedCode(String code) {
    // Stop scanning
    controller?.pauseCamera();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scanned: $code'), backgroundColor: Colors.green),
    );

    // Navigate back with the scanned code
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Title
                  const Text(
                    'Scanning......',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // QR Scanner View
                        QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                          overlay: QrScannerOverlayShape(
                            borderColor: Colors.transparent,
                            borderRadius: 10,
                            borderLength: 30,
                            borderWidth: 10,
                            cutOutSize: 250,
                          ),
                        ),

                        // Custom overlay with black top and bottom sections
                        Positioned.fill(
                          child: Column(
                            children: [
                              // Black top section
                              Container(height: 100, color: Colors.black),

                              // Grey scanning area with corner brackets
                              Expanded(
                                child: Container(
                                  color: Colors.grey[200],
                                  child: Stack(
                                    children: [
                                      // Corner brackets
                                      // Top-left bracket
                                      Positioned(
                                        top: 20,
                                        left: 20,
                                        child: _buildCornerBracket(true, true),
                                      ),
                                      // Top-right bracket
                                      Positioned(
                                        top: 20,
                                        right: 20,
                                        child: _buildCornerBracket(true, false),
                                      ),
                                      // Bottom-left bracket
                                      Positioned(
                                        bottom: 20,
                                        left: 20,
                                        child: _buildCornerBracket(false, true),
                                      ),
                                      // Bottom-right bracket
                                      Positioned(
                                        bottom: 20,
                                        right: 20,
                                        child: _buildCornerBracket(
                                          false,
                                          false,
                                        ),
                                      ),

                                      // Barcode icon in center
                                      Center(
                                        child: Container(
                                          width: 200,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              // Barcode lines
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: List.generate(20, (
                                                    index,
                                                  ) {
                                                    final width =
                                                        (index % 3 == 0)
                                                        ? 3.0
                                                        : 1.0;
                                                    return Container(
                                                      width: width,
                                                      height: 50,
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 1,
                                                          ),
                                                      color: Colors.black,
                                                    );
                                                  }),
                                                ),
                                              ),
                                              // Red scan line
                                              Center(
                                                child: Container(
                                                  width: 200,
                                                  height: 2,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Black bottom section
                              Container(height: 100, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2, // Add tab is selected
        onItemTapped: (index) {
          // Handle navigation
          switch (index) {
            case 0: // Home
              Navigator.pushReplacementNamed(context, AppRouter.home);
              break;
            case 1: // Devices
              Navigator.pushReplacementNamed(context, AppRouter.devices);
              break;
            case 2: // Add (current screen)
              // Already on add screen
              break;
          }
        },
      ),
    );
  }

  Widget _buildCornerBracket(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: CornerBracketPainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class CornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  CornerBracketPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isTop && isLeft) {
      // Top-left bracket
      path.moveTo(size.width, 0);
      path.lineTo(size.width * 0.3, 0);
      path.moveTo(0, size.height * 0.3);
      path.lineTo(0, size.height);
    } else if (isTop && !isLeft) {
      // Top-right bracket
      path.moveTo(0, 0);
      path.lineTo(size.width * 0.7, 0);
      path.moveTo(size.width, size.height * 0.3);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      // Bottom-left bracket
      path.moveTo(size.width, size.height);
      path.lineTo(size.width * 0.3, size.height);
      path.moveTo(0, size.height * 0.7);
      path.lineTo(0, 0);
    } else {
      // Bottom-right bracket
      path.moveTo(0, size.height);
      path.lineTo(size.width * 0.7, size.height);
      path.moveTo(size.width, size.height * 0.7);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
