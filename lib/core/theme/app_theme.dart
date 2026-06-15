import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF11645D);
  static const primaryDark = Color(0xFF0E5B55);
  static const text = Color(0xFF142522);
  static const muted = Color(0xFF60716E);
  static const background = Color(0xFFF7FAF9);
  static const border = Color(0xFFE2ECE9);
  static const peach = Color(0xFFDC8D58);
  static const warningBackground = Color(0xFFFFF8F1);
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.peach,
        surface: Colors.white,
        onSurface: AppColors.text,
        outline: AppColors.border,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.text,
          fontSize: 30,
          height: 1.12,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineSmall: TextStyle(
          color: AppColors.text,
          fontSize: 21,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: AppColors.text,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.text, fontSize: 15, height: 1.45),
        bodyMedium: TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          height: 1.45,
        ),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xFF8A9C99), fontSize: 14),
        prefixIconColor: const Color(0xFF718581),
        suffixIconColor: const Color(0xFF718581),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(AppColors.primary, 1.4),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFDDF0ED),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder([
    Color color = AppColors.border,
    double width = 1,
  ]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
