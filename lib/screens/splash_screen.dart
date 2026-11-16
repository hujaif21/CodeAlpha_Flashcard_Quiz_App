import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWelcome();
  }

  _navigateToWelcome() async {
    // Wait for the animation to finish (2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child); // Smooth fade transition
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated SVG Logo
            SvgPicture.asset(
              'assets/images/logo.svg',
              width: 140,
              height: 140,
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack) // Pops in
                .shimmer(delay: 800.ms, duration: 1200.ms, color: Colors.white.withOpacity(0.2)), // Premium shine

            const SizedBox(height: 24),

            // Animated Text
            const Text(
              'BRAINBOUNTY',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.5, end: 0),
          ],
        ),
      ),
    );
  }
}