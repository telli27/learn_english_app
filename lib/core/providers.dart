import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/grammar/controllers/grammar_controller.dart';
import '../features/grammar/repositories/grammar_repository.dart';
import '../features/auth/controllers/theme_controller.dart';
import '../core/models/grammar_topic.dart';

// Dilbilgisi Providerleri (Grammar providers)
// Dilbilgisi repository provider - GrammarRepository nesnesini sağlar
// Veritabanı işlemlerini gerçekleştiren sınıfa erişim sağlar
final grammarRepositoryProvider = Provider<GrammarRepository>((ref) {
  return GrammarRepository();
});

// Dilbilgisi controller provider - Dilbilgisi durumunu ve işlemlerini yönetir
// StateNotifierProvider, durum değişikliklerini bildiren ve yöneten bir provider türüdür
final grammarControllerProvider =
    StateNotifierProvider<GrammarController, GrammarState>((ref) {
  // ref.watch ile repository provider'ını dinler
  final repository = ref.watch(grammarRepositoryProvider);
  return GrammarController(repository);
});

// Dilbilgisi konuları provider - Tüm konuları sağlar
// Uygulama içinde dilbilgisi konularına erişim için kullanılır
final grammarTopicsProvider = Provider<List<GrammarTopic>>((ref) {
  // Controller'ın durumunu izler ve konuları döndürür
  final state = ref.watch(grammarControllerProvider);
  return state.topics;
});

// Mevcut konu provider - Şu anda seçili olan konuyu sağlar
// Detay sayfalarında kullanılır
final currentTopicProvider = Provider<GrammarTopic?>((ref) {
  // Controller'ın durumunu izler ve mevcut konuyu döndürür
  final state = ref.watch(grammarControllerProvider);
  return state.currentTopic;
});

// Mevcut alt konu provider - Şu anda seçili olan alt konuyu sağlar
// Alt konu detaylarında kullanılır
final currentSubtopicProvider = Provider<GrammarSubtopic?>((ref) {
  // Controller'ın durumunu izler ve mevcut alt konuyu döndürür
  final state = ref.watch(grammarControllerProvider);
  return state.currentSubtopic;
});

// Yükleniyor durumu provider - Veri yüklenirken durumu bildirir
// Yükleme göstergelerini (loading indicators) kontrol etmek için kullanılır
final isLoadingProvider = Provider<bool>((ref) {
  // Controller'ın durumunu izler ve yükleniyor durumunu döndürür
  final state = ref.watch(grammarControllerProvider);
  return state.isLoading;
});

// Hata mesajı provider - Hata durumunda mesajı sağlar
// Hata bildirimleri için kullanılır
final errorMessageProvider = Provider<String?>((ref) {
  // Controller'ın durumunu izler ve hata mesajını döndürür
  final state = ref.watch(grammarControllerProvider);
  return state.errorMessage;
});

// Tema Providerleri (Theme providers)
// Tema controller provider - Tema modunu yönetir
// Tema değişikliklerini kontrol eden provider
final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});

// Koyu mod durumu provider - Uygulamanın koyu modda olup olmadığını bildirir
// Arayüz bileşenlerinin tema durumuna göre görünümünü ayarlamak için kullanılır
final isDarkModeProvider = Provider<bool>((ref) {
  // Tema controller'ının durumunu izler
  final themeMode = ref.watch(themeControllerProvider);
  return themeMode == ThemeMode.dark;
});
