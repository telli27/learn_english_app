import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math' as math;

import '../models/listening_models.dart';
import '../providers/listening_provider.dart';

/// Professional story-based listening practice screen with modern design
class ListeningStoryScreen extends ConsumerStatefulWidget {
  final ListeningStory story;

  const ListeningStoryScreen({
    super.key,
    required this.story,
  });

  @override
  ConsumerState<ListeningStoryScreen> createState() =>
      _ListeningStoryScreenState();
}

class _ListeningStoryScreenState extends ConsumerState<ListeningStoryScreen>
    with TickerProviderStateMixin {
  /// Animation controllers - sadece gerekli olanlar
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  /// TTS instance
  late FlutterTts _flutterTts;

  /// Story state
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isCompleted = false;
  bool _showQuestions = false;
  int _currentQuestionIndex = 0;
  final Map<String, String> _userAnswers = <String, String>{};
  int _score = 0;

  /// Text highlighting
  List<String> _words = [];
  int _currentWordIndex = 0;
  double _speechRate = 0.4; // AudioSpeed.slow ile eşleşen hız
  bool _showText = true;

  /// Page controller for smooth transitions
  late PageController _pageController;
  int _currentPage = 0; // 0: story, 1: questions

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _initializeText();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _pageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  /// Initialize animations with professional timing
  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    );

    // Start animations
    _fadeAnimationController.forward();
  }

  /// Initialize TTS
  void _initializeTTS() async {
    _flutterTts = FlutterTts();

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts
        .setPitch(0.9); // Biraz daha düşük pitch daha rahat dinleme için

    _flutterTts.setStartHandler(() {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      _startWordHighlighting();
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _isCompleted = true;
        _currentWordIndex = _words.length;
      });
    });

    _flutterTts.setPauseHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    });

    _flutterTts.setContinueHandler(() {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      _startWordHighlighting();
    });
  }

  /// Initialize text for highlighting
  void _initializeText() {
    _words = widget.story.content
        .replaceAll('\n', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// Start word highlighting animation
  void _startWordHighlighting() {
    if (!_isPlaying) return;

    // Gerçek zamanlı senkronizasyon için daha hassas hesaplama
    final wordsPerSecond = 1.2 * _speechRate; // Daha hassas takip
    final millisecondsPerWord =
        (800 / wordsPerSecond).round(); // Daha kısa aralıklar

    Future.delayed(Duration(milliseconds: millisecondsPerWord), () {
      if (_isPlaying && _currentWordIndex < _words.length) {
        setState(() {
          _currentWordIndex++;
        });
        _startWordHighlighting();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Professional color scheme
    final primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF667EEA),
        const Color(0xFF764BA2),
      ],
    );

    final secondaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFF093FB),
        const Color(0xFFF5576C),
      ],
    );

    final backgroundColor =
        isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFF8FAFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern compact header
            _buildCompactHeader(primaryGradient, isDarkMode),

            // Content with page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Story page
                  _buildModernStoryPage(
                      primaryGradient, secondaryGradient, isDarkMode),
                  // Questions page
                  _buildQuestionsPage(
                      primaryGradient, secondaryGradient, isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build compact modern header
  Widget _buildCompactHeader(LinearGradient primaryGradient, bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryGradient.colors[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top row with back button and title
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.story.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.story.summary,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageIndicator(0, 'Hikaye', Icons.book),
                const SizedBox(width: 20),
                _buildPageIndicator(1, 'Sorular', Icons.quiz),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build modern story page
  Widget _buildModernStoryPage(LinearGradient primaryGradient,
      LinearGradient secondaryGradient, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Clean audio player
          _buildModernAudioPlayer(
              primaryGradient, secondaryGradient, isDarkMode),

          const SizedBox(height: 24),

          // Clean text display
          _buildCleanTextDisplay(primaryGradient, isDarkMode),

          const SizedBox(height: 24),

          // Simple control buttons
          _buildSimpleControlButtons(primaryGradient, isDarkMode),
        ],
      ),
    );
  }

  /// Build modern audio player
  Widget _buildModernAudioPlayer(LinearGradient primaryGradient,
      LinearGradient secondaryGradient, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Simple play button without animations
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: primaryGradient.colors[0].withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(40),
              child: InkWell(
                onTap: _togglePlayPause,
                borderRadius: BorderRadius.circular(40),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Progress indicator
          if (_words.isNotEmpty)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_currentWordIndex}/${_words.length} words',
                      style: TextStyle(
                        color: primaryGradient.colors[0],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _words.isEmpty ? 0 : _currentWordIndex / _words.length,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(primaryGradient.colors[0]),
                  minHeight: 6,
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Speed control
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Okuma Hızı',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: AudioSpeed.values.map((speed) {
                    final isSelected = (_speechRate - speed.value).abs() < 0.01;
                    return GestureDetector(
                      onTap: () => _changeSpeed(speed.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? primaryGradient : null,
                          color: isSelected ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          speed.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDarkMode
                                    ? Colors.white70
                                    : Colors.grey[700]),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build clean text display
  Widget _buildCleanTextDisplay(
      LinearGradient primaryGradient, bool isDarkMode) {
    if (!_showText) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryGradient.colors[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.headphones,
                size: 48,
                color: primaryGradient.colors[0],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Listen Only Mode',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Focus on listening to improve your comprehension skills',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryGradient.colors[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.article,
                  color: primaryGradient.colors[0],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Story Text',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGradient.colors[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentWordIndex}/${_words.length}',
                  style: TextStyle(
                    color: primaryGradient.colors[0],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: RichText(
                text: TextSpan(
                  children: _words.asMap().entries.map((entry) {
                    final index = entry.key;
                    final word = entry.value;
                    final isHighlighted = index < _currentWordIndex;
                    final isCurrentWord =
                        index == _currentWordIndex - 1 && _isPlaying;

                    return TextSpan(
                      text: '$word ',
                      style: TextStyle(
                        color: isHighlighted
                            ? primaryGradient.colors[0]
                            : (isDarkMode ? Colors.white70 : Colors.grey[700]),
                        fontSize: 16,
                        height: 1.8,
                        fontWeight:
                            isCurrentWord ? FontWeight.bold : FontWeight.normal,
                        backgroundColor: isCurrentWord
                            ? primaryGradient.colors[0].withOpacity(0.2)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build simple control buttons
  Widget _buildSimpleControlButtons(
      LinearGradient primaryGradient, bool isDarkMode) {
    return Column(
      children: [
        // Show/Hide text toggle
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: primaryGradient.colors[0].withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _showText = !_showText),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showText ? Icons.visibility_off : Icons.visibility,
                    color: primaryGradient.colors[0],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _showText ? 'Hide Text' : 'Show Text',
                    style: TextStyle(
                      color: primaryGradient.colors[0],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Continue to questions button
        if (_isCompleted)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryGradient.colors[0].withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Continue to Questions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build page indicator
  Widget _buildPageIndicator(int page, String label, IconData icon) {
    final isActive = _currentPage == page;
    final isAccessible = page == 0 || _isCompleted;

    return GestureDetector(
      onTap: isAccessible
          ? () {
              _pageController.animateToPage(
                page,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(isAccessible ? 1.0 : 0.6),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(isAccessible ? 1.0 : 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle play/pause
  void _togglePlayPause() async {
    if (_isPlaying) {
      await _flutterTts.pause();
    } else if (_isPaused) {
      await _flutterTts.speak(widget.story.content);
    } else {
      // Yeni başlangıç - kelime indeksini sıfırla
      setState(() {
        _currentWordIndex = 0;
      });

      // TTS ayarlarını yeniden uygula
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(0.8);

      await _flutterTts.speak(widget.story.content);
    }
  }

  /// Change speech rate
  void _changeSpeed(double rate) async {
    // Çok yavaş hızları destekle
    final clampedRate = rate.clamp(0.1, 2.0);

    setState(() {
      _speechRate = clampedRate;
    });

    // TTS'i durdur ve yeni hızla ayarla
    await _flutterTts.stop();
    await _flutterTts.setSpeechRate(clampedRate);

    // Eğer oynatılıyorsa, yeni hızla devam et
    if (_isPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
      await _flutterTts.speak(widget.story.content);
    }

    // Update TTS state provider
    final audioSpeed = AudioSpeed.values.firstWhere(
        (speed) => speed.value == rate,
        orElse: () => AudioSpeed.normal);
    ref.read(ttsStateProvider.notifier).changeSpeed(audioSpeed);
  }

  /// Select answer
  void _selectAnswer(String questionId, String answer) {
    setState(() {
      _userAnswers[questionId] = answer;
    });
  }

  /// Next question
  void _nextQuestion() {
    if (_currentQuestionIndex <
        widget.story.comprehensionQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  /// Finish questions
  void _finishQuestions() {
    // Calculate score
    int correctAnswers = 0;
    for (final question in widget.story.comprehensionQuestions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer == question.correctAnswer) {
        correctAnswers++;
      }
    }

    _score = (correctAnswers / widget.story.comprehensionQuestions.length * 100)
        .round();

    // Update progress
    ref
        .read(listeningProgressProvider.notifier)
        .completeStory(widget.story.id, _score);

    // Show completion dialog
    _showCompletionDialog();
  }

  /// Show completion dialog
  void _showCompletionDialog() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF667EEA),
        const Color(0xFF764BA2),
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGradient.colors[0].withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Congratulations!',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'You have successfully completed the story',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Score display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryGradient.colors[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: primaryGradient.colors[0],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Score: $_score%',
                      style: TextStyle(
                        color: primaryGradient.colors[0],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to level detail
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build questions page
  Widget _buildQuestionsPage(LinearGradient primaryGradient,
      LinearGradient secondaryGradient, bool isDarkMode) {
    if (widget.story.comprehensionQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Questions Available',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This story doesn\'t have comprehension questions yet.',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final currentQuestion =
        widget.story.comprehensionQuestions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Question progress
          _buildQuestionProgress(primaryGradient, isDarkMode),

          const SizedBox(height: 20),

          // Question card
          _buildQuestionCard(
              currentQuestion, primaryGradient, secondaryGradient, isDarkMode),

          const SizedBox(height: 20),

          // Action buttons
          _buildQuestionButtons(primaryGradient, secondaryGradient, isDarkMode),
        ],
      ),
    );
  }

  /// Build question progress
  Widget _buildQuestionProgress(
      LinearGradient primaryGradient, bool isDarkMode) {
    final progress = (_currentQuestionIndex + 1) /
        widget.story.comprehensionQuestions.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${widget.story.comprehensionQuestions.length}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryGradient.colors[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: primaryGradient.colors[0],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor:
                AlwaysStoppedAnimation<Color>(primaryGradient.colors[0]),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  /// Build question card
  Widget _buildQuestionCard(
    ListeningQuestion question,
    LinearGradient primaryGradient,
    LinearGradient secondaryGradient,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _userAnswers[question.id] == option;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _selectAnswer(question.id, option),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryGradient.colors[0].withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? primaryGradient.colors[0]
                            : Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? primaryGradient.colors[0]
                                  : Colors.grey.withOpacity(0.5),
                              width: 2,
                            ),
                            color: isSelected
                                ? primaryGradient.colors[0]
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isSelected
                                  ? primaryGradient.colors[0]
                                  : (isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build question buttons
  Widget _buildQuestionButtons(LinearGradient primaryGradient,
      LinearGradient secondaryGradient, bool isDarkMode) {
    final hasAnswer = _userAnswers.containsKey(
        widget.story.comprehensionQuestions[_currentQuestionIndex].id);
    final isLastQuestion =
        _currentQuestionIndex == widget.story.comprehensionQuestions.length - 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: hasAnswer
            ? [
                BoxShadow(
                  color: primaryGradient.colors[0].withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: hasAnswer
              ? (isLastQuestion ? _finishQuestions : _nextQuestion)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isLastQuestion ? 'Finish' : 'Next Question',
              style: TextStyle(
                color: hasAnswer ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
