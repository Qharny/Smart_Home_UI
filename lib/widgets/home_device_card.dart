import 'package:flutter/material.dart';

import '../services/cache_service.dart';

class HomeDeviceCard extends StatefulWidget {
  final String deviceId;
  final String name;
  final String imagePath;
  final bool isOn;
  final Function(bool) onToggle;
  final VoidCallback? onViewControls;

  const HomeDeviceCard({
    super.key,
    required this.deviceId,
    required this.name,
    required this.imagePath,
    required this.isOn,
    required this.onToggle,
    this.onViewControls,
  });

  @override
  State<HomeDeviceCard> createState() => _HomeDeviceCardState();
}

class _HomeDeviceCardState extends State<HomeDeviceCard> {
  bool _localIsOn = false;
  final CacheService _cacheService = CacheService();

  @override
  void initState() {
    super.initState();
    _loadDeviceState();
  }

  Future<void> _loadDeviceState() async {
    // Load device state from cache service using device ID
    final cachedState = await _cacheService.getDevicePowerState(
      widget.deviceId,
    );
    print(
      'HomeDeviceCard: Loading state for ${widget.name} (${widget.deviceId}), cached: $cachedState, widget.isOn: ${widget.isOn}',
    );
    setState(() {
      _localIsOn = cachedState ?? widget.isOn;
    });
    print('HomeDeviceCard: Final local state for ${widget.name}: $_localIsOn');
  }

  @override
  void didUpdateWidget(HomeDeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOn != widget.isOn) {
      print(
        'HomeDeviceCard: Widget state changed for ${widget.name}, old: ${oldWidget.isOn}, new: ${widget.isOn}',
      );
      setState(() {
        _localIsOn = widget.isOn;
      });
      print(
        'HomeDeviceCard: Updated local state for ${widget.name}: $_localIsOn',
      );
    }
  }

  Future<void> _handleToggle() async {
    print(
      'HomeDeviceCard: Toggle tapped for ${widget.name}, current state: $_localIsOn',
    ); // Debug log
    print('HomeDeviceCard: Calling onToggle with: ${!_localIsOn}'); // Debug log

    // Update local state immediately for visual feedback
    setState(() {
      _localIsOn = !_localIsOn;
    });

    // Call the parent callback
    await widget.onToggle(_localIsOn);
    print(
      'HomeDeviceCard: Toggle completed for ${widget.name}, new state: $_localIsOn',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
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
      child: Stack(
        children: [
          // Image positioned to touch the right edge
          Positioned(
            right: 0,
            top: 0,
            bottom: 30,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                child: Image.asset(widget.imagePath, fit: BoxFit.cover),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title at the top left
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Custom toggle button
                GestureDetector(
                  onTap: _handleToggle,
                  child: Container(
                    width: 30,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _localIsOn ? Colors.black : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Toggle circle
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          left: 2,
                          top: _localIsOn ? 2 : 22,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // View controls button at the bottom
                SizedBox(
                  height: 30,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: widget.onViewControls,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    child: const Text(
                      'View controls',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
