import 'package:flutter/material.dart';

import '../models/device.dart';
import '../repositories/device_repository.dart';
import '../route/app_route.dart';
import '../services/cache_service.dart';
import '../widgets/device_page_card.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final DeviceRepository _deviceRepository = DeviceRepository();
  final CacheService _cacheService = CacheService();
  List<Device> _devices = [];
  String _selectedFilter = 'All Devices';
  bool _isLoading = true;
  List<Map<String, dynamic>> _filters = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshDeviceStates();
  }

  Future<void> _loadData() async {
    try {
      // Don't force reinitialize - just load existing devices
      final devices = await _deviceRepository.getAllDevices();

      setState(() {
        _devices = devices;
        _generateFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateFilters() {
    // Start with "All Devices" filter
    _filters = [
      {'name': 'All Devices', 'icon': Icons.devices},
    ];

    // Get unique zones from devices
    final Set<String> uniqueZones = {};
    for (final device in _devices) {
      final zone = device.additionalProperties?['zone'] as String?;
      if (zone != null && zone.isNotEmpty) {
        uniqueZones.add(zone);
      }
    }

    // Add zone-specific filters with appropriate icons
    for (final zone in uniqueZones) {
      _filters.add({'name': zone, 'icon': _getZoneIcon(zone)});
    }
  }

  IconData _getZoneIcon(String zone) {
    final zoneLower = zone.toLowerCase();

    if (zoneLower.contains('living')) {
      return Icons.chair;
    } else if (zoneLower.contains('kitchen')) {
      return Icons.kitchen;
    } else if (zoneLower.contains('bedroom')) {
      return Icons.bed;
    } else if (zoneLower.contains('bathroom')) {
      return Icons.bathtub;
    } else if (zoneLower.contains('dining')) {
      return Icons.dining;
    } else if (zoneLower.contains('office')) {
      return Icons.work;
    } else if (zoneLower.contains('garage')) {
      return Icons.garage;
    } else if (zoneLower.contains('basement')) {
      return Icons.stairs;
    } else if (zoneLower.contains('attic')) {
      return Icons.attractions;
    } else if (zoneLower.contains('garden')) {
      return Icons.grass;
    } else if (zoneLower.contains('balcony')) {
      return Icons.balcony;
    } else if (zoneLower.contains('hallway')) {
      return Icons.door_front_door;
    } else if (zoneLower.contains('laundry')) {
      return Icons.local_laundry_service;
    } else if (zoneLower.contains('guest')) {
      return Icons.person;
    } else {
      return Icons.room; // Default icon for other zones
    }
  }

  Future<void> _toggleDevice(String deviceId) async {
    try {
      await _deviceRepository.toggleDevice(deviceId);
      await _loadData(); // This will refresh both devices and filters
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle device: $e')));
    }
  }

  Future<void> _removeDevice(String deviceId) async {
    try {
      print('DevicesScreen: Removing device: $deviceId'); // Debug log
      await _deviceRepository.removeDevice(deviceId);
      print('DevicesScreen: Device removed successfully'); // Debug log
      await _loadData(); // Reload data to reflect changes
      print('DevicesScreen: Data reloaded after removal'); // Debug log

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device removed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('DevicesScreen: Error removing device: $e'); // Debug log
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove device: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshDeviceStates() async {
    for (final device in _devices) {
      final cachedState = await _cacheService.getDevicePowerState(device.id);
      if (cachedState != null && cachedState != device.isOn) {
        device.isOn = cachedState;
      }
    }
    setState(() {});
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<Device> _getFilteredDevices() {
    if (_selectedFilter == 'All Devices') {
      return _devices;
    }

    return _devices.where((device) {
      final zone = device.additionalProperties?['zone'] as String?;
      return zone == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Devices',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filter Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = filter['name'] == _selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => _onFilterChanged(filter['name']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    filter['icon'],
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    filter['name'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Devices Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _getFilteredDevices().isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.devices_other,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'All Devices'
                                ? 'No devices found'
                                : 'No devices in $_selectedFilter',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFilter == 'All Devices'
                                ? 'Add some devices to get started'
                                : 'Try selecting a different category',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _getFilteredDevices().length,
                      itemBuilder: (context, index) {
                        final device = _getFilteredDevices()[index];
                        return DevicePageCard(
                          deviceId: device.id,
                          name: device.name,
                          imagePath: device.imagePath,
                          isOn: device.isOn,
                          onToggle: (value) async {
                            try {
                              await _toggleDevice(device.id);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to toggle device: $e'),
                                ),
                              );
                            }
                          },
                          onViewControls: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.lightControl,
                              arguments: {
                                'deviceName': device.name,
                                'deviceId': device.id,
                                'deviceType': device.type,
                                'isOn': device.isOn,
                                'brightness': device.brightness,
                                'speed': device.speed,
                                'imagePath': device.imagePath,
                              },
                            );
                          },
                          onRemove: () async {
                            await _removeDevice(device.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
