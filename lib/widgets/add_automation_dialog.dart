import 'package:flutter/material.dart';

import '../models/automation.dart';

class AddAutomationDialog extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final Function(Automation) onAdd;

  const AddAutomationDialog({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.onAdd,
  });

  @override
  State<AddAutomationDialog> createState() => _AddAutomationDialogState();
}

class _AddAutomationDialogState extends State<AddAutomationDialog> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  String _selectedAction = 'on';
  double _selectedValue = 50.0;
  List<String> _selectedDays = ['daily'];

  final List<String> _actions = ['on', 'off', 'brightness', 'speed'];
  final List<String> _days = [
    'daily',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Automation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'for ${widget.deviceName}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // Time Selection
            Text(
              'Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.access_time, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Selection
            Text(
              'Action',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAction,
                  isExpanded: true,
                  items: _actions.map((String action) {
                    return DropdownMenuItem<String>(
                      value: action,
                      child: Text(_getActionDisplayText(action)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedAction = newValue;
                      });
                    }
                  },
                ),
              ),
            ),

            // Value Slider (for brightness/speed)
            if (_selectedAction == 'brightness' ||
                _selectedAction == 'speed') ...[
              const SizedBox(height: 20),
              Text(
                _selectedAction == 'brightness' ? 'Brightness' : 'Speed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _selectedValue,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: (double value) {
                        setState(() {
                          _selectedValue = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_selectedValue.round()}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Days Selection
            Text(
              'Repeat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _days.map((day) {
                final isSelected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (day == 'daily') {
                        _selectedDays = ['daily'];
                      } else {
                        _selectedDays.remove('daily');
                        if (isSelected) {
                          _selectedDays.remove(day);
                        } else {
                          _selectedDays.add(day);
                        }
                        if (_selectedDays.isEmpty) {
                          _selectedDays = ['daily'];
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      day.capitalize(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addAutomation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _getActionDisplayText(String action) {
    switch (action) {
      case 'on':
        return 'Turn On';
      case 'off':
        return 'Turn Off';
      case 'brightness':
        return 'Set Brightness';
      case 'speed':
        return 'Set Speed';
      default:
        return action;
    }
  }

  void _addAutomation() {
    final automation = Automation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      deviceId: widget.deviceId,
      deviceName: widget.deviceName,
      deviceType: widget.deviceType,
      time:
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      action: _selectedAction,
      value: (_selectedAction == 'brightness' || _selectedAction == 'speed')
          ? _selectedValue
          : null,
      days: _selectedDays,
      createdAt: DateTime.now(),
    );

    widget.onAdd(automation);
    Navigator.pop(context);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
