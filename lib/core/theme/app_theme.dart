import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFAF6F1);
  static const cream = Color(0xFFF0E5D8);
  static const brown = Color(0xFF825B42);
  static const ink = Color(0xFF392D26);
  static const muted = Color(0xFF7D7066);
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brown,
      surface: AppColors.background,
      primary: AppColors.brown,
    ),
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE4D9CE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.brown, width: 2),
      ),
    ),
  );
}
