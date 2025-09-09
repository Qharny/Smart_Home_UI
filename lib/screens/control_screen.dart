import 'package:flutter/material.dart';

import '../models/automation.dart';
import '../repositories/device_repository.dart';
import '../services/automation_service.dart';
import '../widgets/add_automation_dialog.dart';

class DeviceControlScreen extends StatefulWidget {
  final String deviceName;
  final String deviceId;
  final String deviceType;
  final bool isOn;
  final double brightness;
  final double speed;
  final String imagePath;

  const DeviceControlScreen({
    super.key,
    required this.deviceName,
    required this.deviceId,
    required this.deviceType,
    required this.isOn,
    this.brightness = 50.0,
    this.speed = 50.0,
    required this.imagePath,
  });

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  late bool _isOn;
  late double _brightness;
  late double _speed;
  late double _temperature; // For AC, fridge, heater
  late String _mode; // For AC, washing machine
  late int _timer; // For various devices
  String _selectedRoom = 'Livingroom';
  final List<String> _rooms = ['Livingroom', 'Bedroom', 'Kitchen', 'Bathroom'];
  final DeviceRepository _deviceRepository = DeviceRepository();
  final AutomationService _automationService = AutomationService();
  List<Automation> _automations = [];

  @override
  void initState() {
    super.initState();
    _isOn = widget.isOn;
    _brightness = widget.brightness;
    _speed = widget.speed;
    _temperature = 22.0; // Default temperature
    _mode = 'auto'; // Default mode
    _timer = 0; // Default timer
    _loadAutomations();
  }

  Future<void> _loadAutomations() async {
    final automations = await _deviceRepository.getAutomationsForDevice(
      widget.deviceId,
    );
    setState(() {
      _automations = automations;
    });
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
    _deviceRepository.updateDeviceBrightness(widget.deviceId, value);
  }

  void _updateSpeed(double value) {
    setState(() {
      _speed = value;
    });
    _deviceRepository.updateDeviceSpeed(widget.deviceId, value);
  }

  void _updateTemperature(double value) {
    setState(() {
      _temperature = value;
    });
    // You can add temperature update to device repository if needed
  }

  void _updateMode(String mode) {
    setState(() {
      _mode = mode;
    });
    // You can add mode update to device repository if needed
  }

  void _updateTimer(int minutes) {
    setState(() {
      _timer = minutes;
    });
    // You can add timer update to device repository if needed
  }

  void _increaseValue() {
    if (widget.deviceType == 'light') {
      setState(() {
        _brightness = (_brightness + 5).clamp(0.0, 100.0);
      });
      _deviceRepository.updateDeviceBrightness(widget.deviceId, _brightness);
    } else if (widget.deviceType == 'fan' || widget.deviceType == 'ac') {
      setState(() {
        _speed = (_speed + 5).clamp(0.0, 100.0);
      });
      _deviceRepository.updateDeviceSpeed(widget.deviceId, _speed);
    } else if (widget.deviceType == 'fridge' || widget.deviceType == 'heater') {
      setState(() {
        _temperature = (_temperature + 1).clamp(16.0, 30.0);
      });
      _updateTemperature(_temperature);
    }
  }

  void _decreaseValue() {
    if (widget.deviceType == 'light') {
      setState(() {
        _brightness = (_brightness - 5).clamp(0.0, 100.0);
      });
      _deviceRepository.updateDeviceBrightness(widget.deviceId, _brightness);
    } else if (widget.deviceType == 'fan' || widget.deviceType == 'ac') {
      setState(() {
        _speed = (_speed - 5).clamp(0.0, 100.0);
      });
      _deviceRepository.updateDeviceSpeed(widget.deviceId, _speed);
    } else if (widget.deviceType == 'fridge' || widget.deviceType == 'heater') {
      setState(() {
        _temperature = (_temperature - 1).clamp(16.0, 30.0);
      });
      _updateTemperature(_temperature);
    }
  }

  double get _currentValue {
    switch (widget.deviceType) {
      case 'light':
        return _brightness;
      case 'fan':
      case 'ac':
        return _speed;
      case 'fridge':
      case 'heater':
        return _temperature;
      default:
        return _brightness;
    }
  }

  String get _valueLabel {
    switch (widget.deviceType) {
      case 'light':
        return 'Brightness';
      case 'fan':
        return 'Speed';
      case 'ac':
        return 'Fan Speed';
      case 'fridge':
        return 'Temperature';
      case 'heater':
        return 'Temperature';
      default:
        return 'Control';
    }
  }

  double _getMinValue() {
    switch (widget.deviceType) {
      case 'light':
        return 0.0;
      case 'fan':
      case 'ac':
        return 0.0;
      case 'fridge':
      case 'heater':
        return 16.0;
      default:
        return 0.0;
    }
  }

