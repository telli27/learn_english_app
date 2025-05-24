import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:confetti/confetti.dart';

import '../controllers/word_recall_game_controller.dart';
import '../models/word_models.dart';
import '../themes/game_theme.dart';
import 'word_recall_phase_widgets.dart';

/// Modern Word Recall Game Screen with clean architecture
class WordRecallModernScreen extends ConsumerStatefulWidget {
  final int initialLevel;

  const WordRecallModernScreen({
    super.key,
    this.initialLevel = 1,
  });

  @override
  ConsumerState<WordRecallModernScreen> createState() =>
      _WordRecallModernScreenState();
}

class _WordRecallModernScreenState extends ConsumerState<WordRecallModernScreen>
    with TickerProviderStateMixin {
  // Constants
  static const double _borderRadius = 16.0;
  static const double _cardElevation = 4.0;
  static const double _spacing = 16.0;
  static const Duration _animationDuration = Duration(milliseconds: 300);

  // Controllers
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  late AnimationController _cardAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _cardAnimation;

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  RecallWord? _currentWord;
  WordRecallGameController? _gameController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeGame();
  }

  void _initializeControllers() {
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _cardAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _cardAnimationController, curve: Curves.easeOutBack),
    );
  }

  void _initializeGame() {
    _gameController =
        ref.read(wordRecallGameControllerProvider(widget.initialLevel));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameController?.startTimer(_onTimerTick);
      _cardAnimationController.forward();
    });
  }

  void _onTimerTick() {
    if (mounted) {
      setState(() {
        _selectCurrentWord();
      });
    }
  }

  void _selectCurrentWord() {
    if (_gameController?.gamePhase == RecallGamePhase.recall &&
        _currentWord == null &&
        _gameController!.recallWords.isNotEmpty) {
      setState(() {
        _currentWord = _gameController!.recallWords.first;
        _inputController.clear();
        _inputFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    _cardAnimationController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _gameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        ref.watch(wordRecallGameControllerProvider(widget.initialLevel));
    _gameController = controller;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gameTheme = GameTheme.fromPhase(controller.gamePhase);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(controller, gameTheme),
          SliverFillRemaining(
            child: _buildBody(controller, gameTheme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
      WordRecallGameController controller, GameTheme gameTheme) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: gameTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Kelime Hatırlama',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gameTheme.primaryColor,
                gameTheme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: _buildHeaderContent(controller, gameTheme),
        ),
      ),
      actions: [
        if (controller.gamePhase == RecallGamePhase.study ||
            controller.gamePhase == RecallGamePhase.recall)
          IconButton(
            icon: Icon(
              controller.isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
            ),
            onPressed: () => setState(() => controller.togglePause()),
          ),
      ],
    );
  }

  Widget _buildHeaderContent(
      WordRecallGameController controller, GameTheme gameTheme) {
    return Padding(
      padding: const EdgeInsets.all(_spacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildStatusChips(controller),
          const SizedBox(height: _spacing),
          _buildProgressIndicator(controller, gameTheme),
        ],
      ),
    );
  }

  Widget _buildStatusChips(WordRecallGameController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatusChip(
          icon: Icons.layers,
          label: 'Seviye ${controller.currentLevel.id}',
        ),
        _StatusChip(
          icon: Icons.assignment,
          label:
              '${controller.currentExercise.orderInLevel}/${controller.currentLevel.exercises.length}',
        ),
        _StatusChip(
          icon: _getPhaseIcon(controller.gamePhase),
          label: controller.gamePhase == RecallGamePhase.study ||
                  controller.gamePhase == RecallGamePhase.recall
              ? '${controller.timeLeft}s'
              : _getPhaseText(controller.gamePhase),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(
      WordRecallGameController controller, GameTheme gameTheme) {
    final progress = _calculateProgress(controller);
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withOpacity(0.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody(WordRecallGameController controller, GameTheme gameTheme,
      ColorScheme colorScheme) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(_spacing),
          child: _buildPhaseContent(controller, gameTheme, colorScheme),
        ),
        _buildConfetti(),
      ],
    );
  }

  Widget _buildPhaseContent(WordRecallGameController controller,
      GameTheme gameTheme, ColorScheme colorScheme) {
    switch (controller.gamePhase) {
      case RecallGamePhase.study:
        return StudyPhaseWidget(
          controller: controller,
          gameTheme: gameTheme,
          colorScheme: colorScheme,
          onProceedToRecall: () {
            setState(() {
              controller.proceedToRecallPhase();
              _selectCurrentWord();
            });
          },
        );
      case RecallGamePhase.recall:
        return RecallPhaseWidget(
          controller: controller,
          gameTheme: gameTheme,
          colorScheme: colorScheme,
          currentWord: _currentWord,
          inputController: _inputController,
          inputFocusNode: _inputFocusNode,
          pulseAnimation: _pulseAnimation,
          onCheckAnswer: _checkAnswer,
          onSkipWord: _skipWord,
        );
      case RecallGamePhase.review:
        return ReviewPhaseWidget(
          controller: controller,
          gameTheme: gameTheme,
          colorScheme: colorScheme,
          onComplete: () => setState(() => controller.completeExercise()),
        );
      case RecallGamePhase.complete:
        return CompletePhaseWidget(
          controller: controller,
          gameTheme: gameTheme,
          colorScheme: colorScheme,
          onNextAction: _handleNextAction,
        );
    }
  }

  Widget _buildConfetti() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi / 2,
        emissionFrequency: 0.05,
        numberOfParticles: 30,
        gravity: 0.1,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.pink,
        ],
      ),
    );
  }

  void _checkAnswer() {
    if (_currentWord == null) return;

    final answer = _inputController.text.trim();
    if (answer.isEmpty) {
      _showFeedback('Lütfen bir cevap girin', isError: true);
      return;
    }

    final isCorrect = _gameController!.checkWordRecall(_currentWord!, answer);
    _showFeedback(
      isCorrect ? 'Doğru! 🎉' : 'Yanlış! Doğru: ${_currentWord!.turkish}',
      isError: !isCorrect,
    );

    if (isCorrect) {
      _confettiController.play();
    }

    setState(() {
      _currentWord = null;
      _inputController.clear();
      _selectCurrentWord();
    });
  }

  void _skipWord() {
    if (_currentWord == null) return;

    _showFeedback('Doğru cevap: ${_currentWord!.turkish}');
    _gameController!.skipWord(_currentWord!);

    setState(() {
      _currentWord = null;
      _inputController.clear();
      _selectCurrentWord();
    });
  }

  void _showFeedback(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      gravity: ToastGravity.TOP,
    );
  }

  void _handleNextAction() {
    final isLastExercise = _gameController!.currentExercise.orderInLevel ==
        _gameController!.currentLevel.exercises.length;

    if (isLastExercise) {
      if (_gameController!.isGameCompleted) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WordRecallModernScreen(
              initialLevel: _gameController!.currentLevel.id + 1,
            ),
          ),
        );
      }
    } else {
      setState(() => _gameController!.moveToNextExercise());
    }
  }

  // Helper methods
  IconData _getPhaseIcon(RecallGamePhase phase) {
    switch (phase) {
      case RecallGamePhase.study:
        return Icons.visibility;
      case RecallGamePhase.recall:
        return Icons.psychology;
      case RecallGamePhase.review:
        return Icons.assessment;
      case RecallGamePhase.complete:
        return Icons.celebration;
    }
  }

  String _getPhaseText(RecallGamePhase phase) {
    switch (phase) {
      case RecallGamePhase.study:
        return 'Çalışma';
      case RecallGamePhase.recall:
        return 'Hatırlama';
      case RecallGamePhase.review:
        return 'İnceleme';
      case RecallGamePhase.complete:
        return 'Tamamlandı';
    }
  }

  double _calculateProgress(WordRecallGameController controller) {
    switch (controller.gamePhase) {
      case RecallGamePhase.study:
        return 1.0 -
            (controller.timeLeft / controller.currentExercise.studyTimeSeconds);
      case RecallGamePhase.recall:
        final total = controller.wordCount;
        final completed = controller.correctlyRecalledWords.length +
            controller.incorrectlyRecalledWords.length;
        return total > 0 ? completed / total : 0.0;
      case RecallGamePhase.review:
      case RecallGamePhase.complete:
        return 1.0;
    }
  }
}

/// Status chip widget for header
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
