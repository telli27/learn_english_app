import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/grammar_version_checker.dart';
import '../data/grammar_data.dart';

// Loading state for language change
final languageLoadingProvider = StateProvider<bool>((ref) => false);
final languageLoadingProgressProvider = StateProvider<double>((ref) => 0.0);

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'selected_locale';
  final Ref ref;

  LocaleNotifier(this.ref) : super(const Locale('tr', '')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString(_localeKey);
      print("🌍 Loading locale from preferences: $localeString");

      if (localeString != null) {
        final parts = localeString.split('_');
        if (parts.isNotEmpty) {
          final locale = Locale(parts[0], parts.length > 1 ? parts[1] : '');
          print("✅ Locale loaded: ${locale.languageCode}");
          state = locale;
        } else {
          print("⚠️ Invalid locale format: $localeString, using default");
          state = const Locale('tr', '');
        }
      } else {
        print("⚠️ No locale found in preferences, using default Turkish");
        state = const Locale('tr', '');
      }
    } catch (e) {
      print("❌ Error loading locale: $e");
      state = const Locale('tr', '');
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      print("🌍 Setting locale to: ${locale.languageCode}");

      // Start loading
      ref.read(languageLoadingProvider.notifier).state = true;
      ref.read(languageLoadingProgressProvider.notifier).state = 0.0;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _localeKey, '${locale.languageCode}_${locale.countryCode}');

      // Update progress
      ref.read(languageLoadingProgressProvider.notifier).state = 0.2;

      // Clear all grammar data when language changes to force reload
      print("🗑️ Clearing all grammar data for language change");
      await GrammarVersionChecker.clearAllData();

      // Update progress
      ref.read(languageLoadingProgressProvider.notifier).state = 0.4;

      // Clear GrammarData topics so they get reloaded with new language
      print("🗑️ Clearing GrammarData.topics");
      GrammarData.topics.clear();

      // Update state first
      state = locale;

      // Update progress
      ref.read(languageLoadingProgressProvider.notifier).state = 0.6;

      // Load new language data immediately
      print("📥 Loading new language data: ${locale.languageCode}");
      await GrammarData.loadTopics(languageCode: locale.languageCode);

      // Update progress to show data loading
      ref.read(languageLoadingProgressProvider.notifier).state = 0.8;

      // Give a moment for data to be processed
      await Future.delayed(const Duration(milliseconds: 300));

      // Complete loading
      ref.read(languageLoadingProgressProvider.notifier).state = 1.0;

      // Small delay to show completion
      await Future.delayed(const Duration(milliseconds: 200));

      print("✅ Language changed to: ${locale.languageCode}");
    } catch (e) {
      print("❌ Error setting locale: $e");
      rethrow;
    } finally {
      // Always stop loading
      ref.read(languageLoadingProvider.notifier).state = false;
      ref.read(languageLoadingProgressProvider.notifier).state = 0.0;
    }
  }
}
