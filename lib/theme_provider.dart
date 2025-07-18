import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme preference

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode(); // Load saved theme when provider is created
  }

  // Toggles the theme between light and dark.
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(_themeMode); // Save the new theme
    notifyListeners(); // Notify listeners to rebuild UI
  }

  // Loads the theme preference from SharedPreferences.
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final int? themeIndex = prefs.getInt('themeMode');
    if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
  }

  // Saves the current theme mode preference to SharedPreferences.
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }
}