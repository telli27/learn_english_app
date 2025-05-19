import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model for an activity in the study progress
class StudyActivity {
  final String id;
  final String title;
  final String description;
  final String type; // 'quiz', 'flashcard', 'review', 'study'
  final DateTime timestamp;
  final int score;

  StudyActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.score = 0,
  });

  // For displaying time ago in UI
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dk önce';
    } else {
      return 'Az önce';
    }
  }
}

// Model for study progress data
class StudyProgress {
  final int daysStudied;
  final double totalHours;
  final int wordsLearned;
  final double studyGoalProgress;
  final double wordGoalProgress;
  final double accuracy;
  final int level;
  final List<StudyActivity> recentActivities;

  StudyProgress({
    required this.daysStudied,
    required this.totalHours,
    required this.wordsLearned,
    required this.studyGoalProgress,
    required this.wordGoalProgress,
    required this.accuracy,
    required this.level,
    required this.recentActivities,
  });
}

// Study progress repository
class StudyProgressRepository {
  // Mock data for demonstration
  Future<StudyProgress> getStudyProgress() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data
    return StudyProgress(
      daysStudied: 15,
      totalHours: 8.5,
      wordsLearned: 127,
      studyGoalProgress: 0.75,
      wordGoalProgress: 0.63,
      accuracy: 0.82,
      level: 4,
      recentActivities: [
        StudyActivity(
          id: '1',
          title: 'Kelime Quizi',
          description: '10/12 doğru cevap (Mükemmel!)',
          type: 'quiz',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          score: 83,
        ),
        StudyActivity(
          id: '2',
          title: 'Fiil Kartları',
          description: '20 kelime çalışıldı',
          type: 'flashcard',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          score: 75,
        ),
        StudyActivity(
          id: '3',
          title: 'Haftalık Tekrar',
          description: '15 kelime tekrar edildi',
          type: 'review',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          score: 90,
        ),
        StudyActivity(
          id: '4',
          title: 'Yeni Kelimeler',
          description: '8 yeni kelime öğrenildi',
          type: 'study',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          score: 60,
        ),
      ],
    );
  }

  Future<void> addActivity(StudyActivity activity) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app, this would save the activity to a database
  }
}

// Provider for the repository
final studyProgressRepositoryProvider =
    Provider<StudyProgressRepository>((ref) {
  return StudyProgressRepository();
});

// Provider for study progress data
final studyProgressProvider = FutureProvider<StudyProgress>((ref) async {
  final repository = ref.watch(studyProgressRepositoryProvider);
  return repository.getStudyProgress();
});

// Provider for streak data (mock implementation)
final streakProvider = Provider<int>((ref) {
  return 15; // Mock streak days
});

// Provider for weekly progress (mock implementation)
final weeklyProgressProvider = Provider<double>((ref) {
  return 0.75; // Mock progress (75%)
});
