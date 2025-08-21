import 'package:flutter/material.dart';

import '../models/device.dart';
import '../repositories/device_repository.dart';
import '../route/app_route.dart';
import '../services/cache_service.dart';
import '../widgets/home_device_card.dart';

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
      drawer: _buildDrawer(),
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
                      Scaffold.of(context).openDrawer();
                    },
                    icon: const Icon(Icons.menu, size: 24),
                  ),
                  // Right side icons
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.notifications);
                        },
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 24,
                        ),
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
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRouter.devices);
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
                        return HomeDeviceCard(
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
                            Navigator.pushNamed(
                              context,
                              AppRouter.lightControl,
                              arguments: {
                                'deviceName': device.name,
                                'deviceId': device.id,
                                'isOn': device.isOn,
                                'brightness': 47.0, // Default brightness
                                'imagePath': device.imagePath,
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

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header with user info
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
                ),
              ),
              child: Column(
                children: [
                  // User avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User name
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // User email/status
                  Text(
                    'Smart Home User',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                    },
                    isSelected: true,
                  ),
                  _buildDrawerItem(
                    icon: Icons.devices,
                    title: 'Devices',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.devices);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.add_circle_outline,
                    title: 'Add Device',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.addDevice);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.qr_code_scanner,
                    title: 'Scan QR Code',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.scan);
                    },
                  ),
                  const Divider(height: 1),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.settings);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      _showHelpDialog();
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog();
                    },
                  ),
                ],
              ),
            ),

            // Logout section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog();
                    },
                    textColor: Colors.red,
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            iconColor ??
            (isSelected ? const Color(0xFF667eea) : Colors.grey[600]),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color:
              textColor ??
              (isSelected ? const Color(0xFF667eea) : Colors.black87),
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: const Color(0xFF667eea).withOpacity(0.1),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help with your smart home?'),
            SizedBox(height: 8),
            Text('• Contact us: support@smarthome.com'),
            Text('• Call us: +1 (555) 123-4567'),
            Text('• Visit our website: www.smarthome.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Smart Home'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smart Home App'),
            SizedBox(height: 4),
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text('Control your smart devices with ease.'),
            SizedBox(height: 8),
            Text('© 2024 Smart Home Inc.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to welcome screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.welcome,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
