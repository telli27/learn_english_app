import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../kelime oyunları/game_enums.dart';
import '../kelime oyunları/game_models.dart';

/// Provider for the achievement service
final achievementServiceProvider = Provider<AchievementService>(
  (ref) => AchievementService(),
);

/// Achievement service for managing player achievements
class AchievementService {
  final List<Achievement> _unlockedAchievements = [];

  /// Get all unlocked achievements
  List<Achievement> get unlockedAchievements =>
      List.unmodifiable(_unlockedAchievements);

  /// Check if an achievement is unlocked
  bool isAchievementUnlocked(String achievementId) {
    return _unlockedAchievements
        .any((achievement) => achievement.id == achievementId);
  }

  /// Unlock an achievement
  void unlockAchievement(Achievement achievement) {
    if (!isAchievementUnlocked(achievement.id)) {
      _unlockedAchievements.add(achievement);
      _notifyAchievementUnlocked(achievement);
    }
  }

  /// Get achievements for a specific type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _unlockedAchievements
        .where((achievement) => achievement.type == type)
        .toList();
  }

  /// Get total achievement count
  int get totalAchievements => _unlockedAchievements.length;

  /// Get achievement points (each achievement is worth 100 points)
  int get achievementPoints => _unlockedAchievements.length * 100;

  /// Mark achievement as notified
  void markAsNotified(String achievementId) {
    final index = _unlockedAchievements
        .indexWhere((achievement) => achievement.id == achievementId);
    if (index != -1) {
      _unlockedAchievements[index] =
          _unlockedAchievements[index].copyWith(isNotified: true);
    }
  }

  /// Get unnotified achievements
  List<Achievement> get unnotifiedAchievements {
    return _unlockedAchievements
        .where((achievement) => !achievement.isNotified)
        .toList();
  }

  /// Private method to handle achievement notification
  void _notifyAchievementUnlocked(Achievement achievement) {
    // In a real app, this would show a notification or dialog
    print('🏆 Achievement Unlocked: ${achievement.title}');
    print('📝 ${achievement.description}');
  }

  /// Reset all achievements (for testing purposes)
  void resetAchievements() {
    _unlockedAchievements.clear();
  }

  /// Create a sample achievement for testing
  Achievement createSampleAchievement(AchievementType type) {
    return Achievement(
      id: 'sample_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      unlockedAt: DateTime.now(),
      title: type.title,
      description: type.description,
    );
  }
}
