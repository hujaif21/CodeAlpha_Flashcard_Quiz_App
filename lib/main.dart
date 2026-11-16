import 'package:brainbounty/providers/mock_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'providers/app_provider.dart'; // <-- ADDED

void main() {
  runApp(
    // <-- ADDED MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => MockTestProvider()),
      ],
      child: const BrainBountyApp(),
    ),
  );
}

class BrainBountyApp extends StatelessWidget {
  const BrainBountyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainBounty',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }

}