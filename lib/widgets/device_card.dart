import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool isOn;
  final Function(bool) onToggle;
  final VoidCallback? onViewControls;

  const DeviceCard({
    super.key,
    required this.name,
    required this.imagePath,
    required this.isOn,
    required this.onToggle,
    this.onViewControls,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title at the top
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),

          // Toggle and Icon side by side
          Expanded(
            child: Row(
              children: [
                // Vertical Toggle Switch on the left
                Transform.rotate(
                  angle: -1.5708, // -90 degrees in radians
                  child: Switch(
                    value: isOn,
                    onChanged: onToggle,
                    activeColor: name == 'Fan' ? Colors.black : Colors.transparent,
                    inactiveThumbColor: Colors.black,
                    inactiveTrackColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 16),

                // Image on the right
                Expanded(
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      width: 50,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // View controls button at the bottom
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewControls,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'View controls',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
