import 'package:flutter/material.dart';
import '../data/grammar_data.dart';
import '../models/grammar_topic.dart';

class GrammarProvider extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  List<GrammarTopic>? _topics;
  GrammarTopic? _currentTopic;
  GrammarSubtopic? _currentSubtopic;
  String? _errorMessage;

  // Yükleme kilidi - aynı anda birden fazla yükleme olmasını engeller
  bool _isLoadLocked = false;

  // Getters
  bool get isLoading => _isLoading;
  List<GrammarTopic> get topics => _topics ?? [];
  GrammarTopic? get currentTopic => _currentTopic;
  GrammarSubtopic? get currentSubtopic => _currentSubtopic;
  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;
  bool get hasTopics => _topics != null && _topics!.isNotEmpty;
  bool get hasTopic => _currentTopic != null;
  bool get hasSubtopic => _currentSubtopic != null;

  // Load all grammar topics
  Future<void> loadGrammarTopics() async {
    // Eğer zaten yükleniyor veya kilit aktifse, çık
    if (_isLoading || _isLoadLocked) return;

    // Eğer topics zaten yüklenmişse, tekrar yükleme
    if (hasTopics && !hasError) return;

    try {
      _setLoadLock(true);
      _setLoading(true);
      _clearError();

      // Hafıza önbelleği temizle
      _topics = null;
      _currentTopic = null;
      _currentSubtopic = null;
      notifyListeners(); // Yükleme başladığını bildir

      // Simulate a short delay for loading animation
      await Future.delayed(const Duration(milliseconds: 300));

      // Verileri yükle
      _topics = GrammarData.topics;

      _setLoading(false);
    } catch (e) {
      _setError('Konular yüklenirken hata oluştu: ${e.toString()}');
    } finally {
      _setLoadLock(false);
    }
  }

  // Load a specific grammar topic by ID
  Future<void> loadGrammarTopic(String topicId) async {
    // Eğer zaten yükleniyor veya kilit aktifse, çık
    if (_isLoading || _isLoadLocked) return;

    // Eğer aynı konu zaten yüklenmişse ve hata yoksa, işlem yapma
    if (hasTopic && currentTopic!.id == topicId && !hasError) {
      return;
    }

    try {
      _setLoadLock(true);
      _setLoading(true);
      _clearError();

      // Önce konuyu temizle
      _currentTopic = null;
      _currentSubtopic = null;
      notifyListeners(); // Yükleme başladığını bildir

      // Eğer konular yüklü değilse, konuları yükle
      if (!hasTopics) {
        _topics = GrammarData.topics;
      }

      // Simulate a short delay for loading animation
      await Future.delayed(const Duration(milliseconds: 300));

      // Konu ID'sine göre konuyu bul
      final topic = _topics!.firstWhere(
        (topic) => topic.id == topicId,
        orElse: () => throw Exception('Konu bulunamadı'),
      );

      _currentTopic = topic;

      _setLoading(false);
    } catch (e) {
      _setError('Konu yüklenirken hata oluştu: ${e.toString()}');
    } finally {
      _setLoadLock(false);
    }
  }

  // Load a specific grammar subtopic by topic ID and subtopic ID
  Future<void> loadGrammarSubtopic(String topicId, String subtopicId) async {
    // Eğer zaten yükleniyor veya kilit aktifse, çık
    if (_isLoading || _isLoadLocked) return;

    // Eğer aynı alt konu zaten yüklenmişse ve hata yoksa, işlem yapma
    if (hasTopic &&
        currentTopic!.id == topicId &&
        hasSubtopic &&
        currentSubtopic!.id == subtopicId &&
        !hasError) {
      return;
    }

    try {
      _setLoadLock(true);
      _setLoading(true);
      _clearError();

      // Önce alt konuyu temizle
      _currentSubtopic = null;
      notifyListeners(); // Yükleme başladığını bildir

      // Eğer konular yüklü değilse veya farklı bir konu ise, konuyu yükle
      if (!hasTopic || currentTopic!.id != topicId) {
        // Konuları yükle
        if (!hasTopics) {
          _topics = GrammarData.topics;
        }

        _currentTopic = _topics!.firstWhere(
          (topic) => topic.id == topicId,
          orElse: () => throw Exception('Konu bulunamadı'),
        );
      }

      // Simulate a short delay for loading animation
      await Future.delayed(const Duration(milliseconds: 300));

      // Alt konuyu bul
      final subtopic = _currentTopic!.subtopics.firstWhere(
        (subtopic) => subtopic.id == subtopicId,
        orElse: () => throw Exception('Alt konu bulunamadı'),
      );

      _currentSubtopic = subtopic;

      _setLoading(false);
    } catch (e) {
      _setError('Alt konu yüklenirken hata oluştu: ${e.toString()}');
    } finally {
      _setLoadLock(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadLock(bool locked) {
    _isLoadLocked = locked;
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
