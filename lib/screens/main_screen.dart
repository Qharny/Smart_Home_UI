import 'package:flutter/material.dart';

import '../route/app_route.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [const HomeScreen(), const DevicesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Handle navigation based on selected index
          switch (index) {
            case 2: // Add tab
              Navigator.pushReplacementNamed(context, AppRouter.addDevice);
              // Reset to home tab after navigation
              setState(() {
                _selectedIndex = 0;
              });
              break;
          }
        },
      ),
    );
  }
}
