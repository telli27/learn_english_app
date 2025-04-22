import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeController() : super(ThemeMode.light) {
    _loadThemeFromPrefs();
  }

  bool get isDarkMode => state == ThemeMode.dark;

  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();
    String themeName;

    switch (mode) {
      case ThemeMode.dark:
        themeName = 'dark';
        break;
      case ThemeMode.light:
        themeName = 'light';
        break;
      default:
        themeName = 'system';
    }

    await prefs.setString(_themeKey, themeName);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
