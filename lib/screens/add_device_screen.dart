import 'package:flutter/material.dart';

import '../models/device.dart';
import '../repositories/device_repository.dart';
import 'qr_scanner_screen.dart';

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

  final DeviceRepository _deviceRepository = DeviceRepository();
  bool _isSubmitting = false;

  // Predefined zone options
  final List<String> _predefinedZones = [
    'Living Room',
    'Kitchen',
    'Bedroom',
    'Bathroom',
    'Dining Room',
    'Office',
    'Garage',
    'Basement',
    'Attic',
    'Garden',
    'Balcony',
    'Hallway',
    'Laundry Room',
    'Guest Room',
    'Other',
  ];

  @override
  void dispose() {
    _uniqueIdController.dispose();
    _assignedNameController.dispose();
    _zoneController.dispose();
    _protocolController.dispose();
    super.dispose();
  }

  void _startScanning() async {
    // Navigate to QR scanner screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    // Handle the scanned result
    if (result != null && result is String) {
      setState(() {
        _uniqueIdController.text = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Code scanned successfully: $result'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _submitDevice() async {
    // Validate form data
    if (!_validateDeviceData()) {
      return;
    }

    // Check if device with this ID already exists
    final existingDevice = await _deviceRepository.getDevice(
      _uniqueIdController.text.trim(),
    );
    if (existingDevice != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A device with this Unique ID already exists'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create new device
      final newDevice = Device(
        id: _uniqueIdController.text.trim(),
        name: _assignedNameController.text.trim(),
        imagePath: _getDeviceImagePath(_assignedNameController.text.trim()),
        type: _getDeviceType(_assignedNameController.text.trim()),
        isOn: false,
        lastUpdated: DateTime.now(),
        additionalProperties: {
          'zone': _zoneController.text.trim(),
          'protocol': _protocolController.text.trim(),
        },
      );

      // Add device to repository
      await _deviceRepository.addDevice(newDevice);

      // Show success message with option to add another device
      if (mounted) {
        final shouldAddAnother = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Device Added Successfully!'),
            content: Text(
              'Device "${newDevice.name}" has been added to your smart home.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Done'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Add Another Device'),
              ),
            ],
          ),
        );

        if (shouldAddAnother == true) {
          // Clear form for adding another device
          _clearForm();
        } else {
          // Navigate back to main screen with devices tab selected
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: {'initialIndex': 1}, // Switch to devices tab
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding device: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getDeviceImagePath(String deviceName) {
    // Determine image path based on device name
    final nameLower = deviceName.toLowerCase();

    if (nameLower.contains('fridge') || nameLower.contains('refrigerator')) {
      return 'asset/images/fridge.jpg'; // Using home.png as default for fridge
    } else if (nameLower.contains('fan') || nameLower.contains('air')) {
      return 'asset/images/fan.png';
    } else if (nameLower.contains('light') ||
        nameLower.contains('bulb') ||
        nameLower.contains('lamp')) {
      return 'asset/images/bulb.png';
    } else if (nameLower.contains('tv') || nameLower.contains('television')) {
      return 'asset/images/tv.jpg';
    } else if (nameLower.contains('ac') ||
        nameLower.contains('air conditioner')) {
      return 'asset/images/ac.jpg';
    } else if (nameLower.contains('washing') || nameLower.contains('washer') || nameLower.contains('washing machine')) {
      return 'asset/images/washing_machine.jpg';
    } else if (nameLower.contains('microwave') || nameLower.contains('oven')) {
      return 'asset/images/microwave.jpg';
    } else if (nameLower.contains('dishwasher')) {
      return 'asset/images/dish_washer.jpg';
    } else if (nameLower.contains('coffee') || nameLower.contains('maker')) {
      return 'asset/images/coffee.jpg';
    } else if (nameLower.contains('toaster')) {
      return 'asset/images/toaster.jpg';
    } else if (nameLower.contains('heater')) {
      return 'asset/images/heater.jpg';
    } else if (nameLower.contains('camera') || nameLower.contains('security')) {
      return 'asset/images/camera.png';
    } else if (nameLower.contains('speaker') || nameLower.contains('sound')) {
      return 'asset/images/speaker.jpg';
    } else if (nameLower.contains('router') || nameLower.contains('wifi')) {
      return 'asset/images/router.jpg';
    } else if (nameLower.contains('door') || nameLower.contains('lock')) {
      return 'asset/images/door_lock.jpg';
    } else if (nameLower.contains('garage')) {
      return 'asset/images/garage_door.jpg';
    } else if (nameLower.contains('sensor') || nameLower.contains('motion')) {
      return 'asset/images/camera.png'; // Using camera for sensors
    } else if (nameLower.contains('switch') || nameLower.contains('outlet')) {
      return 'asset/images/bulb.png'; // Using bulb for switches
    } else {
      return 'asset/images/bulb.png'; // Default image
    }
  }

  String _getDeviceType(String deviceName) {
    // Determine device type based on device name
    final nameLower = deviceName.toLowerCase();

    if (nameLower.contains('fan') ||
        nameLower.contains('air') ||
        nameLower.contains('ac')) {
      return 'ac';
    } else if (nameLower.contains('light') ||
        nameLower.contains('bulb') ||
        nameLower.contains('lamp') ||
        nameLower.contains('led')) {
      return 'light';
    } else if (nameLower.contains('switch') || nameLower.contains('outlet')) {
      return 'switch';
    } else if (nameLower.contains('sensor') ||
        nameLower.contains('motion') ||
        nameLower.contains('camera')) {
      return 'sensor';
    } else if (nameLower.contains('tv') || nameLower.contains('television')) {
      return 'tv';
    } else if (nameLower.contains('fridge') ||
        nameLower.contains('refrigerator')) {
      return 'fridge';
    } else if (nameLower.contains('washing') ||
        nameLower.contains('washer') ||
        nameLower.contains('dishwasher')) {
      return 'washing machine';
    } else if (nameLower.contains('microwave') ||
        nameLower.contains('oven') ||
        nameLower.contains('coffee') ||
        nameLower.contains('toaster')) {
      return 'microwave';
    } else if (nameLower.contains('heater')) {
      return 'heater';
    } else if (nameLower.contains('speaker') || nameLower.contains('sound')) {
      return 'audio';
    } else if (nameLower.contains('router') || nameLower.contains('wifi')) {
      return 'router';
    } else if (nameLower.contains('door') ||
        nameLower.contains('lock') ||
        nameLower.contains('garage')) {
      return 'door lock';
    } else {
      return 'appliance'; // Default type
    }
  }

  // Helper method to validate device data
  bool _validateDeviceData() {
    if (_uniqueIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Unique ID'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_assignedNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a device name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate Unique ID format (alphanumeric and underscore only)
    final uniqueIdRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!uniqueIdRegex.hasMatch(_uniqueIdController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unique ID can only contain letters, numbers, and underscores',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  // Helper method to clear form
  void _clearForm() {
    _uniqueIdController.clear();
    _assignedNameController.clear();
    _zoneController.clear();
    _protocolController.clear();
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    // Check if there are unsaved changes
    if (_uniqueIdController.text.isNotEmpty ||
        _assignedNameController.text.isNotEmpty ||
        _zoneController.text.isNotEmpty ||
        _protocolController.text.isNotEmpty) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );

      return shouldDiscard ?? false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: Center(
                  child: Container(
                    width: 300,
                    height: 250,
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // QR Code pattern background
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.qr_code,
                            size: 250,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          // CustomPaint(painter: QRCodePainter()),
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
              ),

              const SizedBox(height: 30),

              // Separator with "or"
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: Colors.grey[300]),
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
                    child: Container(height: 1, color: Colors.grey[300]),
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
              Column(
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
                  _buildZoneDropdown(),

                  const SizedBox(height: 16),

                  // Protocol field
                  _buildInputField(
                    controller: _protocolController,
                    label: 'Protocol',
                    placeholder: 'Enter protocol',
                  ),

                  const SizedBox(height: 40),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitDevice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Adding Device...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
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
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
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

  Widget _buildZoneDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zone',
          style: TextStyle(
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
          child: DropdownButtonFormField<String>(
            value: _zoneController.text.isEmpty ? null : _zoneController.text,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            hint: const Text(
              'Select zone',
              style: TextStyle(color: Colors.grey),
            ),
            items: _predefinedZones.map((String zone) {
              return DropdownMenuItem<String>(value: zone, child: Text(zone));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _zoneController.text = newValue;
                });
              }
            },
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
