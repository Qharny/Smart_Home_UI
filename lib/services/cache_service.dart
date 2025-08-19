import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _deviceStatesKey = 'device_states';
  static const String _userNameKey = 'user_name';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _themeModeKey = 'theme_mode';
  static const String _lastSyncTimeKey = 'last_sync_time';

  // Singleton pattern
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  late SharedPreferences _prefs;

  // Initialize shared preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Device States Management
  Future<void> saveDeviceState(
    String deviceId,
    Map<String, dynamic> state,
  ) async {
    final deviceStates = await getDeviceStates();
    deviceStates[deviceId] = state;
    await _prefs.setString(_deviceStatesKey, jsonEncode(deviceStates));
  }

  Future<Map<String, dynamic>> getDeviceStates() async {
    final String? deviceStatesJson = _prefs.getString(_deviceStatesKey);
    if (deviceStatesJson != null) {
      return Map<String, dynamic>.from(jsonDecode(deviceStatesJson));
    }
    return {};
  }

  Future<Map<String, dynamic>?> getDeviceState(String deviceId) async {
    final deviceStates = await getDeviceStates();
    return deviceStates[deviceId];
  }

  Future<void> updateDevicePowerState(String deviceId, bool isOn) async {
    final currentState = await getDeviceState(deviceId) ?? {};
    currentState['isOn'] = isOn;
    currentState['lastUpdated'] = DateTime.now().toIso8601String();
    await saveDeviceState(deviceId, currentState);
  }

  Future<bool?> getDevicePowerState(String deviceId) async {
    final state = await getDeviceState(deviceId);
    return state?['isOn'] as bool?;
  }

  // User Preferences
  Future<void> saveUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  // App Settings
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _prefs.setBool(_isFirstLaunchKey, isFirstLaunch);
  }

  bool isFirstLaunch() {
    return _prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'system';
  }

  // Sync Management
  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setString(_lastSyncTimeKey, time.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final timeString = _prefs.getString(_lastSyncTimeKey);
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  // Generic methods for other data
  Future<void> saveData(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      // For complex objects, convert to JSON
      await _prefs.setString(key, jsonEncode(value));
    }
  }

  T? getData<T>(String key) {
    return _prefs.get(key) as T?;
  }

  Future<void> removeData(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Check if data exists
  bool hasData(String key) {
    return _prefs.containsKey(key);
  }
}
