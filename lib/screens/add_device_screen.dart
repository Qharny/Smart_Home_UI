import 'package:flutter/material.dart';

import '../route/app_route.dart';
import '../widgets/bottom_nav_bar.dart';

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

  @override
  void dispose() {
    _uniqueIdController.dispose();
    _assignedNameController.dispose();
    _zoneController.dispose();
    _protocolController.dispose();
    super.dispose();
  }

  void _scanQRCode() async {
    // Navigate to scan screen and wait for result
    final result = await Navigator.pushNamed(context, AppRouter.scan);

    if (result != null && result is String) {
      // Handle the scanned QR code
      setState(() {
        _uniqueIdController.text = result;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Code scanned: $result'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _submitForm() {
    // TODO: Implement form submission
    if (_uniqueIdController.text.isEmpty ||
        _assignedNameController.text.isEmpty ||
        _zoneController.text.isEmpty ||
        _protocolController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Navigate to success screen
    Navigator.pushReplacementNamed(
      context,
      AppRouter.deviceAddedSuccess,
      arguments: {'deviceName': _assignedNameController.text},
    );
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
                    'Add devices',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scan Section
                    const Text(
                      'Click to scan',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    // QR Code Scan Area
                    GestureDetector(
                      onTap: _scanQRCode,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Stack(
                          children: [
                            // QR Code Pattern (simulated)
                            Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.qr_code,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            // Scan Button Overlay
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Scan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
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

                    // Manual Add Section
                    const Text(
                      'Add manually',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Fields
                    _buildInputField(
                      controller: _uniqueIdController,
                      label: 'Unique ID:',
                      hint: 'Enter unique ID',
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _assignedNameController,
                      label: 'Assigned name',
                      hint: 'Enter device name',
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _zoneController,
                      label: 'Zone',
                      hint: 'Enter zone',
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _protocolController,
                      label: 'Protocol',
                      hint: 'Enter protocol',
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
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

                    const SizedBox(height: 20),
                  ],
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
