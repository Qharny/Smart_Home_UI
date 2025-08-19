import 'package:flutter/material.dart';

import '../route/app_route.dart';
import '../services/cache_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final CacheService _cacheService = CacheService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Check if user is already logged in
      final isLoggedIn = _cacheService.isLoggedIn();
      
      if (isLoggedIn) {
        // User is logged in, navigate to home
        Navigator.pushReplacementNamed(context, AppRouter.home);
      } else {
        // User is not logged in, navigate to welcome screen
        Navigator.pushReplacementNamed(context, AppRouter.welcome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0), // Light gray background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Image.asset(
              'asset/images/Frame 3 1.png',
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the house icon
class HousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw the house base (rectangle)
    final baseRect = Rect.fromLTWH(
      0,
      size.height * 0.4,
      size.width,
      size.height * 0.6,
    );
    canvas.drawRect(baseRect, paint);

    // Draw the roof (triangle)
    final path = Path();
    path.moveTo(size.width * 0.5, 0); // Top point
    path.lineTo(0, size.height * 0.4); // Bottom left
    path.lineTo(size.width, size.height * 0.4); // Bottom right
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
