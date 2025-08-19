import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/light_control_screen.dart';
import '../screens/otp.dart';
import '../screens/splash.dart';
import '../screens/welcome_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String verification = '/verification';
  static const String home = '/home';
  static const String lightControl = '/light-control';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case verification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              VerificationScreen(phoneNumber: args?['phoneNumber'] ?? ''),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case lightControl:
        return MaterialPageRoute(builder: (_) => const LightControlScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