  double _getMaxValue() {
    switch (widget.deviceType) {
      case 'light':
        return 100.0;
      case 'fan':
      case 'ac':
        return 100.0;
      case 'fridge':
      case 'heater':
        return 30.0;
      default:
        return 100.0;
    }
  }

  Function(double) _getSliderOnChanged() {
    switch (widget.deviceType) {
      case 'light':
        return _updateBrightness;
      case 'fan':
      case 'ac':
        return _updateSpeed;
      case 'fridge':
      case 'heater':
        return _updateTemperature;
      default:
        return _updateBrightness;
    }
  }

  String _getValueDisplay() {
    switch (widget.deviceType) {
      case 'light':
        return '${_currentValue.round()}%';
      case 'fan':
      case 'ac':
        return '${_currentValue.round()}%';
      case 'fridge':
      case 'heater':
        return '${_currentValue.round()}°C';
      default:
        return '${_currentValue.round()}%';
    }
  }

  bool _shouldShowModeControls() {
    return widget.deviceType == 'ac' ||
        widget.deviceType == 'washing machine' ||
        widget.deviceType == 'microwave';
  }

  List<String> _getModeOptions() {
    switch (widget.deviceType) {
      case 'ac':
        return ['Auto', 'Cool', 'Heat', 'Fan', 'Dry'];
      case 'washing machine':
        return ['Normal', 'Delicate', 'Heavy', 'Quick', 'Eco'];
      case 'microwave':
        return ['Defrost', 'Reheat', 'Cook', 'Grill', 'Auto'];
      default:
        return [];
    }
  }

  Widget _buildModeControls() {
    final modes = _getModeOptions();
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'Mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: modes.map((mode) {
              final isSelected = _mode.toLowerCase() == mode.toLowerCase();
              return GestureDetector(
                onTap: () => _updateMode(mode),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    mode,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _addAutomation(Automation automation) async {
    await _deviceRepository.addAutomation(automation);
    await _loadAutomations();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Automation added for ${automation.formattedTime}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteAutomation(String automationId) async {
    await _deviceRepository.deleteAutomation(automationId);
    await _loadAutomations();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Automation deleted'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _toggleAutomation(String automationId) async {
    await _deviceRepository.toggleAutomation(automationId);
    await _loadAutomations();
  }

  void _showAddAutomationDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAutomationDialog(
        deviceId: widget.deviceId,
        deviceName: widget.deviceName,
        deviceType: widget.deviceType,
        onAdd: _addAutomation,
      ),
    );
  }

  Future<void> _testAutomations() async {
    await _automationService.checkAutomationsNow();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Automation check completed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
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

              // Device-specific mode controls (for AC, washing machine, etc.)
              if (_shouldShowModeControls()) _buildModeControls(),

              const SizedBox(height: 20),

              // Middle Section - Main Control and Device Image
              SizedBox(
                height: 400, // Fixed height instead of Expanded
                child: Row(
                  children: [
                    // Left Side - Brightness Slider
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          // Increase button
                          GestureDetector(
                            onTap: _increaseValue,
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
                                  value: _currentValue,
                                  min: _getMinValue(),
                                  max: _getMaxValue(),
                                  onChanged: _getSliderOnChanged(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Decrease button
                          GestureDetector(
                            onTap: _decreaseValue,
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

                          // Value display with appropriate unit
                          Text(
                            _getValueDisplay(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Brightness label
                          Text(
                            _valueLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
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
                        Row(
                          children: [
                            // Test button (only show if there are automations)
                            if (_automations.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: ElevatedButton(
                                  onPressed: _testAutomations,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[50],
                                    foregroundColor: Colors.blue[700],
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: Colors.blue[200]!,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Test',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            // Add button
                            ElevatedButton(
                              onPressed: _showAddAutomationDialog,
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
                          flex: 2,
                          child: Text(
                            'Action',
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

                    // Automation entries
                    if (_automations.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No automations yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "Add +" to create your first automation',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._automations
                          .map(
                            (automation) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: automation.isEnabled
                                            ? Colors.grey[100]
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: automation.isEnabled
                                              ? Colors.grey[300]!
                                              : Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        automation.formattedTime,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: automation.isEnabled
                                              ? Colors.black87
                                              : Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: automation.isEnabled
                                            ? Colors.grey[100]
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: automation.isEnabled
                                              ? Colors.grey[300]!
                                              : Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        automation.actionDisplayText,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: automation.isEnabled
                                              ? Colors.black87
                                              : Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      // Toggle button
                                      GestureDetector(
                                        onTap: () =>
                                            _toggleAutomation(automation.id),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: automation.isEnabled
                                                ? Colors.green[50]
                                                : Colors.grey[100],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            automation.isEnabled
                                                ? Icons.check
                                                : Icons.close,
                                            size: 16,
                                            color: automation.isEnabled
                                                ? Colors.green[600]
                                                : Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Delete button
                                      GestureDetector(
                                        onTap: () =>
                                            _deleteAutomation(automation.id),
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
                          )
                          .toList(),
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
