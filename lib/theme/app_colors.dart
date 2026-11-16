import 'package:flutter/material.dart';

class AppColors {
  // 60% BASE: High-Purple Lavender Mist & Floating White Surfaces
  static const Color background = Color(0xFFF5F3FF); // Soft Violet-Ice base
  static const Color backgroundAlt = Color(0xFFEDE9FE); // Rich Lavender tint for badges/bars
  static const Color surface = Color(0xFFFFFFFF); // Pure White 3D floating cards

  // 30% TYPOGRAPHY: Deep Cosmic Indigo (Matches the purple family instead of plain black)
  static const Color textPrimary = Color(0xFF1E1B4B); // Ultra-crisp Deep Violet-Navy
  static const Color textMuted = Color(0xFF6D28D9); // Muted Royal Purple for subtitles

  // 10% HERO LOGO ACCENTS (Exact match to your SVG!)
  static const Color primary = Color(0xFF7C3AED); // SVG Brain Hemisphere Purple
  static const Color primaryLight = Color(0xFF8B5CF6); // Vivid Electric Violet for 3D lips
  static const Color accentGold = Color(0xFFD97706); // SVG Inner Coin Deep Amber

  // BOUNTY & STATUS COLORS
  static const Color gold = Color(0xFFF59E0B); // SVG Outer Coin Gold
  static const Color success = Color(0xFF10B981); // Crisp Mint (pops against purple)
  static const Color warning = Color(0xFFF97316); // Vibrant Orange
  static const Color danger = Color(0xFFEF4444); // Coral Red

  // --- 3D & RGB GRADIENT PRESETS ---

  // 1. High-Purple RGB Aurora Background Mesh
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEDE9FE), // Top-Left: High-Purple Lavender Glow
      Color(0xFFFDF4FF), // Center: Crisp Orchid-White
      Color(0xFFFFFBEB), // Bottom-Right: Warm Gold-Tinted Mist (echoes the coin!)
    ],
    stops: [0.0, 0.55, 1.0],
  );

  // 2. Signature "Royal Purple Wave" Gradient (Buttons, Active Pills, Badges)
  static const LinearGradient waveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5B21B6), // Deep Royal Violet
      Color(0xFF7C3AED), // Exact Logo Purple (#7C3AED)
      Color(0xFFC026D3), // Electric Fuchsia-Violet highlight
    ],
  );

  // 3. 3D Coin Gold Gradient (Exact match to your SVG coin #F59E0B -> #D97706)
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFBBF24), // Top light catch
      Color(0xFFF59E0B), // Exact SVG Outer Coin (#F59E0B)
      Color(0xFFD97706), // Exact SVG Inner Coin (#D97706)
    ],
  );

  // 4. 3D Floating Card Shadow (Colored Purple Ambient Glow)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withOpacity(0.14),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: const Color(0xFF5B21B6).withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}