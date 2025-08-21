import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final TextEditingController _uniqueIdController = TextEditingController();
  final TextEditingController _assignedNameController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _protocolController = TextEditingController();
  
  bool _isScanning = false;
  QRViewController? _qrViewController;

  @override
  void dispose() {
    _uniqueIdController.dispose();
    _assignedNameController.dispose();
    _zoneController.dispose();
    _protocolController.dispose();
    _qrViewController?.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _qrViewController?.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrViewController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        // Handle scanned QR code data
        _uniqueIdController.text = scanData.code!;
        _stopScanning();
      }
    });
  }

  void _submitDevice() {
    // Validate and submit device data
    if (_uniqueIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Unique ID')),
      );
      return;
    }

    // TODO: Implement device submission logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device added successfully!')),
    );
    
    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Add devices',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Click to scan section
              const Text(
                'Click to scan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // QR Scanner Area
              GestureDetector(
                onTap: _startScanning,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isScanning
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: QRView(
                            key: const Key('qr_view'),
                            onQRViewCreated: _onQRViewCreated,
                            overlay: QrScannerOverlayShape(
                              borderColor: Colors.white,
                              borderRadius: 10,
                              borderLength: 30,
                              borderWidth: 10,
                              cutOutSize: 200,
                            ),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            // QR Code pattern background
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomPaint(
                                painter: QRCodePainter(),
                              ),
                            ),
                            // Scan text
                            const Text(
                              'Scan',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Separator with "or"
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Add manually section
              const Text(
                'Add manually',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Input fields
              Expanded(
                child: Column(
                  children: [
                    // Unique ID field
                    _buildInputField(
                      controller: _uniqueIdController,
                      label: 'Unique ID:',
                      placeholder: 'Enter unique ID',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Assigned name field
                    _buildInputField(
                      controller: _assignedNameController,
                      label: 'Assigned name',
                      placeholder: 'Enter device name',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Zone field
                    _buildInputField(
                      controller: _zoneController,
                      label: 'Zone',
                      placeholder: 'Enter zone',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Protocol field
                    _buildInputField(
                      controller: _protocolController,
                      label: 'Protocol',
                      placeholder: 'Enter protocol',
                    ),
                    
                    const Spacer(),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitDevice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for QR code pattern
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2;

    // Draw QR code pattern
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * (size.width / 8),
              j * (size.height / 8),
              size.width / 8,
              size.height / 8,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 