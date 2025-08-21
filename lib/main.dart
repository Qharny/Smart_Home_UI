import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/route/app_route.dart';
import 'package:smart_home/services/cache_service.dart';
import 'package:smart_home/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cache service
  await CacheService().init();
  
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Smart Home',
            debugShowCheckedModeBanner: false,
            theme: themeService.currentTheme,
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}