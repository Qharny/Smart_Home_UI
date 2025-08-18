import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';
import '../widgets/device_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hamburger menu
                  IconButton(
                    onPressed: () {
                      // TODO: Implement menu
                    },
                    icon: const Icon(Icons.menu, size: 24),
                  ),
                  // Right side icons
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Implement notifications
                        },
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          // TODO: Implement profile
                        },
                        icon: const Icon(Icons.person_outline, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('asset/images/home.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Hi Mark,',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Welcome to your Smart Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Devices Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Devices',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to all devices
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Devices Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        DeviceCard(
                          name: 'Light',
                          imagePath: 'asset/images/bulb.png',
                          isOn: false,
                          onToggle: (value) {
                            setState(() {
                              // TODO: Implement light toggle
                            });
                          },
                          onViewControls: () {
                            // TODO: Navigate to light controls
                          },
                        ),
                        DeviceCard(
                          name: 'Fan',
                          imagePath: 'asset/images/fan.png',
                          isOn: true,
                          onToggle: (value) {
                            setState(() {
                              // TODO: Implement fan toggle
                            });
                          },
                          onViewControls: () {
                            // TODO: Navigate to fan controls
                          },
                        ),
                        DeviceCard(
                          name: 'Light',
                          imagePath: 'asset/images/bulb.png',
                          isOn: false,
                          onToggle: (value) {
                            setState(() {
                              // TODO: Implement light toggle
                            });
                          },
                          onViewControls: () {
                            // TODO: Navigate to light controls
                          },
                        ),
                        DeviceCard(
                          name: 'Fan',
                          imagePath: 'asset/images/fan.png',
                          isOn: true,
                          onToggle: (value) {
                            setState(() {
                              // TODO: Implement fan toggle
                            });
                          },
                          onViewControls: () {
                            // TODO: Navigate to fan controls
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
