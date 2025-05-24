import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:confetti/confetti.dart';

class WordMatchingGameScreen extends ConsumerStatefulWidget {
  final int initialLevel;

  const WordMatchingGameScreen({
    super.key,
    this.initialLevel = 1,
  });

  @override
  ConsumerState<WordMatchingGameScreen> createState() =>
      _WordMatchingGameScreenState();
}

class _WordMatchingGameScreenState
    extends ConsumerState<WordMatchingGameScreen> {
  bool _isGameActive = true;
  bool _isGameCompleted = false;
  int _score = 0;
  late int _currentLevel;
  int _timeLeft = 60;
  bool _isPaused = false;
  Timer? _timer;
  late ConfettiController _confettiController;

  String? _selectedEnglishWord;
  String? _selectedTurkishWord;

  late List<WordPair> _currentWords;
  late List<String> _availableEnglishWords;
  late List<String> _availableTurkishWords;

  final List<WordPair> _matchedWords = [];
  final List<WordPair> _incorrectMatches = [];

  final Map<String, GlobalKey> _englishKeys = {};
  final Map<String, GlobalKey> _turkishKeys = {};

  final GlobalKey _contentKey = GlobalKey();

  final List<List<WordPair>> _levels = [
    [
      WordPair('apple', 'elma'),
      WordPair('house', 'ev'),
      WordPair('car', 'araba'),
      WordPair('water', 'su'),
      WordPair('book', 'kitap'),
    ],
    [
      WordPair('beautiful', 'güzel'),
      WordPair('difficult', 'zor'),
      WordPair('important', 'önemli'),
      WordPair('yesterday', 'dün'),
      WordPair('tomorrow', 'yarın'),
      WordPair('quickly', 'hızlıca'),
    ],
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
    _currentLevel = widget.initialLevel;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _setupLevel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _setupLevel() {
    final levelIndex = min(_currentLevel - 1, _levels.length - 1);
    _currentWords = List.from(_levels[levelIndex]);

    _availableEnglishWords = _currentWords.map((pair) => pair.english).toList()
      ..shuffle();
    _availableTurkishWords = _currentWords.map((pair) => pair.turkish).toList()
      ..shuffle();

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
    setState(() {
      _isPaused = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF2A2E5A),
        title: const Text(
          'Süre Doldu!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF1F2247),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer_off,
                color: Color(0xFF6C5CE7),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Puanınız: $_score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Eşleştirilen kelimeler: ${_matchedWords.length}/${_currentWords.length}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            const Text(
              'Şu anki seviyeyi tekrar oynamak veya farklı bir seviyeye geçmek ister misiniz?',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Çıkış',
              style: TextStyle(color: Color(0xFFFF7675)),
            ),
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
            child: const Text(
              'Tekrar Oyna',
              style: TextStyle(color: Colors.white),
            ),
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
              child: const Text(
                'Sonraki Seviye',
                style: TextStyle(color: Color(0xFF6C5CE7)),
              ),
            ),
        ],
      ),
    );
  }

  void _handleWordSelection(String word, bool isEnglish) {
    if (_isPaused) return;

    bool isMatched = _isWordMatched(word, isEnglish);
    if (isMatched) {
      return;
    }

    final bool isCurrentlySelected = isEnglish
        ? (_selectedEnglishWord == word)
        : (_selectedTurkishWord == word);

    setState(() {
      if (isEnglish) {
        if (isCurrentlySelected) {
          _selectedEnglishWord = null;
        } else {
          _selectedEnglishWord = word;
        }
      } else {
        if (isCurrentlySelected) {
          _selectedTurkishWord = null;
        } else {
          _selectedTurkishWord = word;
        }
      }
    });
  }

  void _removeWordSelection(String word, bool isEnglish) {
    setState(() {
      if (isEnglish && _selectedEnglishWord == word) {
        _selectedEnglishWord = null;
      } else if (!isEnglish && _selectedTurkishWord == word) {
        _selectedTurkishWord = null;
      }
    });
  }

  bool _isWordMatched(String word, bool isEnglish) {
    for (final pair in _matchedWords) {
      if (isEnglish && pair.english == word) {
        return true;
      } else if (!isEnglish && pair.turkish == word) {
        return true;
      }
    }
    return false;
  }

  Widget _buildWordCard(String word, bool isEnglish, Color cardColor,
      Color textColor, int index) {
    final bool isSelected = isEnglish
        ? (_selectedEnglishWord == word)
        : (_selectedTurkishWord == word);

    bool isMatched = _isWordMatched(word, isEnglish);

    final GlobalKey cardKey =
        isEnglish ? _englishKeys[word]! : _turkishKeys[word]!;

    return Container(
      key: cardKey,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isMatched) {
            _handleWordSelection(word, isEnglish);
          }
        },
        child: Container(
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
                      color: const Color(0xFF6C5CE7).withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
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

  void _clearSelections() {
    setState(() {
      _selectedEnglishWord = null;
      _selectedTurkishWord = null;
    });
  }

  Widget _buildConnectionLine() {
    if (_selectedEnglishWord == null || _selectedTurkishWord == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: CustomPaint(
          painter: ImprovedConnectionPainter(
            selectedEnglishWord: _selectedEnglishWord!,
            selectedTurkishWord: _selectedTurkishWord!,
            englishKeys: _englishKeys,
            turkishKeys: _turkishKeys,
            contentKey: _contentKey,
          ),
        ),
      ),
    );
  }

  void _checkMatchWithButton() {
    if (_isPaused ||
        _selectedEnglishWord == null ||
        _selectedTurkishWord == null) return;

    final correctPair = _currentWords
        .firstWhere((pair) => pair.english == _selectedEnglishWord);

    if (correctPair.turkish == _selectedTurkishWord) {
      setState(() {
        _matchedWords.add(correctPair);
        _score += 10;

        final englishWordToRemove = _selectedEnglishWord!;
        final turkishWordToRemove = _selectedTurkishWord!;

        _selectedEnglishWord = null;
        _selectedTurkishWord = null;

        _availableEnglishWords.remove(englishWordToRemove);
        _availableTurkishWords.remove(turkishWordToRemove);

        _englishKeys.remove(englishWordToRemove);
        _turkishKeys.remove(turkishWordToRemove);

        Fluttertoast.showToast(
            msg: "Doğru eşleşme: +10 puan! 🎉",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);

        if (_matchedWords.length == _currentWords.length) {
          _onLevelComplete();
        }
      });
    } else {
      setState(() {
        _incorrectMatches
            .add(WordPair(_selectedEnglishWord!, _selectedTurkishWord!));
        _score = max(0, _score - 2);

        _selectedEnglishWord = null;
        _selectedTurkishWord = null;

        Fluttertoast.showToast(
            msg: "Yanlış eşleşme: -2 puan! ❌",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
  }

  void _onLevelComplete() {
    _timer?.cancel();

    setState(() {
      _isPaused = true;
      _isGameCompleted = _currentLevel >= _levels.length;

      int timeBonus = _timeLeft;
      _score += timeBonus;
    });

    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF2A2E5A),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isGameCompleted
                        ? 'Tebrikler! Oyunu Tamamladınız!'
                        : 'Seviye $_currentLevel Tamamlandı!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2247),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Doğru Eşleşmeler:',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '${_matchedWords.length} / ${_currentWords.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Zaman Bonusu:',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '+$_timeLeft puan',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Toplam Puan:',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '$_score',
                              style: const TextStyle(
                                color: Color(0xFF6C5CE7),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _isGameCompleted
                        ? 'Tüm seviyeleri başarıyla tamamladınız!'
                        : 'Bir sonraki seviyeye geçmeye hazır mısınız?',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Ana Menü',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      if (!_isGameCompleted)
                        ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            'Sonraki Seviye',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_isGameCompleted)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            'Bitir',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A2E5A), width: 5),
                ),
                child: Icon(
                  _isGameCompleted ? Icons.emoji_events : Icons.check_circle,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            Positioned(
              top: -60,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 1,
                emissionFrequency: 0.03,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                ],
              ),
            ),
          ],
        ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
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
                        'Seviye $_currentLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
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
                        '$_score puan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _timeLeft < 15
                        ? Colors.red.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_timeLeft s',
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
          ),
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
          Expanded(
            key: _contentKey,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _availableEnglishWords.length,
                                  itemBuilder: (context, index) {
                                    final word = _availableEnglishWords[index];
                                    return _buildWordCard(word, true, cardColor,
                                        textColor, index);
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _availableTurkishWords.length,
                                  itemBuilder: (context, index) {
                                    final word = _availableTurkishWords[index];
                                    return _buildWordCard(word, false,
                                        cardColor, textColor, index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ElevatedButton.icon(
                          onPressed: (_selectedEnglishWord != null &&
                                  _selectedTurkishWord != null)
                              ? _checkMatchWithButton
                              : null,
                          icon: const Icon(
                            Icons.compare_arrows,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: const Text(
                            "EŞLEŞTİR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_selectedEnglishWord != null &&
                                    _selectedTurkishWord != null)
                                ? const Color(0xFF4B3FD8)
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: (_selectedEnglishWord != null &&
                                    _selectedTurkishWord != null)
                                ? 8
                                : 0,
                            shadowColor: (_selectedEnglishWord != null &&
                                    _selectedTurkishWord != null)
                                ? const Color(0xFF4B3FD8).withOpacity(0.4)
                                : null,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (_selectedEnglishWord != null &&
                    _selectedTurkishWord != null)
                  _buildConnectionLine(),
              ],
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
      final englishKey = englishKeys[selectedEnglishWord];
      final turkishKey = turkishKeys[selectedTurkishWord];
      final contentBox =
          contentKey.currentContext?.findRenderObject() as RenderBox?;

      if (englishKey?.currentContext == null ||
          turkishKey?.currentContext == null ||
          contentBox == null) {
        return;
      }

      final englishBox =
          englishKey!.currentContext!.findRenderObject() as RenderBox?;
      final turkishBox =
          turkishKey!.currentContext!.findRenderObject() as RenderBox?;

      if (englishBox == null || turkishBox == null) {
        return;
      }

      final contentPosition = contentBox.localToGlobal(Offset.zero);
      final englishPosition = englishBox.localToGlobal(Offset.zero);
      final turkishPosition = turkishBox.localToGlobal(Offset.zero);

      final englishRelative = Offset(
        englishPosition.dx - contentPosition.dx,
        englishPosition.dy - contentPosition.dy,
      );

      final turkishRelative = Offset(
        turkishPosition.dx - contentPosition.dx,
        turkishPosition.dy - contentPosition.dy,
      );

      final englishCenter = Offset(
        englishRelative.dx + englishBox.size.width,
        englishRelative.dy + (englishBox.size.height / 2),
      );

      final turkishCenter = Offset(
        turkishRelative.dx,
        turkishRelative.dy + (turkishBox.size.height / 2),
      );

      final paint = Paint()
        ..color = const Color(0xFF6C5CE7)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(englishCenter.dx, englishCenter.dy);

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

      canvas.drawPath(path, paint);

      final dotPaint = Paint()
        ..color = const Color(0xFF6C5CE7)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(englishCenter, 4, dotPaint);
      canvas.drawCircle(turkishCenter, 4, dotPaint);
    } catch (e) {}
  }

  @override
  bool shouldRepaint(ImprovedConnectionPainter oldDelegate) {
    return oldDelegate.selectedEnglishWord != selectedEnglishWord ||
        oldDelegate.selectedTurkishWord != selectedTurkishWord;
  }
}
