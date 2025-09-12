import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../route/app_route.dart';
import '../services/cache_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CacheService _cacheService = CacheService();
  final NotificationService _notificationService = NotificationService();
  String? _userName;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userName = _cacheService.getUserName();
    final userPhone = _cacheService.getUserPhone();

    setState(() {
      _userName = userName;
      _userPhone = userPhone;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? This will clear all your data and device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Clear all cache and user data
      await _cacheService.logout();

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Navigate to welcome screen
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.welcome,
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // void _showClearCacheDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Clear Cache'),
  //       content: const Text(
  //         'This will clear all cached device data. Your login information will be preserved.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel', style: TextStyle(color: Colors.black)),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             await _clearCache();
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.black,
  //             foregroundColor: Colors.white,
  //           ),
  //           child: const Text('Clear Cache'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _clearCache() async {
    try {
      await _cacheService.clearDeviceStates();
      await _cacheService.removeData('devices_list');
      await _cacheService.removeData('automations_list');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSyncFrequencyDialog(NotificationService notificationService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSyncOption('Every 1 minute', '1', notificationService),
            _buildSyncOption('Every 5 minutes', '5', notificationService),
            _buildSyncOption('Every 15 minutes', '15', notificationService),
            _buildSyncOption('Every 30 minutes', '30', notificationService),
            _buildSyncOption('Every hour', '60', notificationService),
            _buildSyncOption('Manual only', 'manual', notificationService),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOption(
    String title,
    String value,
    NotificationService notificationService,
  ) {
    return ListTile(
      title: Text(title),
      trailing: notificationService.syncFrequency == title
          ? const Icon(Icons.check)
          : null,
      onTap: () async {
        await notificationService.setSyncFrequency(title);
        Navigator.pop(context);
      },
    );
  }

  void _showDemoNotification() {
    // Show a demo notification when notifications are enabled
    _notificationService.showDeviceNotification(
      'Demo Device',
      'toggled',
      true,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildSection(title: 'Profile', children: [_buildProfileCard()]),

            const SizedBox(height: 24),

            // App Preferences Section
            _buildSection(
              title: 'App Preferences',
              children: [
                Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    return _buildSettingsTile(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark themes',
                      trailing: Switch(
                        value: themeService.isDarkMode,
                        onChanged: (value) {
                          themeService.toggleTheme();
                        },
                      ),
                    );
                  },
                ),
                Consumer<NotificationService>(
                  builder: (context, notificationService, child) {
                    return _buildSettingsTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Receive device alerts and updates',
                      trailing: Switch(
                        value: notificationService.notificationsEnabled,
                        onChanged: (value) async {
                          await notificationService.toggleNotifications(
                            value,
                            context: context,
                          );
                          if (value) {
                            // Show demo notification when enabled
                            _showDemoNotification();
                          }
                        },
                      ),
                    );
                  },
                ),
                Consumer<NotificationService>(
                  builder: (context, notificationService, child) {
                    return _buildSettingsTile(
                      icon: Icons.sync,
                      title: 'Auto Sync',
                      subtitle: 'Automatically sync device states',
                      trailing: Switch(
                        value: notificationService.autoSyncEnabled,
                        onChanged: (value) async {
                          await notificationService.toggleAutoSync(value);
                        },
                      ),
                    );
                  },
                ),
                Consumer<NotificationService>(
                  builder: (context, notificationService, child) {
                    return _buildSettingsTile(
                      icon: Icons.schedule,
                      title: 'Sync Frequency',
                      subtitle: notificationService.syncFrequency,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          _showSyncFrequencyDialog(notificationService),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Device Management Section
            _buildSection(
              title: 'Device Management',
              children: [
                // _buildSettingsTile(
                //   icon: Icons.clear_all,
                //   title: 'Clear Cache',
                //   subtitle: 'Clear cached device data',
                //   trailing: const Icon(Icons.chevron_right),
                //   onTap: _showClearCacheDialog,
                // ),
                _buildSettingsTile(
                  icon: Icons.refresh,
                  title: 'Refresh Devices',
                  subtitle: 'Reload all device data',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // This would trigger a device refresh
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Devices refreshed'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                Consumer<NotificationService>(
                  builder: (context, notificationService, child) {
                    final isRunning =
                        notificationService.isDemoNotificationsRunning;
                    return _buildSettingsTile(
                      icon: isRunning ? Icons.stop : Icons.notifications_active,
                      title: isRunning
                          ? 'Stop Demo Notifications'
                          : 'Demo Notifications',
                      subtitle: isRunning
                          ? 'Demo notifications are running'
                          : 'Start demo notifications for testing',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (notificationService.notificationsEnabled) {
                          if (isRunning) {
                            notificationService.stopDemoNotifications();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Demo notifications stopped'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          } else {
                            notificationService.startDemoNotifications();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Demo notifications started'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enable notifications first',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSection(
              title: 'About',
              children: [
                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'App Version',
                  subtitle: '1.0.0',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help with using the app',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to help screen or show help dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support coming soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to privacy policy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Logout Section
            _buildSection(
              title: 'Account',
              children: [
                _buildSettingsTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showLogoutDialog,
                  textColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userPhone ?? 'No phone number',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: trailing,
      onTap: onTap,
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
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A modern smart home control application built with Flutter.'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Device Management'),
            Text('• Real-time Control'),
            Text('• Automation'),
            Text('• Multiple Themes'),
            Text('• Offline Support'),
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
}
