import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device.dart';
import '../repositories/device_repository.dart';
import '../route/app_route.dart';
import '../services/cache_service.dart';
import '../services/theme_service.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.notifications);
            },
            icon: const Icon(Icons.notifications_outlined, size: 24),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
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
                                Colors.black.withOpacity(0.6),
                              ],
                              stops: [0.0, 0.6, 1.0],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Hi $_userName,',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 3,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Welcome to your Smart Home',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                            await Navigator.pushNamed(
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

                            // Refresh device states when returning from control screen
                            await _refreshDeviceStates();
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
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        child: Column(
          children: [
            // Header with user info
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                children: [
                  // User avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User name
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
                children: [
                  _buildDrawerItem(
                    // icon: Icons.home,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                    },
                    isSelected: true,
                  ),
                  Divider(),
                  Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                      return ListTile(
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        trailing: Switch(
                          value: themeService.isDarkMode,
                          onChanged: (value) {
                            themeService.toggleTheme();
                          },
                        ),
                        onTap: () {
                          themeService.toggleTheme();
                        },
                      );
                    },
                  ),
                  Divider(),
                  _buildDrawerItem(
                    // icon: Icons.add_circle_outline,
                    title: 'Logout',
                    onTap: () {
                      _showLogoutDialog();
                    },
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    // required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? textColor,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color:
              textColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 15,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: const Color(0xFF667eea).withOpacity(0.1),
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
