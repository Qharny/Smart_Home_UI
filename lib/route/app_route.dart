import 'package:flutter/material.dart';

import '../screens/add_device_screen.dart';
import '../screens/device_added_success_screen.dart';
import '../screens/device_control_screen.dart';
import '../screens/devices_screen.dart';
import '../screens/light_control_screen.dart';
import '../screens/main_screen.dart';
import '../screens/otp.dart';
import '../screens/scan_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash.dart';
import '../screens/welcome_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String verification = '/verification';
  static const String home = '/home';
  static const String devices = '/devices';
  static const String addDevice = '/add-device';
  static const String scan = '/scan';
  static const String deviceAddedSuccess = '/device-added-success';
  static const String lightControl = '/light-control';
  static const String deviceControl = '/device-control';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case verification:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => VerificationScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            userName: args?['userName'] ?? '',
          ),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case devices:
        return MaterialPageRoute(builder: (_) => const DevicesScreen());
      case addDevice:
        return MaterialPageRoute(builder: (_) => const AddDeviceScreen());
      case scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());
      case deviceAddedSuccess:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              DeviceAddedSuccessScreen(deviceName: args?['deviceName']),
        );
      case lightControl:
        return MaterialPageRoute(builder: (_) => const LightControlScreen());
      case deviceControl:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DeviceControlScreen(
            device: args?['device'],
            onDeviceStateChanged: args?['onDeviceStateChanged'],
          ),
        );
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
