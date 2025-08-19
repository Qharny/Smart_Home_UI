import 'dart:convert';

import '../models/device.dart';
import '../services/cache_service.dart';

class DeviceRepository {
  final CacheService _cacheService = CacheService();

  static const String _devicesKey = 'devices_list';

  // Get all devices
  Future<List<Device>> getAllDevices() async {
    final devicesJson = _cacheService.getData<String>(_devicesKey);
    if (devicesJson != null) {
      final List<dynamic> devicesList = jsonDecode(devicesJson);
      return devicesList.map((json) => Device.fromMap(json)).toList();
    }

    // Return default devices if none are cached
    return _getDefaultDevices();
  }

  // Save all devices
  Future<void> saveAllDevices(List<Device> devices) async {
    final devicesJson = jsonEncode(
      devices.map((device) => device.toMap()).toList(),
    );
    await _cacheService.saveData(_devicesKey, devicesJson);
  }

  // Get a specific device
  Future<Device?> getDevice(String deviceId) async {
    final devices = await getAllDevices();
    try {
      return devices.firstWhere((device) => device.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  // Update device state
  Future<void> updateDeviceState(String deviceId, bool isOn) async {
    final devices = await getAllDevices();
    final deviceIndex = devices.indexWhere((device) => device.id == deviceId);

    if (deviceIndex != -1) {
      devices[deviceIndex] = devices[deviceIndex].copyWith(
        isOn: isOn,
        lastUpdated: DateTime.now(),
      );
      await saveAllDevices(devices);
    }
  }

  // Toggle device state
  Future<void> toggleDevice(String deviceId) async {
    final devices = await getAllDevices();
    final deviceIndex = devices.indexWhere((device) => device.id == deviceId);

    if (deviceIndex != -1) {
      devices[deviceIndex] = devices[deviceIndex].toggle();
      await saveAllDevices(devices);
    }
  }

  // Add new device
  Future<void> addDevice(Device device) async {
    final devices = await getAllDevices();
    devices.add(device);
    await saveAllDevices(devices);
  }

  // Remove device
  Future<void> removeDevice(String deviceId) async {
    final devices = await getAllDevices();
    devices.removeWhere((device) => device.id == deviceId);
    await saveAllDevices(devices);
  }

  // Get devices by type
  Future<List<Device>> getDevicesByType(String type) async {
    final devices = await getAllDevices();
    return devices.where((device) => device.type == type).toList();
  }

  // Get powered on devices
  Future<List<Device>> getPoweredOnDevices() async {
    final devices = await getAllDevices();
    return devices.where((device) => device.isOn).toList();
  }

  // Get powered off devices
  Future<List<Device>> getPoweredOffDevices() async {
    final devices = await getAllDevices();
    return devices.where((device) => !device.isOn).toList();
  }

  // Clear all cached devices
  Future<void> clearAllDevices() async {
    await _cacheService.removeData(_devicesKey);
  }

  // Initialize with default devices
  Future<void> initializeDefaultDevices() async {
    final devices = await getAllDevices();
    if (devices.isEmpty) {
      await saveAllDevices(_getDefaultDevices());
    }
  }

  // Default devices for the app
  List<Device> _getDefaultDevices() {
    return [
      Device(
        id: 'light_1',
        name: 'bulb',
        imagePath: 'asset/images/bulb.png',
        type: 'light',
        isOn: false,
      ),
      Device(
        id: 'light_2',
        name: 'bulb',
        imagePath: 'asset/images/bulb.png',
        type: 'light',
        isOn: false,
      ),
      Device(
        id: 'fan_1',
        name: 'fan',
        imagePath: 'asset/images/fan.png',
        type: 'fan',
        isOn: true,
      ),
      Device(
        id: 'fan_2',
        name: 'fan',
        imagePath: 'asset/images/fan.png',
        type: 'fan',
        isOn: true,
      ),
    ];
  }

  // Get device statistics
  Future<Map<String, dynamic>> getDeviceStatistics() async {
    final devices = await getAllDevices();
    final totalDevices = devices.length;
    final poweredOnDevices = devices.where((device) => device.isOn).length;
    final poweredOffDevices = totalDevices - poweredOnDevices;

    final devicesByType = <String, int>{};
    for (final device in devices) {
      devicesByType[device.type] = (devicesByType[device.type] ?? 0) + 1;
    }

    return {
      'totalDevices': totalDevices,
      'poweredOnDevices': poweredOnDevices,
      'poweredOffDevices': poweredOffDevices,
      'devicesByType': devicesByType,
    };
  }
}
