import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/notification_overlay.dart';

class NotificationService extends ChangeNotifier {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _autoSyncEnabledKey = 'auto_sync_enabled';
  static const String _syncFrequencyKey = 'sync_frequency';

  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  String _syncFrequency = 'Every 5 minutes';
  Timer? _syncTimer;
  Timer? _demoNotificationTimer;

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _loadSettings();
  }

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSyncEnabled => _autoSyncEnabled;
  String get syncFrequency => _syncFrequency;

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    _autoSyncEnabled = prefs.getBool(_autoSyncEnabledKey) ?? true;
    _syncFrequency = prefs.getString(_syncFrequencyKey) ?? 'Every 5 minutes';

    if (_notificationsEnabled && _autoSyncEnabled) {
      _startSyncTimer();
    }

    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, _notificationsEnabled);
    await prefs.setBool(_autoSyncEnabledKey, _autoSyncEnabled);
    await prefs.setString(_syncFrequencyKey, _syncFrequency);
  }

  // Toggle notifications
  Future<void> toggleNotifications(
    bool enabled, {
    BuildContext? context,
  }) async {
    _notificationsEnabled = enabled;
    await _saveSettings();

    if (enabled && _autoSyncEnabled) {
      _startSyncTimer();
      // Show immediate demo notification
      _showDemoNotification(
        'Notifications Enabled',
        'You will now receive device alerts and updates',
        Icons.notifications_active,
        context: context,
      );
    } else {
      _stopSyncTimer();
      _stopDemoNotificationTimer();
    }

    notifyListeners();
  }

  // Toggle auto sync
  Future<void> toggleAutoSync(bool enabled) async {
    _autoSyncEnabled = enabled;
    await _saveSettings();

    if (enabled && _notificationsEnabled) {
      _startSyncTimer();
    } else {
      _stopSyncTimer();
    }

    notifyListeners();
  }

  // Set sync frequency
  Future<void> setSyncFrequency(String frequency) async {
    _syncFrequency = frequency;
    await _saveSettings();

    if (_notificationsEnabled && _autoSyncEnabled) {
      _startSyncTimer();
    }

    notifyListeners();
  }

  // Start sync timer based on frequency
  void _startSyncTimer() {
    _stopSyncTimer();

    final duration = _getSyncDuration();
    if (duration != null) {
      _syncTimer = Timer.periodic(duration, (timer) {
        _performSync();
      });
    }
  }

  // Stop sync timer
  void _stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Stop demo notification timer
  void _stopDemoNotificationTimer() {
    _demoNotificationTimer?.cancel();
    _demoNotificationTimer = null;
  }

  // Get sync duration from frequency string
  Duration? _getSyncDuration() {
    switch (_syncFrequency) {
      case 'Every 1 minute':
        return const Duration(minutes: 1);
      case 'Every 5 minutes':
        return const Duration(minutes: 5);
      case 'Every 15 minutes':
        return const Duration(minutes: 15);
      case 'Every 30 minutes':
        return const Duration(minutes: 30);
      case 'Every hour':
        return const Duration(hours: 1);
      case 'Manual only':
        return null;
      default:
        return const Duration(minutes: 5);
    }
  }

  // Perform sync operation
  void _performSync() {
    if (!_notificationsEnabled) return;

    // Simulate sync operation
    _showDemoNotification(
      'Device Sync',
      'All devices have been synchronized successfully',
      Icons.sync,
    );
  }

  // Show demo notification
  void _showDemoNotification(
    String title,
    String body,
    IconData icon, {
    BuildContext? context,
  }) {
    // This would typically use a notification plugin like flutter_local_notifications
    // For now, we'll show in-app notifications using overlay
    print('Notification: $title - $body');

    if (context != null) {
      NotificationOverlay.show(
        context: context,
        title: title,
        body: body,
        icon: icon,
      );
    }
  }

  // Show device-specific notifications
  void showDeviceNotification(
    String deviceName,
    String action,
    bool isOn, {
    BuildContext? context,
  }) {
    if (!_notificationsEnabled) return;

    final status = isOn ? 'turned on' : 'turned off';
    _showDemoNotification(
      'Device Update',
      '$deviceName has been $status',
      isOn ? Icons.power : Icons.power_off,
      context: context,
    );
  }

  // Show automation notification
  void showAutomationNotification(String automationName, String deviceName) {
    if (!_notificationsEnabled) return;

    _showDemoNotification(
      'Automation Triggered',
      '$automationName activated for $deviceName',
      Icons.schedule,
    );
  }

  // Show connection notification
  void showConnectionNotification(String deviceName, bool connected) {
    if (!_notificationsEnabled) return;

    final status = connected ? 'connected' : 'disconnected';
    _showDemoNotification(
      'Device $status',
      '$deviceName has $status',
      connected ? Icons.wifi : Icons.wifi_off,
    );
  }

  // Show battery low notification
  void showBatteryLowNotification(String deviceName, int batteryLevel) {
    if (!_notificationsEnabled) return;

    _showDemoNotification(
      'Low Battery',
      '$deviceName battery is at $batteryLevel%',
      Icons.battery_alert,
    );
  }

  // Show security notification
  void showSecurityNotification(String message) {
    if (!_notificationsEnabled) return;

    _showDemoNotification('Security Alert', message, Icons.security);
  }

  // Start demo notifications for testing
  void startDemoNotifications() {
    if (!_notificationsEnabled) return;

    _stopDemoNotificationTimer();

    // Show demo notifications every 10 seconds for testing
    _demoNotificationTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) {
      _showRandomDemoNotification();
    });
  }

  // Stop demo notifications
  void stopDemoNotifications() {
    _stopDemoNotificationTimer();
  }

  // Show random demo notification
  void _showRandomDemoNotification() {
    if (!_notificationsEnabled) return;

    final random = Random();
    final notifications = [
      {
        'title': 'Living Room Light',
        'body': 'Living Room Light has been turned on',
        'icon': Icons.lightbulb,
      },
      {
        'title': 'Kitchen Fan',
        'body': 'Kitchen Fan speed increased to 75%',
        'icon': Icons.ac_unit,
      },
      {
        'title': 'Bedroom AC',
        'body': 'Bedroom AC temperature set to 22°C',
        'icon': Icons.thermostat,
      },
      {
        'title': 'Security Camera',
        'body': 'Motion detected in the living room',
        'icon': Icons.camera_alt,
      },
      {
        'title': 'Smart Lock',
        'body': 'Front door has been unlocked',
        'icon': Icons.lock_open,
      },
      {
        'title': 'Washing Machine',
        'body': 'Washing cycle completed',
        'icon': Icons.local_laundry_service,
      },
    ];

    final notification = notifications[random.nextInt(notifications.length)];
    _showDemoNotification(
      notification['title'] as String,
      notification['body'] as String,
      notification['icon'] as IconData,
    );
  }

  // Check if demo notifications are running
  bool get isDemoNotificationsRunning =>
      _demoNotificationTimer?.isActive ?? false;

  // Clean up resources
  void dispose() {
    _stopSyncTimer();
    _stopDemoNotificationTimer();
    super.dispose();
  }
}
