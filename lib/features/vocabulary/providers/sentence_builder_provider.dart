import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';

// Model to track a built sentence
class BuiltSentence {
  final String flashcardId;
  final String word;
  final String sentence;
  final int score;
  final DateTime timestamp;

  BuiltSentence({
    required this.flashcardId,
    required this.word,
    required this.sentence,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'flashcardId': flashcardId,
      'word': word,
      'sentence': sentence,
      'score': score,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory BuiltSentence.fromMap(Map<String, dynamic> map) {
    return BuiltSentence(
      flashcardId: map['flashcardId'],
      word: map['word'],
      sentence: map['sentence'],
      score: map['score'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}

// Model for sentence building stats
class SentenceBuildingStats {
  final int totalSentences;
  final int perfectSentences;
  final double averageScore;
  final Map<String, int> wordsUsed;
  final List<BuiltSentence> recentSentences;

  SentenceBuildingStats({
    required this.totalSentences,
    required this.perfectSentences,
    required this.averageScore,
    required this.wordsUsed,
    required this.recentSentences,
  });
}

// Repository for sentence building data
class SentenceBuilderRepository {
  final List<BuiltSentence> _sentences = [];

  // Return a comprehensive stats object
  Future<SentenceBuildingStats> getSentenceBuildingStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Calculate stats
    final totalSentences = _sentences.length;

    final perfectSentences = _sentences.where((s) => s.score >= 9).length;

    final averageScore = totalSentences > 0
        ? _sentences.map((s) => s.score).reduce((a, b) => a + b) /
            totalSentences
        : 0.0;

    // Count occurrences of each word
    final wordsUsed = <String, int>{};
    for (final sentence in _sentences) {
      wordsUsed[sentence.word] = (wordsUsed[sentence.word] ?? 0) + 1;
    }

    // Get most recent sentences (up to 10)
    final recentSentences = List<BuiltSentence>.from(_sentences)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return SentenceBuildingStats(
      totalSentences: totalSentences,
      perfectSentences: perfectSentences,
      averageScore: averageScore,
      wordsUsed: wordsUsed,
      recentSentences: recentSentences.take(10).toList(),
    );
  }

  // Add a new sentence to the history
  Future<void> addSentence(BuiltSentence sentence) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    _sentences.add(sentence);

    // In a real app, this would save to a database or cloud storage
  }

  // Get sample sentences for a word to help users learn
  Future<List<String>> getSampleSentences(String word) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    // This would typically come from an API or database
    // Here we're providing hardcoded examples
    switch (word.toLowerCase()) {
      case 'serendipity':
        return [
          'Finding that rare book was pure serendipity.',
          'Their meeting was a moment of serendipity that changed both their lives.',
          'Sometimes serendipity leads to the greatest discoveries in science.'
        ];
      case 'ubiquitous':
        return [
          'Smartphones have become ubiquitous in modern society.',
          'The company\'s logo is ubiquitous throughout the city.',
          'WiFi is now ubiquitous in most public spaces.'
        ];
      case 'eloquent':
        return [
          'She gave an eloquent speech that moved the entire audience.',
          'His writing is remarkably eloquent and persuasive.',
          'The professor was known for his eloquent explanations of complex topics.'
        ];
      default:
        return [
          'I use the word $word frequently in my writing.',
          'She couldn\'t remember what $word meant.',
          'Learning to use $word correctly took some practice.'
        ];
    }
  }
}

// Provider for the repository
final sentenceBuilderRepositoryProvider =
    Provider<SentenceBuilderRepository>((ref) {
  return SentenceBuilderRepository();
});

// Provider for sentence building stats
final sentenceBuildingStatsProvider =
    FutureProvider<SentenceBuildingStats>((ref) async {
  final repository = ref.watch(sentenceBuilderRepositoryProvider);
  return repository.getSentenceBuildingStats();
});

// Provider for sample sentences for a specific word
final sampleSentencesProvider =
    FutureProvider.family<List<String>, String>((ref, word) async {
  final repository = ref.watch(sentenceBuilderRepositoryProvider);
  return repository.getSampleSentences(word);
});

// Provider for adding a new sentence (returns the updated stats)
final addSentenceProvider =
    Provider<Future<void> Function(BuiltSentence)>((ref) {
  final repository = ref.watch(sentenceBuilderRepositoryProvider);
  return (sentence) async {
    await repository.addSentence(sentence);
    // Invalidate the stats provider to trigger a refresh
    ref.refresh(sentenceBuildingStatsProvider);
  };
});
