import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.light,
      // 1. APPLY INTER FONT GLOBALLY (Preserved from your setup)
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      // 2. USE STANDARD LIGHT TEXT THEME WITH OXFORD NAVY TYPOGRAPHY
      textTheme: ThemeData.light().textTheme.copyWith(
        bodyLarge: const TextStyle(color: AppColors.textPrimary),
        bodyMedium: const TextStyle(color: AppColors.textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}