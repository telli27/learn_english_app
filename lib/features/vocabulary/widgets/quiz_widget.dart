import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

enum QuizMode { multipleChoice, translation, flashcard }

class QuizWidget extends StatefulWidget {
  final List<Flashcard> flashcards;

  const QuizWidget({
    Key? key,
    required this.flashcards,
  }) : super(key: key);

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  late QuizMode _mode;
  late List<Flashcard> _quizCards;
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  bool _answered = false;
  int? _selectedOption;
  bool _isQuizCompleted = false;

  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  String _userAnswer = '';
  bool _showAnswer = false;

  // Options for multiple choice quiz
  late List<String> _currentOptions;
  late int _correctOptionIndex;

  @override
  void initState() {
    super.initState();
    _mode = QuizMode.multipleChoice;
    _prepareQuiz();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  void _prepareQuiz() {
    // Create a copy of the flashcards and shuffle them
    _quizCards = List.from(widget.flashcards);
    _quizCards.shuffle();

    // Remove duplicates to ensure each word is unique
    final uniqueWords = <String>{};
    _quizCards = _quizCards.where((card) {
      final isUnique = !uniqueWords.contains(card.word);
      if (isUnique) uniqueWords.add(card.word);
      return isUnique;
    }).toList();

    // Limit to max 20 cards (changed from 10)
    if (_quizCards.length > 20) {
      _quizCards = _quizCards.sublist(0, 20);
    }

    // Reset quiz state
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _totalAnswered = 0;
      _answered = false;
      _selectedOption = null;
      _isQuizCompleted = false;
      _userAnswer = '';
      _showAnswer = false;
      _answerController.clear();

      if (_quizCards.isNotEmpty) {
        _generateOptionsForCurrentQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _quizCards.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOption = null;
        _userAnswer = '';
        _showAnswer = false;
        _answerController.clear();
        _generateOptionsForCurrentQuestion();
      });
    } else {
      setState(() {
        _isQuizCompleted = true;
      });
    }
  }

  // Generate unique options for the current question
  void _generateOptionsForCurrentQuestion() {
    final correctAnswer = _quizCards[_currentIndex].translation;

    // Get all available translations except the current one
    final allTranslations = widget.flashcards
        .map((card) => card.translation)
        .where((translation) => translation != correctAnswer)
        .toSet() // Use Set to eliminate duplicates
        .toList();

    // If we don't have enough wrong answers (at least 3 ideally),
    // we need to generate some random variations
    List<String> wrongOptions = [];

    if (allTranslations.length >= 3) {
      // We have enough wrong options, shuffle and take 3
      allTranslations.shuffle();
      wrongOptions = allTranslations.take(3).toList();
    } else {
      // Not enough wrong options, use what we have
      wrongOptions = List.from(allTranslations);

      // Add some fake options if we still don't have 3
      final fakeOptions =
          _generateFakeOptions(correctAnswer, 3 - wrongOptions.length);
      wrongOptions.addAll(fakeOptions);
    }

    // Combine with correct answer
    final options = [...wrongOptions, correctAnswer];

    // Shuffle options
    options.shuffle();

    // Store options and correct answer index
    _currentOptions = options;
    _correctOptionIndex = options.indexOf(correctAnswer);
  }

  // Generate fake options that are similar but different from the correct answer
  List<String> _generateFakeOptions(String correctAnswer, int count) {
    final fakeOptions = <String>[];

    // Simple approach: modify the correct answer slightly
    for (int i = 0; i < count; i++) {
      String fake = correctAnswer;

      // Add a suffix based on index to make it different
      switch (i) {
        case 0:
          fake = fake.length > 3
              ? '${fake.substring(0, fake.length - 2)}'
              : '$fake X';
          break;
        case 1:
          fake = '$fake +';
          break;
        case 2:
          fake = 'Diğer $fake';
          break;
        default:
          fake = '$fake?';
      }

      fakeOptions.add(fake);
    }

    return fakeOptions;
  }

  void _checkMultipleChoiceAnswer(int optionIndex) {
    if (_answered) return;

    final isCorrect = optionIndex == _correctOptionIndex;

    setState(() {
      _answered = true;
      _selectedOption = optionIndex;
      _totalAnswered++;
      if (isCorrect) _correctAnswers++;
    });

    // Wait 1.5 seconds before moving to the next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _nextQuestion();
    });
  }

  void _checkTranslationAnswer() {
    if (_answered) return;

    final userAnswerNormalized = _userAnswer.trim().toLowerCase();
    final correctAnswerNormalized =
        _quizCards[_currentIndex].translation.trim().toLowerCase();

    final isCorrect = userAnswerNormalized == correctAnswerNormalized;

    setState(() {
      _answered = true;
      _showAnswer = true;
      _totalAnswered++;
      if (isCorrect) _correctAnswers++;
    });

    // Wait 2 seconds before moving to the next question
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _nextQuestion();
    });
  }

  void _resetQuiz() {
    _prepareQuiz();
  }

  void _changeMode(QuizMode mode) {
    setState(() {
      _mode = mode;
      _prepareQuiz();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = isDark ? const Color(0xFF242424) : Colors.white;

    if (_quizCards.isEmpty) {
      return Center(
        child: Text(
          'Yeterli kelime kartı bulunmamaktadır',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    if (_isQuizCompleted) {
      return _buildQuizResults(isDark);
    }

    return Column(
      children: [
        // Quiz mode selector - sadece 2 seçenek kalsın: Çoktan Seçmeli ve Yazarak
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: SegmentedButton<QuizMode>(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return primaryColor;
                    }
                    return Colors.transparent;
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return isDark ? Colors.white70 : Colors.black87;
                  },
                ),
                textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return const TextStyle(fontWeight: FontWeight.bold);
                    }
                    return const TextStyle(fontWeight: FontWeight.normal);
                  },
                ),
              ),
              segments: const [
                ButtonSegment<QuizMode>(
                  value: QuizMode.multipleChoice,
                  label: Text('Çoktan Seçmeli'),
                  icon: Icon(Icons.checklist),
                ),
                ButtonSegment<QuizMode>(
                  value: QuizMode.translation,
                  label: Text('Yazarak'),
                  icon: Icon(Icons.edit),
                ),
                // Kart modunu kaldırdık
              ],
              selected: {_mode},
              onSelectionChanged: (newSelection) {
                _changeMode(newSelection.first);
              },
            ),
          ),
        ),

        // Progress indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_currentIndex + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Soru ${_currentIndex + 1}/${_quizCards.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_correctAnswers doğru',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _quizCards.length,
                    backgroundColor:
                        isDark ? Colors.white10 : Colors.grey.shade200,
                    color: primaryColor,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Question area
        Expanded(
          child: _mode == QuizMode.multipleChoice
              ? _buildMultipleChoiceQuiz(isDark)
              : _buildTranslationQuiz(isDark),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceQuiz(bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: [
          // Question card - çok daha kompakt hale getirelim
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(bottom: 12),
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Word
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // If there's an image URL, show the image
                    if (_quizCards[_currentIndex].imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _quizCards[_currentIndex].imageUrl,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    if (_quizCards[_currentIndex].imageUrl.isNotEmpty)
                      const SizedBox(width: 12),

                    Text(
                      _quizCards[_currentIndex].word,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Question hint
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Yukarıdaki kelimenin Türkçe karşılığı nedir?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Options - ekranın çoğunluğunu kaplasın
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _currentOptions.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedOption == index;
                final isCorrect = _answered && index == _correctOptionIndex;
                final isWrong = _answered && isSelected && !isCorrect;

                Color cardColor;
                IconData statusIcon;
                Color statusColor;

                if (_answered) {
                  if (isCorrect) {
                    cardColor = Colors.green.withOpacity(isDark ? 0.2 : 0.1);
                    statusIcon = Icons.check_circle;
                    statusColor = Colors.green;
                  } else if (isWrong) {
                    cardColor = Colors.red.withOpacity(isDark ? 0.2 : 0.1);
                    statusIcon = Icons.cancel;
                    statusColor = Colors.red;
                  } else {
                    cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
                    statusIcon = Icons.circle_outlined;
                    statusColor =
                        isDark ? Colors.white38 : Colors.grey.shade400;
                  }
                } else {
                  cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
                  statusIcon = Icons.circle_outlined;
                  statusColor = isDark ? Colors.white38 : Colors.grey.shade400;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12.0),
                  height: 60, // Sabit yükseklik
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? isCorrect
                              ? Colors.green
                              : isWrong
                                  ? Colors.red
                                  : primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? (isCorrect
                                ? Colors.green.withOpacity(0.3)
                                : isWrong
                                    ? Colors.red.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3))
                            : Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _answered
                          ? null
                          : () => _checkMultipleChoiceAnswer(index),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: primaryColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Seçenek göstergesi (daire şeklinde)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? isCorrect
                                        ? Colors.green
                                        : isWrong
                                            ? Colors.red
                                            : primaryColor
                                    : (isDark
                                        ? Colors.white10
                                        : Colors.grey.shade100),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : isDark
                                          ? Colors.white24
                                          : Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  statusIcon,
                                  size: 18,
                                  color:
                                      isSelected ? Colors.white : statusColor,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Şık metni
                            Expanded(
                              child: Text(
                                _currentOptions[index],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),

                            // Doğru/yanlış ikonu (cevaplandıysa)
                            if (_answered)
                              AnimatedOpacity(
                                opacity: isCorrect || isWrong ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 22,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationQuiz(bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: [
          // Question card - çok daha kompakt hale getirelim
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(bottom: 12),
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Word
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // If there's an image URL, show the image
                    if (_quizCards[_currentIndex].imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _quizCards[_currentIndex].imageUrl,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    if (_quizCards[_currentIndex].imageUrl.isNotEmpty)
                      const SizedBox(width: 12),

                    Text(
                      _quizCards[_currentIndex].word,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Question hint
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Yukarıdaki kelimenin Türkçe karşılığını yazınız',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Text input
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Cevabınız',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    // Skip button if not answered yet
                    if (!_answered)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _answered = true;
                            // Önemli değişiklik: showAnswer değişkenini false yap
                            _showAnswer = false;
                            _totalAnswered++;
                          });
                          // Daha kısa bir gecikme ile sonraki soruya geç
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) _nextQuestion();
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.skip_next,
                              size: 16,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Geç',
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Cevap girişi ve kontrol butonu yan yana
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metin girişi
                    Expanded(
                      child: TextField(
                        controller: _answerController,
                        focusNode: _answerFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Cevabınızı yazın',
                          hintStyle: TextStyle(
                            color:
                                isDark ? Colors.white38 : Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor:
                              isDark ? Colors.black12 : Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _userAnswer = value;
                          });
                        },
                        onSubmitted: (_) {
                          if (!_answered) {
                            _checkTranslationAnswer();
                          }
                        },
                        enabled: !_answered,
                      ),
                    ),

                    // Kontrol buton - çok dikkat çekici
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 110,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _answered || _answerController.text.isEmpty
                            ? null
                            : () {
                                _userAnswer = _answerController.text;
                                _checkTranslationAnswer();
                                _answerFocusNode.unfocus();
                              },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('KONTROL ET',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              isDark ? Colors.white12 : Colors.grey.shade200,
                          disabledForegroundColor:
                              isDark ? Colors.white30 : Colors.grey.shade400,
                          elevation: 4,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Enter tuşu ipucu
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.keyboard_return,
                        size: 12,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Enter tuşuna basarak da gönderebilirsiniz',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Answer feedback - sadece cevap gönderildiğinde göster, geçildiğinde gösterme
          if (_showAnswer)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _userAnswer.trim().toLowerCase() ==
                          _quizCards[_currentIndex]
                              .translation
                              .trim()
                              .toLowerCase()
                      ? Colors.green.withOpacity(isDark ? 0.2 : 0.1)
                      : Colors.red.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _userAnswer.trim().toLowerCase() ==
                            _quizCards[_currentIndex]
                                .translation
                                .trim()
                                .toLowerCase()
                        ? Colors.green
                        : Colors.red,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_userAnswer.trim().toLowerCase() ==
                                  _quizCards[_currentIndex]
                                      .translation
                                      .trim()
                                      .toLowerCase()
                              ? Colors.green
                              : Colors.red)
                          .withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _userAnswer.trim().toLowerCase() ==
                                  _quizCards[_currentIndex]
                                      .translation
                                      .trim()
                                      .toLowerCase()
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _userAnswer.trim().toLowerCase() ==
                                  _quizCards[_currentIndex]
                                      .translation
                                      .trim()
                                      .toLowerCase()
                              ? Colors.green
                              : Colors.red,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _userAnswer.trim().toLowerCase() ==
                                  _quizCards[_currentIndex]
                                      .translation
                                      .trim()
                                      .toLowerCase()
                              ? 'Doğru!'
                              : 'Yanlış',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _userAnswer.trim().toLowerCase() ==
                                    _quizCards[_currentIndex]
                                        .translation
                                        .trim()
                                        .toLowerCase()
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (_userAnswer.trim().toLowerCase() !=
                        _quizCards[_currentIndex]
                            .translation
                            .trim()
                            .toLowerCase())
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Doğru cevap: ${_quizCards[_currentIndex].translation}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Placeholder if answer is not shown to maintain layout
          if (!_showAnswer) const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildQuizResults(bool isDark) {
    final scorePercentage =
        _totalAnswered > 0 ? (_correctAnswers / _totalAnswered) * 100 : 0;
    final primaryColor = Theme.of(context).colorScheme.primary;

    String performanceMessage;
    Color performanceColor;

    if (scorePercentage >= 80) {
      performanceMessage = 'Harika iş! Kelimelere çok iyi hakimsiniz.';
      performanceColor = Colors.green;
    } else if (scorePercentage >= 60) {
      performanceMessage = 'İyi iş! Biraz daha pratik yapabilirsiniz.';
      performanceColor = Colors.orange;
    } else {
      performanceMessage = 'Daha fazla çalışma zamanı. Kelimeleri tekrar edin.';
      performanceColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Trophy card
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Trophy icon with circle background
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (scorePercentage >= 80 ? Colors.amber : primaryColor)
                        .withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      scorePercentage >= 80 ? Icons.emoji_events : Icons.school,
                      size: 80,
                      color:
                          scorePercentage >= 80 ? Colors.amber : primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Score text
                Text(
                  'Quiz Tamamlandı!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Score percentage in circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: performanceColor.withOpacity(0.1),
                    border: Border.all(
                      color: performanceColor,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${scorePercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: performanceColor,
                          ),
                        ),
                        Text(
                          '$_correctAnswers / $_totalAnswered',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Performance message
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: performanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        scorePercentage >= 80
                            ? Icons.sentiment_very_satisfied
                            : scorePercentage >= 60
                                ? Icons.sentiment_satisfied
                                : Icons.sentiment_dissatisfied,
                        color: performanceColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          performanceMessage,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: performanceColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Restart button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _resetQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Yeniden Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
