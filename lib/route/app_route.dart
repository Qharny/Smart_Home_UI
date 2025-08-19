import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/light_control_screen.dart';
import '../screens/otp.dart';
import '../screens/settings_screen.dart';
import '../screens/splash.dart';
import '../screens/welcome_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String verification = '/verification';
  static const String home = '/home';
  static const String lightControl = '/light-control';
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
          builder: (_) =>
              VerificationScreen(phoneNumber: args?['phoneNumber'] ?? ''),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case lightControl:
        return MaterialPageRoute(builder: (_) => const LightControlScreen());
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
