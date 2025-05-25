import 'package:flutter/material.dart';
import 'kelime hatırlama/word_recall_game_controller.dart';

/// Theme configuration for different game phases
class GameTheme {
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;

  const GameTheme({
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
  });

  factory GameTheme.fromPhase(RecallGamePhase phase) {
    switch (phase) {
      case RecallGamePhase.study:
        return const GameTheme(
          primaryColor: Color(0xFF00BCD4),
          accentColor: Color(0xFF0097A7),
          backgroundColor: Color(0xFFE0F7FA),
        );
      case RecallGamePhase.recall:
        return const GameTheme(
          primaryColor: Color(0xFF673AB7),
          accentColor: Color(0xFF512DA8),
          backgroundColor: Color(0xFFEDE7F6),
        );
      case RecallGamePhase.review:
        return const GameTheme(
          primaryColor: Color(0xFFFF5722),
          accentColor: Color(0xFFD84315),
          backgroundColor: Color(0xFFFBE9E7),
        );
      case RecallGamePhase.complete:
        return const GameTheme(
          primaryColor: Color(0xFF4CAF50),
          accentColor: Color(0xFF388E3C),
          backgroundColor: Color(0xFFE8F5E8),
        );
    }
  }
}
