import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_word.dart';
import '../providers/daily_word_provider.dart';
import 'package:confetti/confetti.dart';

class WordMatchGameScreen extends ConsumerStatefulWidget {
  const WordMatchGameScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WordMatchGameScreen> createState() =>
      _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends ConsumerState<WordMatchGameScreen> {
  List<DailyWord> _gameWords = [];
  List<String> _wordOptions = [];
  List<String> _translationOptions = [];
  Map<String, String?> _selectedMatches = {};
  String? _draggedWord;
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 3;
  bool _roundComplete = false;

  // Confetti controller for victory animation
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _setupGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _setupGame() {
    final allWords = ref.read(dailyWordProvider).valueOrNull ?? [];

    if (allWords.isEmpty) {
      // Fallback if no words are loaded
      return;
    }

    // Shuffle and select 5 random words for this round
    final shuffledWords = List<DailyWord>.from(allWords)..shuffle();
    _gameWords = shuffledWords.take(5).toList();

    // Create separate lists for words and translations
    _wordOptions = _gameWords.map((word) => word.word).toList()..shuffle();
    _translationOptions = _gameWords.map((word) => word.translation).toList()
      ..shuffle();

    // Reset matches
    _selectedMatches = {};
    _draggedWord = null;
    _roundComplete = false;
  }

  void _checkRoundCompletion() {
    // Round is complete if all words have been matched
    if (_selectedMatches.length == _wordOptions.length) {
      // Count correct matches
      int correctMatches = 0;
      for (int i = 0; i < _gameWords.length; i++) {
        final word = _gameWords[i].word;
        final correctTranslation = _gameWords[i].translation;

        if (_selectedMatches[word] == correctTranslation) {
          correctMatches++;
        }
      }

      // Update score
      setState(() {
        _score += correctMatches;
        _roundComplete = true;

        // Play confetti if all correct
        if (correctMatches == _wordOptions.length) {
          _confettiController.play();
        }
      });
    }
  }

  void _nextRound() {
    if (_round < _maxRounds) {
      setState(() {
        _round++;
        _setupGame();
      });
    } else {
      // Game complete - show results dialog
      _showGameCompleteDialog();
    }
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _round = 1;
      _setupGame();
    });
  }

  void _showGameCompleteDialog() {
    final maxPossibleScore = _maxRounds * 5; // 5 words per round
    final percentage = (_score / maxPossibleScore * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Oyun Tamamlandı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Puanınız: $_score / $maxPossibleScore'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _score / maxPossibleScore,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 80
                    ? Colors.green
                    : percentage > 50
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getFeedbackMessage(percentage),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text('Tekrar Oyna'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  String _getFeedbackMessage(int percentage) {
    if (percentage >= 90) {
      return 'Harika! Mükemmel bir sonuç!';
    } else if (percentage >= 70) {
      return 'Çok iyi! Kelimeleri öğreniyorsun!';
    } else if (percentage >= 50) {
      return 'İyi iş! Biraz daha pratik yapabilirsin.';
    } else {
      return 'Daha fazla pratik yapmaya devam et!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Eşleştirme'),
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tur: $_round/$_maxRounds',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Score indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: isDark ? Colors.black12 : Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Puan: $_score',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (_roundComplete)
                      ElevatedButton(
                        onPressed: _nextRound,
                        child: Text(
                            _round == _maxRounds ? 'Sonuçlar' : 'Sonraki Tur'),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: _gameWords.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Instructions
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Text(
                                'Kelimeleri doğru anlamlarıyla eşleştirin!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // Column of source words (left side)
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Words column
                                  Expanded(
                                    child: Column(
                                      children: _wordOptions.map((word) {
                                        final matched =
                                            _selectedMatches.containsKey(word);

                                        return Draggable<String>(
                                          data: word,
                                          feedback: _buildWordCard(
                                            word,
                                            matched: matched,
                                            isDragging: true,
                                          ),
                                          childWhenDragging: _buildWordCard(
                                            word,
                                            matched: matched,
                                            isPlaceholder: true,
                                          ),
                                          onDragStarted: () {
                                            setState(() {
                                              _draggedWord = word;
                                            });
                                          },
                                          onDragEnd: (_) {
                                            setState(() {
                                              _draggedWord = null;
                                            });
                                          },
                                          child: _buildWordCard(
                                            word,
                                            matched: matched,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),

                                  // Arrow indicators
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          Icons.arrow_forward,
                                          color: isDark
                                              ? Colors.white30
                                              : Colors.black12,
                                          size: 24,
                                        );
                                      }),
                                    ),
                                  ),

                                  // Translations column (right side)
                                  Expanded(
                                    child: Column(
                                      children: _translationOptions
                                          .map((translation) {
                                        final isMatched = _selectedMatches
                                            .containsValue(translation);

                                        return DragTarget<String>(
                                          builder: (context, candidateData,
                                              rejectedData) {
                                            final isTargeted =
                                                candidateData.isNotEmpty;

                                            return _buildTranslationCard(
                                              translation,
                                              matched: isMatched,
                                              isTargeted: isTargeted,
                                            );
                                          },
                                          onAccept: (word) {
                                            // If the translation was already matched with another word, clear that match
                                            _selectedMatches.removeWhere(
                                                (key, value) =>
                                                    value == translation);

                                            // Set the new match
                                            setState(() {
                                              _selectedMatches[word] =
                                                  translation;
                                              _checkRoundCompletion();
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // straight up
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(String word,
      {bool matched = false,
      bool isDragging = false,
      bool isPlaceholder = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isDragging ? 8 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: matched
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : BorderSide.none,
        ),
        color: isPlaceholder
            ? Colors.transparent
            : matched
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : isDark
                    ? const Color(0xFF2A2A2A)
                    : Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Center(
            child: Text(
              isPlaceholder ? '' : word,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: matched
                    ? Theme.of(context).colorScheme.primary
                    : isDark
                        ? Colors.white
                        : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationCard(String translation,
      {bool matched = false, bool isTargeted = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isTargeted ? 8 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: matched
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : isTargeted
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    )
                  : BorderSide.none,
        ),
        color: matched
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : isTargeted
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                : isDark
                    ? const Color(0xFF2A2A2A)
                    : Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Center(
            child: Text(
              translation,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: matched
                    ? Theme.of(context).colorScheme.primary
                    : isTargeted
                        ? Theme.of(context).colorScheme.secondary
                        : isDark
                            ? Colors.white
                            : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
