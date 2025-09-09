import 'package:flutter/material.dart';
import 'package:smart_home/screens/devices_screen.dart';

import '../screens/control_screen.dart';
import '../screens/main_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/otp.dart';
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
  static const String notifications = '/notifications';

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
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MainScreen(initialIndex: args?['initialIndex'] ?? 0),
        );
      case devices:
        return MaterialPageRoute(builder: (_) => const DevicesScreen());
      case lightControl:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DeviceControlScreen(
            deviceName: args?['deviceName'] ?? 'Device',
            deviceId: args?['deviceId'] ?? '',
            deviceType: args?['deviceType'] ?? 'light',
            isOn: args?['isOn'] ?? false,
            brightness: args?['brightness'] ?? 50.0,
            speed: args?['speed'] ?? 50.0,
            imagePath: args?['imagePath'] ?? 'asset/images/bulb.png',
          ),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
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
