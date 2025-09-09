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
  String _selectedFilter = 'Living-room';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Living-room', 'icon': Icons.chair},
    {'name': 'Exterior', 'icon': Icons.outdoor_grill},
    {'name': 'Living-room', 'icon': Icons.chair},
  ];

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDevice(String deviceId) async {
    try {
      await _deviceRepository.toggleDevice(deviceId);
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle device: $e')));
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
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
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
