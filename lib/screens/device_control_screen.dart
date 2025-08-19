import 'package:flutter/material.dart';

import '../models/device.dart';
import '../repositories/device_repository.dart';

class DeviceControlScreen extends StatefulWidget {
  final Device device;
  final VoidCallback? onDeviceStateChanged;

  const DeviceControlScreen({
    super.key,
    required this.device,
    this.onDeviceStateChanged,
  });

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  late bool isDeviceOn;
  late double brightness;
  String selectedRoom = 'Livingroom';
  bool hasAutomation = true;
  final DeviceRepository _deviceRepository = DeviceRepository();

  @override
  void initState() {
    super.initState();
    isDeviceOn = widget.device.isOn;
    brightness = 0.47; // Default brightness
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
              // Top section with back button and title
              Row(
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
                  Text(
                    widget.device.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Toggle and Room Selection Row
              Row(
                children: [
                  // Toggle Switch
                  Row(
                    children: [
                      Switch(
                        value: isDeviceOn,
                        onChanged: (value) async {
                          setState(() {
                            isDeviceOn = value;
                          });
                          // Update device state in repository
                          await _deviceRepository.updateDeviceState(
                            widget.device.id,
                            value,
                          );
                          // Notify parent widget about state change
                          widget.onDeviceStateChanged?.call();
                        },
                        activeColor: Colors.black,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[300],
                        activeTrackColor: Colors.black,
                        activeThumbColor: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDeviceOn ? 'On' : 'Off',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Room Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedRoom,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Device-specific controls
              Expanded(child: _buildDeviceControls()),

              // Automation Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Automation Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Automation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Add +',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Automation Entry
                    if (hasAutomation)
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Text(
                                  '2pm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Text(
                                  'Off',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  hasAutomation = false;
                                });
                              },
                              icon: const Icon(
                                Icons.remove,
                                size: 16,
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
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

  Widget _buildDeviceControls() {
    switch (widget.device.type) {
      case 'light':
        return _buildLightControls();
      case 'fan':
        return _buildFanControls();
      default:
        return _buildDefaultControls();
    }
  }

  Widget _buildLightControls() {
    return Row(
      children: [
        // Left side - Brightness Controls
        Column(
          children: [
            // Plus button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    brightness = (brightness + 0.1).clamp(0.0, 1.0);
                  });
                },
                icon: const Icon(Icons.add, color: Colors.black),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 10),
            // Brightness Slider
            Container(
              height: 250,
              width: 60,
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: Colors.black,
                  ),
                  child: Slider(
                    value: brightness,
                    onChanged: (value) {
                      setState(() {
                        brightness = value;
                      });
                    },
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Minus button
            Container(
              width: 40,
              height: 40,
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
              child: IconButton(
                onPressed: () {
                  setState(() {
                    brightness = (brightness - 0.1).clamp(0.0, 1.0);
                  });
                },
                icon: const Icon(Icons.remove, color: Colors.black),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(width: 40),
        // Right side - Light Bulb Image and Brightness Display
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Light Bulb Image
              Container(
                width: 120,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDeviceOn
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.transparent,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  widget.device.imagePath,
                  fit: BoxFit.contain,
                  color: isDeviceOn
                      ? Colors.orange.withOpacity(0.8)
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 20),
              // Brightness Percentage
              Text(
                '${(brightness * 100).round()}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Brightness',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFanControls() {
    return Row(
      children: [
        // Left side - Speed Controls
        Column(
          children: [
            // Plus button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    brightness = (brightness + 0.1).clamp(0.0, 1.0);
                  });
                },
                icon: const Icon(Icons.add, color: Colors.black),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 10),
            // Speed Slider
            Container(
              height: 250,
              width: 60,
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: Colors.black,
                  ),
                  child: Slider(
                    value: brightness,
                    onChanged: (value) {
                      setState(() {
                        brightness = value;
                      });
                    },
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Minus button
            Container(
              width: 40,
              height: 40,
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
              child: IconButton(
                onPressed: () {
                  setState(() {
                    brightness = (brightness - 0.1).clamp(0.0, 1.0);
                  });
                },
                icon: const Icon(Icons.remove, color: Colors.black),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(width: 40),
        // Right side - Fan Image and Speed Display
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fan Image
              Container(
                width: 120,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDeviceOn
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.transparent,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  widget.device.imagePath,
                  fit: BoxFit.contain,
                  color: isDeviceOn
                      ? Colors.blue.withOpacity(0.8)
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 20),
              // Speed Percentage
              Text(
                '${(brightness * 100).round()}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Speed',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultControls() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDeviceOn
                      ? Colors.green.withOpacity(0.3)
                      : Colors.transparent,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(
              widget.device.imagePath,
              fit: BoxFit.contain,
              color: isDeviceOn
                  ? Colors.green.withOpacity(0.8)
                  : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.device.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isDeviceOn ? 'Device is On' : 'Device is Off',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
