import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',

    scaffoldBackgroundColor: const Color(0xFFF8FAFC),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      primary: const Color(0xFF2563EB),
      secondary: const Color(0xFF14B8A6),
      surface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),

        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
      ),
    ),
  );
}