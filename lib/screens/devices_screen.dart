import 'package:flutter/material.dart';

import '../models/device.dart';
import '../repositories/device_repository.dart';
import '../route/app_route.dart';
import '../services/cache_service.dart';
import '../widgets/device_card.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final DeviceRepository _deviceRepository = DeviceRepository();
  final CacheService _cacheService = CacheService();
  List<Device> _devices = [];
  List<Device> _filteredDevices = [];
  String _selectedRoom = 'All';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<String> _rooms = [
    'All',
    'Living-room',
    'Exterior',
    'Bedroom',
    'Kitchen',
  ];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Force reinitialize devices to ensure correct names
      await _deviceRepository.forceReinitializeDevices();

      // Load devices from cache
      final devices = await _deviceRepository.getAllDevices();

      setState(() {
        _devices = devices;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDevice(String deviceId) async {
    try {
      print('DevicesScreen: Toggling device: $deviceId'); // Debug log
      await _deviceRepository.toggleDevice(deviceId);
      print('DevicesScreen: Device toggled successfully'); // Debug log
      await _loadData(); // Reload data to reflect changes
      print('DevicesScreen: Data reloaded'); // Debug log
    } catch (e) {
      print('DevicesScreen: Error toggling device: $e'); // Debug log
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle device: $e')));
    }
  }

  Future<void> _refreshDeviceStates() async {
    print('DevicesScreen: Refreshing device states');
    // Refresh device states from cache
    for (final device in _devices) {
      final cachedState = await _cacheService.getDevicePowerState(device.id);
      if (cachedState != null && cachedState != device.isOn) {
        print(
          'DevicesScreen: Updating device ${device.name} state from ${device.isOn} to $cachedState',
        );
        // Update device state
        device.isOn = cachedState;
      }
    }
    setState(() {
      // Trigger rebuild to reflect updated states
    });
    print('DevicesScreen: Device states refreshed');
  }

  void _filterDevicesByRoom(String room) {
    setState(() {
      _selectedRoom = room;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Device> filtered = _devices;

    // Filter by room (for now, show all devices since we don't have room data)
    if (_selectedRoom != 'All') {
      // In a real app, you would filter by actual room data
      // filtered = filtered.where((device) => device.room == _selectedRoom).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (device) =>
                device.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                device.type.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _filteredDevices = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF1F2F6),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Spacer to center the title
                  const SizedBox(width: 48), // Same width as settings button
                  // Title
                  const Text(
                    'Devices',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Settings button
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
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.settings);
                      },
                      icon: const Icon(Icons.settings, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),

            // Room Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Filter Title
                  const Text(
                    'Rooms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Room Filter Buttons
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _rooms.length,
                      itemBuilder: (context, index) {
                        final room = _rooms[index];
                        final isSelected = _selectedRoom == room;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => _filterDevicesByRoom(room),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chair,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    room,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
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
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search devices...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.clear, color: Colors.grey),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Devices Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredDevices.length} Devices',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  // Add Device Button
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.addDevice,
                      );
                    },
                    icon: const Icon(Icons.add, size: 20),
                    tooltip: 'Add Device',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Devices Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _filteredDevices.isEmpty
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
                              'No devices found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add some devices to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: _filteredDevices.length,
                        itemBuilder: (context, index) {
                          final device = _filteredDevices[index];
                          return DeviceCard(
                            deviceId: device.id,
                            name: device.name,
                            imagePath: device.imagePath,
                            isOn: device.isOn,
                            onToggle: (value) async {
                              print(
                                'onToggle called with value: $value for device: ${device.name}',
                              ); // Debug log
                              try {
                                await _toggleDevice(device.id);
                              } catch (e) {
                                // Handle error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to toggle device: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            onViewControls: () async {
                              await Navigator.pushReplacementNamed(
                                context,
                                AppRouter.deviceControl,
                                arguments: {
                                  'device': device,
                                  'onDeviceStateChanged': () {
                                    // Refresh device list when device state changes
                                    _refreshDeviceStates();
                                  },
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
