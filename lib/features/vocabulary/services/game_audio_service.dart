import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/game_enums.dart';

/// Provider for the game audio service
final gameAudioServiceProvider = Provider<GameAudioService>(
  (ref) => GameAudioService(),
);

/// Game audio service for managing sound effects
class GameAudioService {
  bool _isEnabled = true;

  /// Enable or disable sound effects
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Check if sound is enabled
  bool get isEnabled => _isEnabled;

  /// Play a sound effect
  void playSound(SoundEffect effect) {
    if (!_isEnabled) return;

    // Use haptic feedback as a simple sound replacement
    switch (effect) {
      case SoundEffect.correct:
        HapticFeedback.lightImpact();
        break;
      case SoundEffect.incorrect:
        HapticFeedback.mediumImpact();
        break;
      case SoundEffect.victory:
        HapticFeedback.heavyImpact();
        break;
      case SoundEffect.levelComplete:
        HapticFeedback.heavyImpact();
        break;
      case SoundEffect.buttonTap:
        HapticFeedback.selectionClick();
        break;
      case SoundEffect.tick:
        HapticFeedback.selectionClick();
        break;
      case SoundEffect.wordReveal:
        HapticFeedback.lightImpact();
        break;
      case SoundEffect.transition:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  /// Play victory sound with special effects
  void playVictorySound() {
    if (!_isEnabled) return;

    // Multiple haptic feedback for celebration
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.lightImpact();
    });
  }
}
