import 'package:flutter/material.dart';

class AppThemes {
  // Base text style for both themes
  static const _baseTextStyle = TextStyle(fontFamily: 'Roboto');

  // Light theme configuration
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
      primary: Colors.blue,
      onPrimary: Colors.black,
      secondary: Colors.lightBlueAccent,
      onSecondary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black87,
      error: Colors.red,
      onError: Colors.white,
      shadow: Colors.grey.shade300, // Custom shadow color for light mode
    ),
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      color: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: const Color.fromARGB(255, 255, 255, 255),
    textTheme: TextTheme(
      headlineLarge: _baseTextStyle.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: _baseTextStyle.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleLarge: _baseTextStyle.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: _baseTextStyle.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
      bodyLarge: _baseTextStyle.copyWith(color: Colors.black87, fontSize: 16),
      bodyMedium: _baseTextStyle.copyWith(color: Colors.black54, fontSize: 14),
      bodySmall: _baseTextStyle.copyWith(color: Colors.black45, fontSize: 12),
      labelLarge: _baseTextStyle.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.blue;
        }
        return Colors.grey;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: _baseTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: _baseTextStyle.copyWith(color: Colors.grey[600]),
    ),
  );

  // Dark theme configuration
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.indigo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
      primary: Colors.indigo,
      onPrimary: Colors.white,
      secondary: Colors.cyan,
      onSecondary: Colors.black,
      background: Colors.black,
      onBackground: Colors.white70,
      surface: Colors.grey[900],
      onSurface: Colors.white70,
      error: Colors.redAccent,
      onError: Colors.white,
      shadow: Colors.black54, // Custom shadow color for dark mode
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      color: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: _baseTextStyle.copyWith(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardColor: Colors.grey[850],
    textTheme: TextTheme(
      headlineLarge: _baseTextStyle.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: _baseTextStyle.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleLarge: _baseTextStyle.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: _baseTextStyle.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
      bodyLarge: _baseTextStyle.copyWith(color: Colors.white70, fontSize: 16),
      bodyMedium: _baseTextStyle.copyWith(color: Colors.white54, fontSize: 14),
      bodySmall: _baseTextStyle.copyWith(color: Colors.white38, fontSize: 12),
      labelLarge: _baseTextStyle.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.indigo;
        }
        return Colors.grey[700];
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: _baseTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: _baseTextStyle.copyWith(color: Colors.grey[400]),
    ),
  );
}
