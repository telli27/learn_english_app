import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'sentence_building_models.dart';
import 'sentence_building_controller.dart';

/// Professional sentence building game screen
class SentenceBuildingGameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const SentenceBuildingGameScreen({
    super.key,
    required this.levelId,
  });

  @override
  ConsumerState<SentenceBuildingGameScreen> createState() =>
      _SentenceBuildingGameScreenState();
}

class _SentenceBuildingGameScreenState
    extends ConsumerState<SentenceBuildingGameScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState =
        ref.watch(sentenceBuildingControllerProvider(widget.levelId));
    final controller =
        ref.read(sentenceBuildingControllerProvider(widget.levelId).notifier);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Theme colors - consistent with other games
    final primaryColor =
        const Color(0xFF8B5CF6); // Purple theme for sentence building
    final backgroundColor =
        isDarkMode ? const Color(0xFF1F2247) : theme.scaffoldBackgroundColor;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBackPress(controller);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body:
            _buildGameContent(gameState, controller, isDarkMode, primaryColor),
      ),
    );
  }

  Widget _buildGameContent(
    SentenceBuildingGameState gameState,
    SentenceBuildingController controller,
    bool isDarkMode,
    Color primaryColor,
  ) {
    switch (gameState.phase) {
      case SentenceBuildingPhase.loading:
        return _buildLoadingView(isDarkMode);
      case SentenceBuildingPhase.building:
        return _buildGameView(gameState, controller, isDarkMode, primaryColor);
      case SentenceBuildingPhase.feedback:
        return _buildGameView(gameState, controller, isDarkMode, primaryColor);
      case SentenceBuildingPhase.complete:
        return _buildGameView(gameState, controller, isDarkMode, primaryColor);
      case SentenceBuildingPhase.error:
        return _buildErrorView(gameState, isDarkMode, primaryColor);
      default:
        return _buildGameView(gameState, controller, isDarkMode, primaryColor);
    }
  }

  Widget _buildLoadingView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: const Color(0xFF8B5CF6),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Hazırlanıyor...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(
    SentenceBuildingGameState gameState,
    SentenceBuildingController controller,
    bool isDarkMode,
    Color primaryColor,
  ) {
    return Column(
      children: [
        _buildHeader(gameState, controller, primaryColor),
        _buildProgressInfo(gameState, primaryColor, isDarkMode),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 100), // Bottom padding for buttons
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExerciseCounter(gameState, primaryColor),
                const SizedBox(height: 16),
                _buildQuestionCard(gameState, isDarkMode, primaryColor),
                const SizedBox(height: 20),
                _buildSentenceBuilder(
                    gameState, controller, isDarkMode, primaryColor),
                const SizedBox(height: 20),
                _buildWordOptions(
                    gameState, controller, isDarkMode, primaryColor),
                const SizedBox(height: 20),
                if (gameState.phase == SentenceBuildingPhase.feedback)
                  _buildFeedbackSection(
                      gameState, controller, isDarkMode, primaryColor),
              ],
            ),
          ),
        ),
        // Fixed bottom action buttons
        if (gameState.phase != SentenceBuildingPhase.feedback)
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2247) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _buildActionButtons(
                  gameState, controller, isDarkMode, primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(
    SentenceBuildingGameState gameState,
    SentenceBuildingController controller,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.9),
            const Color(0xFF7C3AED),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with back button, title, and pause button
          Row(
            children: [
              IconButton(
                onPressed: () => _handleBackPress(controller),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Cümle Kurma',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: Icon(
                  gameState.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  if (gameState.isPaused) {
                    controller.resumeGame();
                  } else {
                    controller.pauseGame();
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Game info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Seviye ${gameState.currentLevel.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Exercise indicator - clickable
              GestureDetector(
                onTap: () {
                  _showExerciseSelectionDialog(gameState, controller);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.format_list_numbered,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Alıştırma ${gameState.currentExerciseIndex + 1}/${gameState.currentLevel.exercises.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Score indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${gameState.totalScore} puan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(
    SentenceBuildingGameState gameState,
    Color primaryColor,
    bool isDarkMode,
  ) {
    final progressPercentage = (gameState.currentExerciseIndex + 1) /
        gameState.currentLevel.exercises.length;
    final remainingExercises = gameState.currentLevel.exercises.length -
        (gameState.currentExerciseIndex + 1);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2E5A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar - more compact
          Row(
            children: [
              Text(
                'İlerleme',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(progressPercentage * 100).toInt()}%',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Stats row - very compact, single line
          Row(
            children: [
              _buildCompactStat(
                icon: Icons.emoji_events,
                value: '${gameState.totalScore}',
                color: const Color(0xFFFFD700),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(width: 12),
              _buildCompactStat(
                icon: Icons.lightbulb,
                value: '${math.max(0, 3 - gameState.hintsUsed)}',
                color: const Color(0xFF10B981),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(width: 12),
              _buildCompactStat(
                icon: Icons.timer,
                value: _formatTime(gameState.timeLeft),
                color: _getTimerColor(
                    gameState.timeLeft, gameState.currentExercise.timeLimit),
                isDarkMode: isDarkMode,
                isUrgent: gameState.timeLeft <=
                    (gameState.currentExercise.timeLimit * 0.15).round(),
              ),
              const Spacer(),
              Text(
                remainingExercises > 0 ? '$remainingExercises kaldı' : 'Son!',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required Color color,
    required bool isDarkMode,
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isUrgent ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(isUrgent ? 0.4 : 0.3),
          width: isUrgent ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get timer color based on remaining time percentage
  Color _getTimerColor(int timeLeft, int totalTime) {
    final percentage = timeLeft / totalTime;
    if (percentage <= 0.15) {
      return const Color(0xFFEF4444); // Red - very urgent
    } else if (percentage <= 0.25) {
      return const Color(0xFFF59E0B); // Orange - urgent
    } else if (percentage <= 0.5) {
      return const Color(0xFFF59E0B); // Orange - warning
    } else {
      return const Color(0xFF3B82F6); // Blue - normal
    }
  }

  Widget _buildExerciseCounter(
      SentenceBuildingGameState gameState, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Alıştırma ${gameState.currentExerciseIndex + 1}/${gameState.currentLevel.exercises.length}',
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    SentenceBuildingGameState gameState,
    bool isDarkMode,
    Color primaryColor,
  ) {
    final cardColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Türkçe Çeviri:',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            gameState.currentExercise.turkishTranslation,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceBuilder(
    SentenceBuildingGameState gameState,
    SentenceBuildingController controller,
    bool isDarkMode,
    Color primaryColor,
  ) {
    final cardColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gameState.selectedWords.isEmpty
              ? Colors.grey.withOpacity(0.2)
              : primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: primaryColor, size: 16),
              const SizedBox(width: 6),
              Text(
                'Cümlenizi Kurun:',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          gameState.selectedWords.isEmpty
              ? _buildCompactEmptyState(isDarkMode)
              : _buildCompactSelectedWords(
                  gameState, controller, textColor, primaryColor),
        ],
      ),
    );
  }

  Widget _buildCompactEmptyState(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_outlined,
            color: isDarkMode ? Colors.white54 : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Kelimelere dokunarak cümle kurun',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSelectedWords(
    SentenceBuildingGameState gameState,
    SentenceBuildingController controller,
    Color textColor,
    Color primaryColor,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: gameState.selectedWords.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value;
        return _buildCompactSelectedWordChip(
            word, index, controller, primaryColor);
      }).toList(),
    );
  }

  Widget _buildCompactSelectedWordChip(
    String word,
    int index,
    SentenceBuildingController controller,
    Color primaryColor,
  ) {
    final gameState =
        ref.watch(sentenceBuildingControllerProvider(widget.levelId));
    final canRemove = gameState.phase == SentenceBuildingPhase.building &&
        !gameState.isPaused;

    return Material(
      color: primaryColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: canRemove
            ? () {
                HapticFeedback.lightImpact();
                controller.removeWordFromSentence(word);
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                word,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.close,
                color: Colors.white,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordOptions(
    SentenceBuildingGameState gameState,
    SentenceBuildingController controller,
    bool isDarkMode,
    Color primaryColor,
  ) {
    final cardColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.apps, color: primaryColor, size: 16),
              const SizedBox(width: 6),
              Text(
                'Kelimeler',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: gameState.availableWords.map((word) {
              return _buildCompactWordOption(
                  word, controller, isDarkMode, primaryColor);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactWordOption(
    String word,
    SentenceBuildingController controller,
    bool isDarkMode,
    Color primaryColor,
  ) {
    final gameState =
        ref.watch(sentenceBuildingControllerProvider(widget.levelId));
    final isUsed = !gameState.availableWords.contains(word);
    final canSelect = !isUsed &&
        gameState.phase == SentenceBuildingPhase.building &&
        !gameState.isPaused;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canSelect
            ? () {
                HapticFeedback.selectionClick();
                controller.addWordToSentence(word);
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isUsed
                ? (isDarkMode ? Colors.grey[800] : Colors.grey[200])
                : (isDarkMode ? const Color(0xFF3A3F6B) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isUsed ? Colors.transparent : primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUsed) ...[
                Icon(
                  Icons.add,
                  color: primaryColor,
                  size: 12,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                word,
                style: TextStyle(
                  color: isUsed
                      ? (isDarkMode ? Colors.grey[600] : Colors.grey[500])
                      : (isDarkMode ? Colors.white : Colors.black87),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isUsed) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                  size: 12,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    SentenceBuildingGameState gameState,
    SentenceBuildingController controller,
    bool isDarkMode,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Clear button - should work when there are selected words
          _buildCompactButton(
            icon: Icons.refresh,
            onPressed: gameState.selectedWords.isNotEmpty
                ? () {
                    HapticFeedback.lightImpact();
                    controller.clearSentence();
                  }
                : null,
            isDarkMode: isDarkMode,
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 8),
          // Restart button - should always work except during loading
          _buildCompactButton(
            icon: Icons.restart_alt,
            onPressed: gameState.phase != SentenceBuildingPhase.loading
                ? () {
                    HapticFeedback.lightImpact();
                    _showRestartDialog(controller);
                  }
                : null,
            isDarkMode: isDarkMode,
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 8),
          // Hint button - should work when hints are available
          _buildCompactHintButton(
            gameState: gameState,
            controller: controller,
            isDarkMode: isDarkMode,
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 12),
          // Main submit button - takes remaining space
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: gameState.selectedWords.isNotEmpty &&
                        gameState.phase == SentenceBuildingPhase.building
                    ? () {
                        HapticFeedback.mediumImpact();
                        controller.submitSentence();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gameState.selectedWords.isNotEmpty &&
                          gameState.phase == SentenceBuildingPhase.building
                      ? primaryColor
                      : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                  foregroundColor: gameState.selectedWords.isNotEmpty &&
                          gameState.phase == SentenceBuildingPhase.building
                      ? Colors.white
                      : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                  elevation: gameState.selectedWords.isNotEmpty &&
                          gameState.phase == SentenceBuildingPhase.building
                      ? 2
                      : 0,
                  shadowColor: primaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  gameState.selectedWords.isNotEmpty &&
                          gameState.phase == SentenceBuildingPhase.building
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                ),
                label: Text(
                  gameState.selectedWords.isNotEmpty &&
                          gameState.phase == SentenceBuildingPhase.building
                      ? 'Kontrol Et'
                      : 'Kelime Seçin',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: onPressed != null ? primaryColor : Colors.grey,
          side: BorderSide(
              color: onPressed != null
                  ? primaryColor.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: onPressed != null
              ? (isDarkMode
                  ? primaryColor.withOpacity(0.1)
                  : primaryColor.withOpacity(0.05))
              : (isDarkMode
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05)),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildCompactHintButton({
    required SentenceBuildingGameState gameState,
    required SentenceBuildingController controller,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    final canUseHint = gameState.canUseHint &&
        gameState.phase == SentenceBuildingPhase.building &&
        !gameState.isPaused;
    final hintsRemaining = math.max(0, 3 - gameState.hintsUsed);
    final canShowRewardedAd = !canUseHint &&
        gameState.phase == SentenceBuildingPhase.building &&
        !gameState.isPaused &&
        controller.canShowRewardedAdForHints(); // Check if ad is ready
    final isAdLoading = !canUseHint &&
        gameState.phase == SentenceBuildingPhase.building &&
        !gameState.isPaused &&
        !controller.isRewardedAdReady;

    Widget button = SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          OutlinedButton(
            onPressed: canUseHint
                ? () {
                    HapticFeedback.lightImpact();
                    _showHintDialog(controller, gameState);
                  }
                : canShowRewardedAd
                    ? () {
                        HapticFeedback.lightImpact();
                        _showRewardedAdDialog(controller, gameState);
                      }
                    : isAdLoading
                        ? () {
                            // Show info about ad loading and try to reload
                            HapticFeedback.lightImpact();

                            // Try to reload ad manually
                            controller.tryReloadRewardedAd();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.refresh, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Reklam yeniden yükleniyor...'),
                                  ],
                                ),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: (canUseHint || canShowRewardedAd || isAdLoading)
                  ? primaryColor
                  : Colors.grey,
              side: BorderSide(
                  color: (canUseHint || canShowRewardedAd || isAdLoading)
                      ? primaryColor.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3),
                  width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: (canUseHint || canShowRewardedAd || isAdLoading)
                  ? (isDarkMode
                      ? primaryColor.withOpacity(0.1)
                      : primaryColor.withOpacity(0.05))
                  : (isDarkMode
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05)),
              padding: EdgeInsets.zero,
            ),
            child: Icon(
              canUseHint
                  ? Icons.lightbulb
                  : canShowRewardedAd
                      ? Icons.play_circle_filled
                      : isAdLoading
                          ? Icons.refresh
                          : Icons.lightbulb_outline,
              size: 20,
              color: (canUseHint || canShowRewardedAd || isAdLoading)
                  ? primaryColor
                  : Colors.grey,
            ),
          ),
          if (canUseHint && hintsRemaining > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$hintsRemaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (canShowRewardedAd)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green, // Yeşil = hazır
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.video_library,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),
          if (isAdLoading)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.orange, // Turuncu = yükleniyor
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 8,
                    height: 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Add tooltip for better user experience
    if (isAdLoading) {
      return Tooltip(
        message: 'Reklam yükleniyor...',
        child: button,
      );
    } else if (!canUseHint &&
        !canShowRewardedAd &&
        gameState.phase == SentenceBuildingPhase.building) {
      return Tooltip(
        message: 'Reklam şu anda mevcut değil',
        child: button,
      );
    }

    return button;
  }

  /// Show professional hint dialog
  void _showHintDialog(SentenceBuildingController controller,
      SentenceBuildingGameState gameState) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF8B5CF6);
    final dialogBgColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Get hint information - DON'T show the actual word until hint is used
    final correctWords = gameState.currentExercise.words;
    final currentLength = gameState.selectedWords.length;
    final hasNextWord = currentLength < correctWords.length;
    final hintsRemaining = math.max(0, 3 - gameState.hintsUsed);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: dialogBgColor,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lightbulb,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İpucu',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$hintsRemaining ipucu hakkınız kaldı',
                          style: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hint content - Don't reveal the word
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'İpucu Bilgisi:',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (hasNextWord) ...[
                      Text(
                        'Sıradaki kelime otomatik olarak cümlenize eklenecek.',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bu ipucu ${currentLength + 1}. pozisyondaki doğru kelimeyi gösterecek.',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Cümleniz tamamlanmış görünüyor!',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDarkMode ? Colors.white70 : Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'İptal',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: hasNextWord
                          ? () {
                              Navigator.pop(context);
                              controller.useHint();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'İpucu Kullan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(
    SentenceBuildingGameState gameState,
    SentenceBuildingController controller,
    bool isDarkMode,
    Color primaryColor,
  ) {
    final lastAttempt =
        gameState.attempts.isNotEmpty ? gameState.attempts.last : null;
    if (lastAttempt == null) return const SizedBox.shrink();

    final isCorrect = lastAttempt.isCorrect;
    final isPartiallyCorrect = lastAttempt.isPartiallyCorrect && !isCorrect;
    final isTimeout =
        lastAttempt.userSentence.isEmpty && gameState.timeLeft == 0;

    final color = isCorrect
        ? const Color(0xFF10B981)
        : (isPartiallyCorrect
            ? const Color(0xFFF59E0B)
            : (isTimeout
                ? const Color(0xFF6B7280) // Gray for timeout
                : const Color(0xFFEF4444)));

    final icon = isCorrect
        ? Icons.check_circle
        : (isPartiallyCorrect
            ? Icons.warning_amber
            : (isTimeout ? Icons.access_time : Icons.cancel));

    final title = isCorrect
        ? 'Doğru!'
        : (isPartiallyCorrect
            ? 'Kısmen Doğru!'
            : (isTimeout ? 'Süre Bitti!' : 'Yanlış!'));

    final cardColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with icon and title
          Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Special timeout message or sentence comparison
          if (isTimeout) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Süre doldu!',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bir sonraki sefer daha hızlı olmaya çalışın.',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSentenceComparison(
              'Doğru Cümle:',
              lastAttempt.correctSentence.join(' '),
              const Color(0xFF10B981),
              isDarkMode,
            ),
          ] else if (!isCorrect) ...[
            _buildSentenceComparison(
              'Sizin Cümleniz:',
              lastAttempt.userSentence.join(' '),
              const Color(0xFFEF4444),
              isDarkMode,
            ),
            const SizedBox(height: 12),
            _buildSentenceComparison(
              'Doğru Cümle:',
              lastAttempt.correctSentence.join(' '),
              const Color(0xFF10B981),
              isDarkMode,
            ),
          ],

          if (!isTimeout) const SizedBox(height: 20),

          // Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Açıklama:',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  gameState.currentExercise.explanation,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Score and action button
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${lastAttempt.score} puan',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Show retry button for timeout, otherwise next exercise
              if (isTimeout) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      controller.restartExercise();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Tekrar Dene',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleNextExercise(controller),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Geç',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _handleNextExercise(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      gameState.currentExerciseIndex + 1 >=
                              gameState.currentLevel.exercises.length
                          ? 'Seviyeyi Tamamla'
                          : 'Sonraki Alıştırma',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceComparison(
    String label,
    String sentence,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sentence,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    SentenceBuildingGameState gameState,
    bool isDarkMode,
    Color primaryColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 64),
            const SizedBox(height: 16),
            Text(
              'Bir Hata Oluştu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              gameState.errorMessage ?? 'Bilinmeyen hata',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: primaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Geri Dön',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBackPress(SentenceBuildingController controller) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF8B5CF6);
    final dialogBgColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                dialogBgColor,
                isDarkMode
                    ? const Color(0xFF2A2E5A).withOpacity(0.95)
                    : Colors.white.withOpacity(0.98),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon with animated container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFEF4444),
                      const Color(0xFFDC2626),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title with enhanced styling
              Text(
                'Oyundan Çık',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description with better formatting
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : const Color(0xFFEF4444).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFEF4444),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Oyundan çıkmak istediğinizden emin misiniz?',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mevcut ilerlemeniz kaybedilecek.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons with enhanced design
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? primaryColor.withOpacity(0.1)
                              : primaryColor.withOpacity(0.05),
                          foregroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'İptal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Exit button
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFEF4444),
                            Color(0xFFDC2626),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.exit_to_app_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Çık',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNextExercise(SentenceBuildingController controller) {
    final gameState =
        ref.read(sentenceBuildingControllerProvider(widget.levelId));

    if (gameState.currentExerciseIndex + 1 >=
        gameState.currentLevel.exercises.length) {
      _showLevelCompletionDialog(gameState);
    } else {
      // Move to next exercise using the public method
      controller.nextExercise();
    }
  }

  void _showLevelCompletionDialog(SentenceBuildingGameState gameState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Seviye Tamamlandı!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: Color(0xFF10B981), size: 64),
            const SizedBox(height: 16),
            Text('Toplam Puan: ${gameState.totalScore}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Ana Menü'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Show exercise selection dialog
  void _showExerciseSelectionDialog(
    SentenceBuildingGameState gameState,
    SentenceBuildingController controller,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF8B5CF6);
    final dialogBgColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final exerciseCount = gameState.currentLevel.exercises.length;
    final currentExerciseIndex = gameState.currentExerciseIndex;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: dialogBgColor,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.format_list_numbered,
                      color: primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Alıştırma Seç',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Exercise grid
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      exerciseCount,
                      (index) {
                        final exercise =
                            gameState.currentLevel.exercises[index];
                        final isCurrentExercise = index == currentExerciseIndex;

                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            if (!isCurrentExercise) {
                              // Navigate to selected exercise
                              controller.loadExercise(index);
                            }
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: isCurrentExercise
                                  ? primaryColor
                                  : (isDarkMode
                                      ? const Color(0xFF3A3F6B)
                                      : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isCurrentExercise
                                    ? primaryColor
                                    : primaryColor.withOpacity(0.3),
                                width: isCurrentExercise ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isCurrentExercise
                                          ? primaryColor
                                          : Colors.black)
                                      .withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isCurrentExercise
                                      ? Icons.play_circle_filled
                                      : Icons.assignment,
                                  color: isCurrentExercise
                                      ? Colors.white
                                      : primaryColor,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrentExercise
                                        ? Colors.white
                                        : textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exercise.title.length > 10
                                      ? '${exercise.title.substring(0, 10)}...'
                                      : exercise.title,
                                  style: TextStyle(
                                    color: isCurrentExercise
                                        ? Colors.white.withOpacity(0.9)
                                        : (isDarkMode
                                            ? Colors.white70
                                            : Colors.grey[600]),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Info text
              Text(
                'Şu anda ${currentExerciseIndex + 1}. alıştırmadasınız',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show restart confirmation dialog
  void _showRestartDialog(SentenceBuildingController controller) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF8B5CF6);
    final dialogBgColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: dialogBgColor,
        title: Row(
          children: [
            Icon(Icons.restart_alt, color: primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Alıştırmayı Yeniden Başlat',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Bu alıştırmayı yeniden başlatmak istediğinizden emin misiniz? Mevcut ilerlemeniz sıfırlanacak.',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add haptic feedback and call restart
              HapticFeedback.mediumImpact();
              controller.restartExercise();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Yeniden Başlat',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Show rewarded ad dialog for hints
  void _showRewardedAdDialog(SentenceBuildingController controller,
      SentenceBuildingGameState gameState) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF8B5CF6);
    final dialogBgColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: dialogBgColor,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.play_circle_filled,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ödüllü Reklam',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '3 yeni ipucu hakkı kazanın',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ad content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.video_library,
                      color: Colors.green,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kısa bir reklam izleyerek 3 yeni ipucu hakkı kazanabilirsiniz.',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reklam sırasında oyun duraklatılacaktır.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDarkMode ? Colors.white70 : Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'İptal',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final currentContext = context;
                        Navigator.of(currentContext).pop();

                        // Show rewarded ad directly (no loading needed since it's pre-loaded)
                        final success =
                            await controller.showRewardedAdForHints();

                        // Show result message
                        if (mounted && currentContext.mounted) {
                          if (success) {
                            // Show success message
                            ScaffoldMessenger.of(currentContext).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                        'Tebrikler! 3 yeni ipucu hakkı kazandınız!'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          } else {
                            // Show error message
                            ScaffoldMessenger.of(currentContext).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                        'Reklam gösterilemedi. Lütfen tekrar deneyin.'),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Reklam İzle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
