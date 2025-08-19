# Smart Home App - Caching Guide

This guide explains how to use the shared preferences caching system implemented in the Smart Home app.

## Overview

The app uses SharedPreferences to cache various types of data locally on the device. This provides:
- Faster app startup
- Offline functionality
- Persistent user preferences
- Device state management

## Architecture

### 1. CacheService (`lib/services/cache_service.dart`)
The main service that handles all shared preferences operations. It's implemented as a singleton pattern.

### 2. DeviceRepository (`lib/repositories/device_repository.dart`)
Manages device data and integrates with the cache service for device operations.

### 3. Device Model (`lib/models/device.dart`)
Represents smart home devices with their properties and methods.

## Usage Examples

### Basic Cache Operations

```dart
import '../services/cache_service.dart';

final cacheService = CacheService();

// Save data
await cacheService.saveData('key', 'value');
await cacheService.saveData('number', 42);
await cacheService.saveData('boolean', true);

// Retrieve data
String? value = cacheService.getData<String>('key');
int? number = cacheService.getData<int>('number');
bool? boolean = cacheService.getData<bool>('boolean');

// Check if data exists
bool hasData = cacheService.hasData('key');

// Remove specific data
await cacheService.removeData('key');

// Clear all data
await cacheService.clearAll();
```

### Device Management

```dart
import '../repositories/device_repository.dart';
import '../models/device.dart';

final deviceRepository = DeviceRepository();

// Get all devices
List<Device> devices = await deviceRepository.getAllDevices();

// Get specific device
Device? device = await deviceRepository.getDevice('device_id');

// Toggle device state
await deviceRepository.toggleDevice('device_id');

// Update device state
await deviceRepository.updateDeviceState('device_id', true);

// Add new device
Device newDevice = Device(
  id: 'new_device',
  name: 'New Light',
  imagePath: 'asset/images/bulb.png',
  type: 'light',
  isOn: false,
);
await deviceRepository.addDevice(newDevice);

// Remove device
await deviceRepository.removeDevice('device_id');

// Get device statistics
Map<String, dynamic> stats = await deviceRepository.getDeviceStatistics();
```

### User Preferences

```dart
// Save user name
await cacheService.saveUserName('John Doe');

// Get user name
String? userName = cacheService.getUserName();

// Save theme mode
await cacheService.saveThemeMode('dark');

// Get theme mode
String themeMode = cacheService.getThemeMode();

// Save custom preference
await cacheService.saveData('notifications_enabled', true);
bool? notificationsEnabled = cacheService.getData<bool>('notifications_enabled');
```

### Device State Management

```dart
// Save device state
Map<String, dynamic> state = {
  'isOn': true,
  'brightness': 80,
  'color': '#FF0000',
  'lastUpdated': DateTime.now().toIso8601String(),
};
await cacheService.saveDeviceState('light_1', state);

// Get device state
Map<String, dynamic>? deviceState = await cacheService.getDeviceState('light_1');

// Update power state
await cacheService.updateDevicePowerState('light_1', false);

// Get power state
bool? isOn = await cacheService.getDevicePowerState('light_1');
```

## Initialization

The cache service is automatically initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cache service
  await CacheService().init();
  
  runApp(const SmartHomeApp());
}
```

## Data Types Supported

The cache service supports the following data types:
- `String`
- `int`
- `double`
- `bool`
- `List<String>`
- Complex objects (automatically converted to JSON)

## Best Practices

1. **Always handle errors**: Wrap cache operations in try-catch blocks
2. **Use meaningful keys**: Use descriptive key names for better maintainability
3. **Check for null**: Always check if cached data exists before using it
4. **Clear old data**: Implement cleanup mechanisms for old cached data
5. **Validate data**: Validate cached data before using it in your app

## Example Implementation

Here's how the home screen uses caching:

```dart
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

  Future<void> _loadData() async {
    try {
      // Initialize default devices if needed
      await _deviceRepository.initializeDefaultDevices();
      
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
      await _deviceRepository.toggleDevice(deviceId);
      await _loadData(); // Reload data to reflect changes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle device: $e')),
      );
    }
  }
}
```

## Testing

To test the caching functionality:

1. **Run the app** and navigate to different screens
2. **Toggle devices** and verify the state persists after app restart
3. **Change settings** in the settings screen and verify they're saved
4. **Clear cache** using the "Clear All Data" button in settings
5. **Verify default data** is restored after clearing cache

## Troubleshooting

### Common Issues

1. **Data not persisting**: Ensure `CacheService().init()` is called before using the service
2. **Type errors**: Make sure to use the correct generic type when retrieving data
3. **Null values**: Always provide default values for cached data
4. **Performance issues**: Avoid storing large amounts of data in shared preferences

### Debug Tips

```dart
// Check if cache service is initialized
print('Cache initialized: ${cacheService.hasData('test_key')}');

// Print all cached data (for debugging)
// Note: This is not a built-in method, you'd need to implement it
```

## Future Enhancements

Potential improvements to the caching system:
- Add data encryption for sensitive information
- Implement cache expiration
- Add cache size management
- Create cache analytics and monitoring
- Add backup and restore functionality 