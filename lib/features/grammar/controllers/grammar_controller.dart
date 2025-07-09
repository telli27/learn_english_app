import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../../../core/models/grammar_topic.dart';
import '../repositories/grammar_repository.dart';
import '../../../core/data/grammar_data.dart';

// Dilbilgisi için durum sınıfı (State class)
// Riverpod durum yönetimi için değiştirilemez (immutable) bir sınıf kullanır
class GrammarState {
  final bool isLoading;
  final List<GrammarTopic> topics;
  final GrammarTopic? currentTopic;
  final GrammarSubtopic? currentSubtopic;
  final String? errorMessage;

  const GrammarState({
    this.isLoading = false,
    this.topics = const [],
    this.currentTopic,
    this.currentSubtopic,
    this.errorMessage,
  });

  // Yeni bir durum nesnesi oluşturmak için copyWith metodu
  // Riverpod'da state değişmezliğini korumak için kullanılır
  GrammarState copyWith({
    bool? isLoading,
    List<GrammarTopic>? topics,
    GrammarTopic? currentTopic,
    GrammarSubtopic? currentSubtopic,
    String? errorMessage,
  }) {
    return GrammarState(
      isLoading: isLoading ?? this.isLoading,
      topics: topics ?? this.topics,
      currentTopic: currentTopic ?? this.currentTopic,
      currentSubtopic: currentSubtopic ?? this.currentSubtopic,
      errorMessage: errorMessage,
    );
  }
}

// Dilbilgisi kontrolcüsü - StateNotifier sınıfı
// Riverpod'da StateNotifier, uygulamanın durumunu (state) değiştiren asıl sınıftır
class GrammarController extends StateNotifier<GrammarState> {
  final GrammarRepository _repository;
  bool _isLoadLocked = false;

  // Repository bağımlılığını alır ve varsayılan durumu başlatır
  GrammarController(this._repository) : super(const GrammarState());

  // Tüm dilbilgisi konularını yükler
  // Riverpod state'ini güncelleyerek UI'nın yeniden oluşturulmasını tetikler
  Future<void> loadGrammarTopics(
      {String languageCode = 'tr', bool forceReload = false}) async {
    print(
        "📚 GrammarController.loadGrammarTopics called with language: $languageCode, forceReload: $forceReload");

    // If already loading or lock is active, return
    if (state.isLoading || _isLoadLocked) {
      print("⏳ Already loading or locked, returning");
      return;
    }

    // If topics are already loaded and no error, return (unless force reload)
    if (!forceReload && state.topics.isNotEmpty && state.errorMessage == null) {
      print("✅ Topics already loaded and no error, returning");
      return;
    }

    try {
      _isLoadLocked = true;
      print("🔄 Starting to load grammar topics for language: $languageCode");

      // Durum güncellenir - Riverpod bağlı widget'ları bilgilendirir
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        topics: [],
        currentTopic: null,
        currentSubtopic: null,
      );

      // Simulate a short delay for loading animation
      await Future.delayed(const Duration(milliseconds: 100));

      // Load data from GrammarData with language support
      print("📥 Loading topics from GrammarData...");
      await GrammarData.loadTopics(languageCode: languageCode);
      final topics = GrammarData.topics;

      print("📊 Loaded ${topics.length} topics from GrammarData");

      // Başarılı yükleme durumunda state güncellenir
      state = state.copyWith(
        topics: topics,
        isLoading: false,
      );

      print("✅ Grammar topics loaded successfully: ${topics.length} topics");
    } catch (e) {
      print("❌ Error loading grammar topics: $e");
      // Hata durumunda state güncellenir
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Konular yüklenirken hata oluştu: ${e.toString()}',
      );
    } finally {
      _isLoadLocked = false;
    }
  }

  // Directly update topics without loading - used when topics are already loaded elsewhere
  void updateTopicsDirectly(List<GrammarTopic> newTopics) {
    print(
        "🔄 GrammarController.updateTopicsDirectly called with ${newTopics.length} topics");
    state = state.copyWith(
      topics: newTopics,
      isLoading: false,
      errorMessage: null,
    );
    print("✅ GrammarController state updated with new topics");
  }

  // ID'ye göre belirli bir dilbilgisi konusunu yükler
  // Riverpod state'ini güncelleyerek UI'nın yeniden oluşturulmasını tetikler
  Future<void> loadGrammarTopic(String topicId) async {
    // If already loading or lock is active, return
    if (state.isLoading || _isLoadLocked) return;

    // If the same topic is already loaded and no error, return
    if (state.currentTopic != null &&
        state.currentTopic!.id == topicId &&
        state.errorMessage == null) {
      return;
    }

    try {
      _isLoadLocked = true;
      // Durum güncellenir - Riverpod yükleme durumunu bildirir
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentTopic: null,
        currentSubtopic: null,
      );

      // If topics are not loaded, load them
      if (state.topics.isEmpty) {
        final topics = _repository.getGrammarTopics();
        state = state.copyWith(topics: topics);
      }

      // Simulate a short delay for loading animation
      await Future.delayed(const Duration(milliseconds: 100));

      // Find the topic by ID
      final topic = _repository.getGrammarTopic(topicId);
      if (topic == null) {
        throw Exception('Konu bulunamadı');
      }

      // Başarılı yükleme durumunda state güncellenir
      state = state.copyWith(
        currentTopic: topic,
        isLoading: false,
      );
    } catch (e) {
      // Hata durumunda state güncellenir
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Konu yüklenirken hata oluştu: ${e.toString()}',
      );
    } finally {
      _isLoadLocked = false;
    }
  }

  // Konu ID'si ve alt konu ID'sine göre belirli bir dilbilgisi alt konusunu yükler
  // Riverpod state'ini güncelleyerek UI'nın yeniden oluşturulmasını tetikler
  Future<void> loadGrammarSubtopic(String topicId, String subtopicId) async {
    // If already loading or lock is active, return
    if (state.isLoading || _isLoadLocked) return;

    // If the same subtopic is already loaded and no error, return
    if (state.currentTopic != null &&
        state.currentTopic!.id == topicId &&
        state.currentSubtopic != null &&
        state.currentSubtopic!.id == subtopicId &&
        state.errorMessage == null) {
      return;
    }

    try {
      _isLoadLocked = true;
      // Durum güncellenir - Riverpod yükleme durumunu bildirir
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentSubtopic: null,
      );

      // If topics are not loaded or different topic, load the topic
      if (state.currentTopic == null || state.currentTopic!.id != topicId) {
        // If topics are not loaded, load them
        if (state.topics.isEmpty) {
          final topics = _repository.getGrammarTopics();
          state = state.copyWith(topics: topics);
        }

        // Find the topic by ID
        final topic = _repository.getGrammarTopic(topicId);
        if (topic == null) {
          throw Exception('Konu bulunamadı');
        }

        state = state.copyWith(currentTopic: topic);
      }

      // Simulate a short delay for loading animation
      await Future.delayed(const Duration(milliseconds: 100));

      // Find the subtopic
      final subtopic = _repository.getGrammarSubtopic(topicId, subtopicId);
      if (subtopic == null) {
        throw Exception('Alt konu bulunamadı');
      }

      // Başarılı yükleme durumunda state güncellenir
      state = state.copyWith(
        currentSubtopic: subtopic,
        isLoading: false,
      );
    } catch (e) {
      // Hata durumunda state güncellenir
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Alt konu yüklenirken hata oluştu: ${e.toString()}',
      );
    } finally {
      _isLoadLocked = false;
    }
  }
}
