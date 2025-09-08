import 'dart:convert';

import '../models/automation.dart';
import '../models/device.dart';
import '../services/cache_service.dart';

class DeviceRepository {
  final CacheService _cacheService = CacheService();

  static const String _devicesKey = 'devices_list';
  static const String _automationsKey = 'automations_list';

  // Get all devices
  Future<List<Device>> getAllDevices() async {
    final devicesJson = _cacheService.getData<String>(_devicesKey);
    if (devicesJson != null) {
      final List<dynamic> devicesList = jsonDecode(devicesJson);
      final devices = devicesList.map((json) => Device.fromMap(json)).toList();

      // Update device states from cache service
      for (final device in devices) {
        final cachedState = await _cacheService.getDevicePowerState(device.id);
        if (cachedState != null && cachedState != device.isOn) {
          // Update device state from cache
          device.isOn = cachedState;
        }
      }

      return devices;
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
    print('DeviceRepository: Updating device $deviceId state to: $isOn');
    final devices = await getAllDevices();
    final deviceIndex = devices.indexWhere((device) => device.id == deviceId);

    if (deviceIndex != -1) {
      devices[deviceIndex] = devices[deviceIndex].copyWith(
        isOn: isOn,
        lastUpdated: DateTime.now(),
      );

      // Save to both device list and individual device state cache
      await saveAllDevices(devices);
      await _cacheService.updateDevicePowerState(deviceId, isOn);
      print(
        'DeviceRepository: Device $deviceId state updated and saved to cache',
      );
    } else {
      print('DeviceRepository: Device $deviceId not found');
    }
  }

  // Update device brightness
  Future<void> updateDeviceBrightness(
    String deviceId,
    double brightness,
  ) async {
    print(
      'DeviceRepository: Updating device $deviceId brightness to: $brightness',
    );
    final devices = await getAllDevices();
    final deviceIndex = devices.indexWhere((device) => device.id == deviceId);

    if (deviceIndex != -1) {
      devices[deviceIndex] = devices[deviceIndex].copyWith(
        brightness: brightness,
        lastUpdated: DateTime.now(),
      );

      await saveAllDevices(devices);
      print(
        'DeviceRepository: Device $deviceId brightness updated and saved to cache',
      );
    } else {
      print('DeviceRepository: Device $deviceId not found');
    }
  }

  // Update device speed
  Future<void> updateDeviceSpeed(String deviceId, double speed) async {
    print('DeviceRepository: Updating device $deviceId speed to: $speed');
    final devices = await getAllDevices();
    final deviceIndex = devices.indexWhere((device) => device.id == deviceId);

    if (deviceIndex != -1) {
      devices[deviceIndex] = devices[deviceIndex].copyWith(
        speed: speed,
        lastUpdated: DateTime.now(),
      );

      await saveAllDevices(devices);
      print(
        'DeviceRepository: Device $deviceId speed updated and saved to cache',
      );
    } else {
      print('DeviceRepository: Device $deviceId not found');
    }
  }

  // Toggle device state
  Future<void> toggleDevice(String deviceId) async {
    print('DeviceRepository: Toggling device: $deviceId'); // Debug log
    final devices = await getAllDevices();
    final deviceIndex = devices.indexWhere((device) => device.id == deviceId);

    if (deviceIndex != -1) {
      print(
        'DeviceRepository: Device before toggle: ${devices[deviceIndex].isOn}',
      ); // Debug log
      final newState = !devices[deviceIndex].isOn;
      devices[deviceIndex] = devices[deviceIndex].copyWith(
        isOn: newState,
        lastUpdated: DateTime.now(),
      );
      print(
        'DeviceRepository: Device after toggle: ${devices[deviceIndex].isOn}',
      ); // Debug log

      // Save to both device list and individual device state cache
      await saveAllDevices(devices);
      await _cacheService.updateDevicePowerState(deviceId, newState);
      print('DeviceRepository: Devices saved to cache'); // Debug log
    } else {
      print('DeviceRepository: Device not found: $deviceId'); // Debug log
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

  // Force reinitialize devices (useful for updating device names)
  Future<void> forceReinitializeDevices() async {
    await saveAllDevices(_getDefaultDevices());
  }

  // Default devices for the app
  List<Device> _getDefaultDevices() {
    return [
      Device(
        id: 'light_1',
        name: 'Light',
        imagePath: 'asset/images/bulb.png',
        type: 'light',
        isOn: false,
        brightness: 50.0,
        speed: 50.0,
      ),
      Device(
        id: 'light_2',
        name: 'Light',
        imagePath: 'asset/images/bulb.png',
        type: 'light',
        isOn: false,
        brightness: 50.0,
        speed: 50.0,
      ),
      Device(
        id: 'fan_1',
        name: 'Fan',
        imagePath: 'asset/images/fan.png',
        type: 'fan',
        isOn: true,
        brightness: 50.0,
        speed: 50.0,
      ),
      Device(
        id: 'fan_2',
        name: 'Fan',
        imagePath: 'asset/images/fan.png',
        type: 'fan',
        isOn: true,
        brightness: 50.0,
        speed: 50.0,
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

  // ========== AUTOMATION METHODS ==========

  // Get all automations
  Future<List<Automation>> getAllAutomations() async {
    final automationsJson = _cacheService.getData<String>(_automationsKey);
    if (automationsJson != null) {
      final List<dynamic> automationsList = jsonDecode(automationsJson);
      return automationsList.map((json) => Automation.fromMap(json)).toList();
    }
    return [];
  }

  // Save all automations
  Future<void> saveAllAutomations(List<Automation> automations) async {
    final automationsJson = jsonEncode(
      automations.map((automation) => automation.toMap()).toList(),
    );
    await _cacheService.saveData(_automationsKey, automationsJson);
  }

  // Get automations for a specific device
  Future<List<Automation>> getAutomationsForDevice(String deviceId) async {
    final automations = await getAllAutomations();
    return automations
        .where((automation) => automation.deviceId == deviceId)
        .toList();
  }

  // Add new automation
  Future<void> addAutomation(Automation automation) async {
    final automations = await getAllAutomations();
    automations.add(automation);
    await saveAllAutomations(automations);
  }

  // Update automation
  Future<void> updateAutomation(Automation automation) async {
    final automations = await getAllAutomations();
    final index = automations.indexWhere((a) => a.id == automation.id);
    if (index != -1) {
      automations[index] = automation;
      await saveAllAutomations(automations);
    }
  }

  // Delete automation
  Future<void> deleteAutomation(String automationId) async {
    final automations = await getAllAutomations();
    automations.removeWhere((automation) => automation.id == automationId);
    await saveAllAutomations(automations);
  }

  // Toggle automation enabled state
  Future<void> toggleAutomation(String automationId) async {
    final automations = await getAllAutomations();
    final index = automations.indexWhere((a) => a.id == automationId);
    if (index != -1) {
      automations[index] = automations[index].copyWith(
        isEnabled: !automations[index].isEnabled,
      );
      await saveAllAutomations(automations);
    }
  }

  // Execute automation
  Future<void> executeAutomation(Automation automation) async {
    try {
      switch (automation.action) {
        case 'on':
          await updateDeviceState(automation.deviceId, true);
          break;
        case 'off':
          await updateDeviceState(automation.deviceId, false);
          break;
        case 'brightness':
          if (automation.value != null) {
            await updateDeviceBrightness(
              automation.deviceId,
              automation.value!,
            );
          }
          break;
        case 'speed':
          if (automation.value != null) {
            await updateDeviceSpeed(automation.deviceId, automation.value!);
          }
          break;
      }

      // Update last executed time
      final updatedAutomation = automation.copyWith(
        lastExecuted: DateTime.now(),
      );
      await updateAutomation(updatedAutomation);

      print(
        'Automation executed: ${automation.deviceName} - ${automation.actionDisplayText}',
      );
    } catch (e) {
      print('Failed to execute automation: $e');
    }
  }

  // Check and execute pending automations
  Future<void> checkAndExecuteAutomations() async {
    final automations = await getAllAutomations();
    final now = DateTime.now();

    for (final automation in automations) {
      if (automation.isEnabled &&
          automation.isTimeToExecute() &&
          (automation.lastExecuted == null ||
              now.difference(automation.lastExecuted!).inMinutes > 1)) {
        await executeAutomation(automation);
      }
    }
  }

  // Clear all automations
  Future<void> clearAllAutomations() async {
    await _cacheService.removeData(_automationsKey);
  }
}
