import 'package:flutter/material.dart';

import '../repositories/device_repository.dart';

class LightControlScreen extends StatefulWidget {
  final String deviceName;
  final String deviceId;
  final bool isOn;
  final double brightness;
  final String imagePath;

  const LightControlScreen({
    super.key,
    required this.deviceName,
    required this.deviceId,
    required this.isOn,
    this.brightness = 47.0,
    required this.imagePath,
  });

  @override
  State<LightControlScreen> createState() => _LightControlScreenState();
}

class _LightControlScreenState extends State<LightControlScreen> {
  late bool _isOn;
  late double _brightness;
  String _selectedRoom = 'Livingroom';
  final List<String> _rooms = ['Livingroom', 'Bedroom', 'Kitchen', 'Bathroom'];
  final DeviceRepository _deviceRepository = DeviceRepository();

  @override
  void initState() {
    super.initState();
    _isOn = widget.isOn;
    _brightness = widget.brightness;
  }

  Future<void> _togglePower() async {
    try {
      final newState = !_isOn;
      setState(() {
        _isOn = newState;
      });

      // Update device state in repository
      await _deviceRepository.updateDeviceState(widget.deviceId, newState);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Device ${_isOn ? 'turned on' : 'turned off'}'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Revert state if update failed
      setState(() {
        _isOn = !_isOn;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update device: $e')));
    }
  }

  void _updateBrightness(double value) {
    setState(() {
      _brightness = value;
    });
  }

  void _increaseBrightness() {
    setState(() {
      _brightness = (_brightness + 5).clamp(0.0, 100.0);
    });
  }

  void _decreaseBrightness() {
    setState(() {
      _brightness = (_brightness - 5).clamp(0.0, 100.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section - Back button, title, and toggle
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              // Title
              Text(
                widget.deviceName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Toggle and Room Selection
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _togglePower,
                    child: Container(
                      width: 50,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _isOn ? Colors.black : Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            left: _isOn ? 22 : 2,
                            top: 2,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  const Text(
                    'On',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Room Dropdown
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRoom,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    items: _rooms.map((String room) {
                      return DropdownMenuItem<String>(
                        value: room,
                        child: Text(room),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedRoom = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Middle Section - Brightness Control and Light Bulb
              Expanded(
                child: Row(
                  children: [
                    // Left Side - Brightness Slider
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          // Increase button
                          GestureDetector(
                            onTap: _increaseBrightness,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Vertical Slider
                          Expanded(
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
                                  value: _brightness,
                                  min: 0,
                                  max: 100,
                                  onChanged: _updateBrightness,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Decrease button
                          GestureDetector(
                            onTap: _decreaseBrightness,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 40),

                    // Right Side - Device Image
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Device Image with glow effect
                          Container(
                            width: 120,
                            height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow effect when device is on
                                if (_isOn)
                                  Container(
                                    width: 140,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      // color: Colors.orange.withOpacity(0.3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.6),
                                          blurRadius: 30,
                                          spreadRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),

                                // Dark overlay when device is off
                                if (!_isOn)
                                  Container(
                                    width: 140,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      // color: Colors.black.withOpacity(0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 15,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),

                                // Device image
                                _isOn
                                    ? Container(
                                        width: 600,
                                        height: 600,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.asset(
                                            widget.imagePath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Image.asset(
                                        widget.imagePath,
                                        width: 600,
                                        height: 600,
                                        fit: BoxFit.cover,
                                        // color: Colors.grey[400],
                                        colorBlendMode: BlendMode.saturation,
                                      ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Brightness percentage
                          Text(
                            '${_brightness.round()}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Brightness label
                          const Text(
                            'Brightness',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bottom Section - Automation
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Automation header
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
                        ElevatedButton(
                          onPressed: () {
                            // Add automation logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Add +',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Automation table header
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Space for delete button
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Automation entry
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '2pm',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Off',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            // Delete automation logic
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: Colors.red[400],
                            ),
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
}
