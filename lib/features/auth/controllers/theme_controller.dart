import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tema kontrolcüsü - StateNotifier sınıfı
// Riverpod'da StateNotifier, uygulama durumunu (state) kontrol eden sınıftır
// ThemeMode tipinde bir durum tutar ve bunu değiştirme metodları sağlar
class ThemeController extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  // Constructor ile varsayılan durum ayarlanır ve SharedPreferences'dan kayıtlı tema yüklenir
  ThemeController() : super(ThemeMode.light) {
    _loadThemeFromPrefs();
  }

  // Koyu mod durumunu döndüren getter
  bool get isDarkMode => state == ThemeMode.dark;

  // SharedPreferences'dan kayıtlı temayı yükler
  // Riverpod state'ini güncelleyen yardımcı metod
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

  // Tema modunu ayarlar ve SharedPreferences'a kaydeder
  // Riverpod state'ini günceller ve değişiklikleri kalıcı olarak saklar
  void setThemeMode(ThemeMode mode) async {
    // State doğrudan güncellenir, Riverpod bağlı widget'ların yeniden oluşturulmasını sağlar
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

  // Temayı açık/koyu arasında değiştirir
  // Kullanıcı arayüzünden tema değişikliği için kullanılan metod
  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
