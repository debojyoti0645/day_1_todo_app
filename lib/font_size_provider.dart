import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSizeOption { small, medium, large }

class FontSizeProvider with ChangeNotifier {
  FontSizeOption _fontSizeOption = FontSizeOption.medium;

  FontSizeOption get fontSizeOption => _fontSizeOption;

  FontSizeProvider() {
    _loadFontSizeOption();
  }

  void setFontSizeOption(FontSizeOption option) {
    if (_fontSizeOption != option) {
      _fontSizeOption = option;
      _saveFontSizeOption(option);
      notifyListeners();
    }
  }

  Future<void> _loadFontSizeOption() async {
    final prefs = await SharedPreferences.getInstance();
    final int? fontSizeIndex = prefs.getInt('fontSizeOption');
    if (fontSizeIndex != null &&
        fontSizeIndex >= 0 &&
        fontSizeIndex < FontSizeOption.values.length) {
      _fontSizeOption = FontSizeOption.values[fontSizeIndex];
      notifyListeners();
    }
  }

  Future<void> _saveFontSizeOption(FontSizeOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontSizeOption', option.index);
  }
}
