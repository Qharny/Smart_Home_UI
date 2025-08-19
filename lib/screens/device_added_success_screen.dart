import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../route/app_route.dart';

class DeviceAddedSuccessScreen extends StatelessWidget {
  final String? deviceName;

  const DeviceAddedSuccessScreen({super.key, this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Message
                const Text(
                  'Device is successfully added',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),
                // add svg
                SvgPicture.asset(
                  'asset/images/check_svg.svg',
                  width: 150,
                  height: 150,
                ),

                // Success Icon with jagged outline
                // Container(
                //   width: 120,
                //   height: 120,
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.white,
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.1),
                //         blurRadius: 20,
                //         offset: const Offset(0, 10),
                //       ),
                //     ],
                //   ),
                //   child: Stack(
                //     children: [
                //       // Jagged outline (star-like/cog-like)
                //       Center(
                //         child: CustomPaint(
                //           size: const Size(100, 100),
                //           painter: JaggedCirclePainter(),
                //         ),
                //       ),
                //       // Checkmark icon
                //       const Center(
                //         child: Icon(
                //           Icons.check,
                //           size: 60,
                //           color: Colors.black,
                //           weight: 900,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                const SizedBox(height: 60),

                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to home page
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.home,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: const Text(
                      'Go back to home page',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Secondary Action Link
                GestureDetector(
                  onTap: () {
                    // Navigate to device details or devices page
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.devices,
                      (route) => false,
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      children: [
                        const TextSpan(text: 'or visit '),
                        TextSpan(
                          text: 'device details',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class JaggedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    final path = Path();

    // Create a jagged circle with 12 points
    const numPoints = 12;
    for (int i = 0; i < numPoints; i++) {
      final angle = (i * 2 * 3.14159) / numPoints;
      final isOuter = i % 2 == 0;
      final currentRadius = isOuter ? radius : radius * 0.8;

      final x = center.dx + currentRadius * cos(angle);
      final y = center.dy + currentRadius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
