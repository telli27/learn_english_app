import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:async';

class WordMatchingGameScreen extends ConsumerStatefulWidget {
  const WordMatchingGameScreen({super.key});

  @override
  ConsumerState<WordMatchingGameScreen> createState() =>
      _WordMatchingGameScreenState();
}

class _WordMatchingGameScreenState
    extends ConsumerState<WordMatchingGameScreen> {
  // Game state
  bool _isGameActive = true;
  bool _isGameCompleted = false;
  int _score = 0;
  int _currentLevel = 1;
  int _timeLeft = 60;
  bool _isPaused = false;
  Timer? _timer;

  // Selected words
  String? _selectedEnglishWord;
  String? _selectedTurkishWord;

  // Words for current level
  late List<WordPair> _currentWords;
  late List<String> _availableEnglishWords;
  late List<String> _availableTurkishWords;

  // Matched and incorrectly matched words
  final List<WordPair> _matchedWords = [];
  final List<WordPair> _incorrectMatches = [];

  // Global keys for position tracking
  final Map<String, GlobalKey> _englishKeys = {};
  final Map<String, GlobalKey> _turkishKeys = {};

  // Add a key for the main content area to get proper positioning
  final GlobalKey _contentKey = GlobalKey();

  // Demo data - In a real app, this would come from a database
  final List<List<WordPair>> _levels = [
    // Level 1 - Basic words
    [
      WordPair('apple', 'elma'),
      WordPair('house', 'ev'),
      WordPair('car', 'araba'),
      WordPair('water', 'su'),
      WordPair('book', 'kitap'),
    ],
    // Level 2 - Medium words
    [
      WordPair('beautiful', 'güzel'),
      WordPair('difficult', 'zor'),
      WordPair('important', 'önemli'),
      WordPair('yesterday', 'dün'),
      WordPair('tomorrow', 'yarın'),
      WordPair('quickly', 'hızlıca'),
    ],
    // Level 3 - Harder words
    [
      WordPair('achievement', 'başarı'),
      WordPair('development', 'gelişim'),
      WordPair('responsibility', 'sorumluluk'),
      WordPair('opportunity', 'fırsat'),
      WordPair('concentration', 'konsantrasyon'),
      WordPair('perspective', 'bakış açısı'),
      WordPair('environment', 'çevre'),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _setupLevel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupLevel() {
    // Get words for current level (capped at available levels)
    final levelIndex = min(_currentLevel - 1, _levels.length - 1);
    _currentWords = List.from(_levels[levelIndex]);

    // Shuffle both lists to randomize the order
    _availableEnglishWords = _currentWords.map((pair) => pair.english).toList()
      ..shuffle();
    _availableTurkishWords = _currentWords.map((pair) => pair.turkish).toList()
      ..shuffle();

    // Create global keys for each word
    _englishKeys.clear();
    _turkishKeys.clear();

    for (String word in _availableEnglishWords) {
      _englishKeys[word] = GlobalKey();
    }

    for (String word in _availableTurkishWords) {
      _turkishKeys[word] = GlobalKey();
    }

    _matchedWords.clear();
    _incorrectMatches.clear();
    _selectedEnglishWord = null;
    _selectedTurkishWord = null;
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _timeLeft = 60;
      _score = 0;
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _onTimeUp();
        }
      });
    });
  }

  void _onTimeUp() {
    // Pause the game
    setState(() {
      _isPaused = true;
    });

    // Show time up dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Süre Doldu!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Puanınız: $_score'),
            const SizedBox(height: 8),
            Text(
                'Eşleştirilen kelimeler: ${_matchedWords.length}/${_currentWords.length}'),
            const SizedBox(height: 16),
            const Text(
                'Şu anki seviyeyi tekrar oynamak veya farklı bir seviyeye geçmek ister misiniz?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to game selection
            },
            child: const Text('Çıkış'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _setupLevel();
                _timeLeft = 60;
                _isPaused = false;
                _startTimer();
              });
            },
            child: const Text('Tekrar Oyna'),
          ),
          if (_currentLevel < _levels.length)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentLevel++;
                  _setupLevel();
                  _timeLeft = 60;
                  _isPaused = false;
                  _startTimer();
                });
              },
              child: const Text('Sonraki Seviye'),
            ),
        ],
      ),
    );
  }

  // *** IMPROVED SELECTION LOGIC - Fixed deselection ***
  void _handleWordSelection(String word, bool isEnglish) {
    if (_isPaused) return;

    print('Selected word: $word, isEnglish: $isEnglish');
    print('Before: EN=${_selectedEnglishWord}, TR=${_selectedTurkishWord}');

    setState(() {
      if (isEnglish) {
        // If this English word is already selected, deselect it
        if (_selectedEnglishWord == word) {
          _selectedEnglishWord = null;
          print('Deselected English word: $word');
        } else {
          // Select this English word (replacing any previous English selection)
          _selectedEnglishWord = word;
          print('Selected English word: $word');
        }
      } else {
        // If this Turkish word is already selected, deselect it
        if (_selectedTurkishWord == word) {
          _selectedTurkishWord = null;
          print('Deselected Turkish word: $word');
        } else {
          // Select this Turkish word (replacing any previous Turkish selection)
          _selectedTurkishWord = word;
          print('Selected Turkish word: $word');
        }
      }
    });

    print('After: EN=${_selectedEnglishWord}, TR=${_selectedTurkishWord}');
  }

  // Build a card for a word (English or Turkish)
  Widget _buildWordCard(String word, bool isEnglish, Color cardColor,
      Color textColor, int index) {
    // Is this word currently selected?
    final bool isSelected = isEnglish
        ? (_selectedEnglishWord == word)
        : (_selectedTurkishWord == word);

    // Is this word part of a completed match?
    bool isMatched = false;
    for (final pair in _matchedWords) {
      if (isEnglish && pair.english == word) {
        isMatched = true;
        break;
      } else if (!isEnglish && pair.turkish == word) {
        isMatched = true;
        break;
      }
    }

    // Get the appropriate global key
    final GlobalKey cardKey =
        isEnglish ? _englishKeys[word]! : _turkishKeys[word]!;

    return Container(
      key: cardKey, // Add the global key here
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Allow selection/deselection for non-matched words
          if (!isMatched) {
            print('Tapping word: $word, currently selected: $isSelected');
            _handleWordSelection(word, isEnglish);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6C5CE7)
                : isMatched
                    ? Colors.green.withOpacity(0.2)
                    : cardColor,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2.0)
                : isMatched
                    ? Border.all(color: Colors.green, width: 1.0)
                    : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment:
                  isEnglish ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (isEnglish && isSelected)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                Text(
                  word,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : isMatched
                            ? Colors.green
                            : textColor,
                  ),
                ),
                if (!isEnglish && isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // *** FIXED LINE DRAWING LOGIC ***
  Widget _buildConnectionLine() {
    // Safety check - only draw if both words are selected
    if (_selectedEnglishWord == null || _selectedTurkishWord == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: CustomPaint(
        painter: ImprovedConnectionPainter(
          selectedEnglishWord: _selectedEnglishWord!,
          selectedTurkishWord: _selectedTurkishWord!,
          englishKeys: _englishKeys,
          turkishKeys: _turkishKeys,
          contentKey: _contentKey,
        ),
      ),
    );
  }

  void _checkMatchWithButton() {
    if (_isPaused ||
        _selectedEnglishWord == null ||
        _selectedTurkishWord == null) return;

    // Find the correct pair for the selected English word
    final correctPair = _currentWords
        .firstWhere((pair) => pair.english == _selectedEnglishWord);

    if (correctPair.turkish == _selectedTurkishWord) {
      // Correct match
      setState(() {
        _matchedWords.add(correctPair);
        _score += 10;

        // Remove matched words from available lists
        _availableEnglishWords.remove(_selectedEnglishWord);
        _availableTurkishWords.remove(_selectedTurkishWord);

        _selectedEnglishWord = null;
        _selectedTurkishWord = null;

        // Check if level completed
        if (_matchedWords.length == _currentWords.length) {
          _onLevelComplete();
        }
      });
    } else {
      // Incorrect match
      setState(() {
        _incorrectMatches
            .add(WordPair(_selectedEnglishWord!, _selectedTurkishWord!));
        _score = max(0, _score - 2); // Deduct points for wrong match

        _selectedEnglishWord = null;
        _selectedTurkishWord = null;
      });
    }
  }

  void _onLevelComplete() {
    _timer?.cancel();

    setState(() {
      _isPaused = true;
      _isGameCompleted = _currentLevel >= _levels.length;

      // Add time bonus
      int timeBonus = _timeLeft;
      _score += timeBonus;

      if (!_isGameCompleted) {
        _currentLevel++;
      }
    });

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_isGameCompleted
            ? 'Tebrikler! Oyunu Tamamladınız!'
            : 'Seviye Tamamlandı!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Puanınız: $_score'),
            const SizedBox(height: 8),
            Text(
              'Zaman Bonusu: +$_timeLeft puan',
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 16),
            Text(_isGameCompleted
                ? 'Tüm seviyeleri başarıyla tamamladınız.'
                : 'Bir sonraki seviyeye geçmeye hazır mısınız?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_isGameCompleted) {
                Navigator.pop(context); // Return to game selection
              } else {
                setState(() {
                  _setupLevel();
                  _timeLeft = 60;
                  _isPaused = false;
                  _startTimer();
                });
              }
            },
            child: Text(_isGameCompleted ? 'Bitir' : 'Sonraki Seviye'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = true;
    final textColor = Colors.white;
    final backgroundColor = const Color(0xFF1F2247);
    final cardColor = const Color(0xFF2A2E5A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C5CE7),
        elevation: 0,
        title: const Text(
          'Kelime Eşleştirme',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                _isPaused = !_isPaused;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Game stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF6C5CE7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Level indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Seviye $_currentLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Score display
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_score puan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Timer (if game is active)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _timeLeft < 15
                        ? Colors.red.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_timeLeft s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Match progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Text(
                  'Eşleşme: ${_matchedWords.length}/${_currentWords.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _currentWords.isEmpty
                          ? 0
                          : _matchedWords.length / _currentWords.length,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      color: const Color(0xFF6C5CE7),
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'İngilizce',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Türkçe',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const SizedBox(height: 4),

          // Word matching area - ADD KEY HERE
          Expanded(
            key: _contentKey, // Add this key for positioning reference
            child: Stack(
              children: [
                // Word lists
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // English words column
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _availableEnglishWords.length,
                          itemBuilder: (context, index) {
                            final word = _availableEnglishWords[index];
                            return _buildWordCard(
                                word, true, cardColor, textColor, index);
                          },
                        ),
                      ),

                      // Spacer
                      const SizedBox(width: 20),

                      // Turkish words column
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _availableTurkishWords.length,
                          itemBuilder: (context, index) {
                            final word = _availableTurkishWords[index];
                            return _buildWordCard(
                                word, false, cardColor, textColor, index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Draw connection line on top - only if both words are selected
                if (_selectedEnglishWord != null &&
                    _selectedTurkishWord != null)
                  _buildConnectionLine(),
              ],
            ),
          ),

          // Bottom spacer
          const SizedBox(height: 20),

          // Center match button (arrow)
          GestureDetector(
            onTap: _checkMatchWithButton,
            child: Container(
              width: 56,
              height: 56,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: const Color(0xFF4B3FD8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4B3FD8).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WordPair {
  final String english;
  final String turkish;

  WordPair(this.english, this.turkish);
}

// FIXED connection painter with proper positioning
class ImprovedConnectionPainter extends CustomPainter {
  final String selectedEnglishWord;
  final String selectedTurkishWord;
  final Map<String, GlobalKey> englishKeys;
  final Map<String, GlobalKey> turkishKeys;
  final GlobalKey contentKey;

  ImprovedConnectionPainter({
    required this.selectedEnglishWord,
    required this.selectedTurkishWord,
    required this.englishKeys,
    required this.turkishKeys,
    required this.contentKey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      // Get the global keys for the selected words
      final englishKey = englishKeys[selectedEnglishWord];
      final turkishKey = turkishKeys[selectedTurkishWord];
      final contentBox =
          contentKey.currentContext?.findRenderObject() as RenderBox?;

      if (englishKey?.currentContext == null ||
          turkishKey?.currentContext == null ||
          contentBox == null) {
        print('Keys or contexts are null, cannot draw line');
        return;
      }

      // Get the render boxes
      final englishBox =
          englishKey!.currentContext!.findRenderObject() as RenderBox?;
      final turkishBox =
          turkishKey!.currentContext!.findRenderObject() as RenderBox?;

      if (englishBox == null || turkishBox == null) {
        print('Render boxes are null, cannot draw line');
        return;
      }

      // Get positions relative to the content area (not the entire screen)
      final contentPosition = contentBox.localToGlobal(Offset.zero);
      final englishPosition = englishBox.localToGlobal(Offset.zero);
      final turkishPosition = turkishBox.localToGlobal(Offset.zero);

      // Calculate relative positions within the content area
      final englishRelative = Offset(
        englishPosition.dx - contentPosition.dx,
        englishPosition.dy - contentPosition.dy,
      );

      final turkishRelative = Offset(
        turkishPosition.dx - contentPosition.dx,
        turkishPosition.dy - contentPosition.dy,
      );

      // Calculate the center points of the cards
      final englishCenter = Offset(
        englishRelative.dx +
            englishBox.size.width, // Right edge of English card
        englishRelative.dy + (englishBox.size.height / 2), // Center vertically
      );

      final turkishCenter = Offset(
        turkishRelative.dx, // Left edge of Turkish card
        turkishRelative.dy + (turkishBox.size.height / 2), // Center vertically
      );

      print('Drawing line from $englishCenter to $turkishCenter');

      // Create paint for the line
      final paint = Paint()
        ..color = const Color(0xFF6C5CE7)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Create path with a smooth curve
      final path = Path();
      path.moveTo(englishCenter.dx, englishCenter.dy);

      // Create a bezier curve for smooth connection
      final controlPoint1 = Offset(englishCenter.dx + 30, englishCenter.dy);
      final controlPoint2 = Offset(turkishCenter.dx - 30, turkishCenter.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        turkishCenter.dx,
        turkishCenter.dy,
      );

      // Draw the path
      canvas.drawPath(path, paint);

      // Draw dots at endpoints
      final dotPaint = Paint()
        ..color = const Color(0xFF6C5CE7)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(englishCenter, 4, dotPaint);
      canvas.drawCircle(turkishCenter, 4, dotPaint);
    } catch (e) {
      print('Error drawing connection line: $e');
    }
  }

  @override
  bool shouldRepaint(ImprovedConnectionPainter oldDelegate) {
    return oldDelegate.selectedEnglishWord != selectedEnglishWord ||
        oldDelegate.selectedTurkishWord != selectedTurkishWord;
  }
}
