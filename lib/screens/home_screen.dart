import 'package:flutter/material.dart';

import '../models/device.dart';
import '../repositories/device_repository.dart';
import '../route/app_route.dart';
import '../services/cache_service.dart';
import '../widgets/device_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeviceRepository _deviceRepository = DeviceRepository();
  final CacheService _cacheService = CacheService();
  List<Device> _devices = [];
  String _userName = 'Mark';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh device states when dependencies change (e.g., returning from device control)
    _refreshDeviceStates();
  }

  Future<void> _loadData() async {
    try {
      // Force reinitialize devices to ensure correct names
      await _deviceRepository.forceReinitializeDevices();

      // Load devices from cache
      final devices = await _deviceRepository.getAllDevices();

      // Load user name from cache
      final cachedUserName = _cacheService.getUserName();

      setState(() {
        _devices = devices;
        _userName = cachedUserName ?? 'Mark';
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
      print('HomeScreen: Toggling device: $deviceId'); // Debug log
      await _deviceRepository.toggleDevice(deviceId);
      print('HomeScreen: Device toggled successfully'); // Debug log
      await _loadData(); // Reload data to reflect changes
      print('HomeScreen: Data reloaded'); // Debug log
    } catch (e) {
      print('HomeScreen: Error toggling device: $e'); // Debug log
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle device: $e')));
    }
  }

  Future<void> _refreshDeviceStates() async {
    print('HomeScreen: Refreshing device states');
    // Refresh device states from cache
    for (final device in _devices) {
      final cachedState = await _cacheService.getDevicePowerState(device.id);
      if (cachedState != null && cachedState != device.isOn) {
        print(
          'HomeScreen: Updating device ${device.name} state from ${device.isOn} to $cachedState',
        );
        // Update device state
        device.isOn = cachedState;
      }
    }
    setState(() {
      // Trigger rebuild to reflect updated states
    });
    print('HomeScreen: Device states refreshed');
  }

  // Test method to verify synchronization
  Future<void> _testSynchronization() async {
    print('HomeScreen: Testing synchronization...');
    for (final device in _devices) {
      final cachedState = await _cacheService.getDevicePowerState(device.id);
      print(
        'HomeScreen: Device ${device.name} - Current: ${device.isOn}, Cached: $cachedState',
      );
    }
  }

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
                  // Hamburger menu
                  IconButton(
                    onPressed: () {
                      // TODO: Implement menu
                    },
                    icon: const Icon(Icons.menu, size: 24),
                  ),
                  // Right side icons
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Implement notifications
                        },
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.settings);
                        },
                        icon: const Icon(Icons.settings, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('asset/images/home.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Hi $_userName,',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Welcome to your Smart Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Devices Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Devices',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
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
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRouter.devices,
                                );
                              },
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Devices Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                                  content: Text('Failed to toggle device: $e'),
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

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
