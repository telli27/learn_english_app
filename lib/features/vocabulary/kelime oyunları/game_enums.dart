/// Core enums for the vocabulary game system
library;

/// Difficulty levels for vocabulary games
enum DifficultyLevel {
  beginner('Başlangıç', 1),
  intermediate('Orta', 2),
  advanced('İleri', 3),
  expert('Uzman', 4);

  const DifficultyLevel(this.displayName, this.level);

  final String displayName;
  final int level;

  /// Get color associated with difficulty
  static const difficultyColors = {
    DifficultyLevel.beginner: 0xFF4CAF50, // Green
    DifficultyLevel.intermediate: 0xFF2196F3, // Blue
    DifficultyLevel.advanced: 0xFFFF9800, // Orange
    DifficultyLevel.expert: 0xFFF44336, // Red
  };

  int get colorValue => difficultyColors[this] ?? 0xFF4CAF50;
}

/// Game phases for word recall game
enum RecallGamePhase {
  preparation('Hazırlık', 'Oyun başlamak üzere'),
  study('İnceleme', 'Kelimeleri inceleyin'),
  transition('Geçiş', 'Hatırlama aşamasına geçiliyor'),
  recall('Hatırlama', 'Kelimeleri hatırlamaya çalışın'),
  review('Değerlendirme', 'Sonuçlarınızı görün'),
  complete('Tamamlandı', 'Alıştırma tamamlandı');

  const RecallGamePhase(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Game result types
enum GameResult {
  excellent('Mükemmel', 90),
  good('İyi', 75),
  average('Orta', 60),
  needsImprovement('Geliştirilmeli', 0);

  const GameResult(this.displayName, this.minScore);

  final String displayName;
  final int minScore;

  static GameResult fromScore(double scorePercentage) {
    if (scorePercentage >= 90) return GameResult.excellent;
    if (scorePercentage >= 75) return GameResult.good;
    if (scorePercentage >= 60) return GameResult.average;
    return GameResult.needsImprovement;
  }
}

/// Achievement types
enum AchievementType {
  perfectScore('Mükemmel Skor', 'Tüm kelimeleri doğru hatırladın'),
  speedMaster('Hız Ustası', 'Zamanın yarısında tamamladın'),
  streak('Seri', 'Ardışık doğru cevaplar'),
  levelComplete('Seviye Tamamı', 'Seviyeyi tamamladın'),
  dedication('Azim', 'Günlük hedefine ulaştın');

  const AchievementType(this.title, this.description);

  final String title;
  final String description;
}

/// Sound effect types
enum SoundEffect {
  correct,
  incorrect,
  tick,
  victory,
  levelComplete,
  buttonTap,
  wordReveal,
  transition
}

/// Animation types for UI feedback
enum AnimationType {
  cardFlip,
  bounce,
  pulse,
  shake,
  fade,
  slide,
  confetti,
  celebration
}
