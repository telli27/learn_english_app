import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Durum sınıfı - değiştirilemez (immutable)
// Tema durumunu saklamak için kullanılır
class ThemeState {
  final bool isDarkMode;

  const ThemeState({this.isDarkMode = false});

  // Yeni durum oluşturmak için copyWith metodu
  // Riverpod'da state değişmezliğini korumak için kullanılır
  ThemeState copyWith({bool? isDarkMode}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// StateNotifier sınıfı - Tema durumunu yönetir
// Riverpod'da durum (state) değişikliklerini yönetmek için kullanılır
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

  // Temayı açık/koyu olarak değiştirir
  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  // Tema modunu direkt olarak ayarlar
  void setDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
  }
}

// Ana provider - Tema durumunu ve yöneticisini sağlar
// StateNotifierProvider, hem durumu hem de durumu güncelleyecek metodları sağlar
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// Tema verileri provider'ı - ThemeData nesnesini sağlar
// Bu provider, tema durumuna göre uygun ThemeData nesnesini döndürür
final themeDataProvider = Provider<ThemeData>((ref) {
  // ref.watch ile themeProvider'ın durumunu takip eder
  final isDarkMode = ref.watch(themeProvider).isDarkMode;

  return isDarkMode
      ? ThemeData.dark().copyWith(
          primaryColor: Colors.teal,
          colorScheme: ColorScheme.dark(
            primary: Colors.teal,
            secondary: Colors.tealAccent,
          ),
        )
      : ThemeData.light().copyWith(
          primaryColor: Colors.blue,
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.blueAccent,
          ),
        );
});
