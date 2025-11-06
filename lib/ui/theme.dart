import 'package:flutter/material.dart';

/// App color palette with purple, white, and yellow theme
class AppColors {
  // Purple shades
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA78BFA);
  static const Color palePurple = Color(0xFFEDE9FE);

  // Accent
  static const Color accentYellow = Color(0xFFFCD34D);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color backgroundGray = Color(0xFFF9FAFB);

  // Status colors
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
}

/// Light theme configuration
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryPurple,
    secondary: AppColors.accentYellow,
    surface: AppColors.white,
    error: AppColors.errorRed,
  ),
  scaffoldBackgroundColor: AppColors.backgroundGray,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryPurple,
    foregroundColor: AppColors.white,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: AppColors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.textGray),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.textGray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.errorRed),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryPurple,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 2,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accentYellow,
    foregroundColor: AppColors.textDark,
    elevation: 4,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textDark,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textGray,
    ),
  ),
);

/// Dark theme configuration
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.lightPurple,
    secondary: AppColors.accentYellow,
    surface: Color(0xFF1F2937),
    error: AppColors.errorRed,
  ),
  scaffoldBackgroundColor: const Color(0xFF111827),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F2937),
    foregroundColor: AppColors.white,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    elevation: 4,
    color: const Color(0xFF1F2937),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF374151),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF4B5563)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF4B5563)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.lightPurple, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPurple,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF9CA3AF),
    ),
  ),
);
