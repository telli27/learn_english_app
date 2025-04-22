import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../utils/constants/colors.dart';

class ExerciseQuizScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> exercise;
  final Color color;

  const ExerciseQuizScreen({
    Key? key,
    required this.exercise,
    required this.color,
  }) : super(key: key);

  @override
  ConsumerState<ExerciseQuizScreen> createState() => _ExerciseQuizScreenState();
}

class _ExerciseQuizScreenState extends ConsumerState<ExerciseQuizScreen> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _answered = false;
  int? _selectedOptionIndex;
  bool _quizCompleted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    final questions =
        widget.exercise['questions'] as List<Map<String, dynamic>>;
    final currentQuestion = questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text(
          widget.exercise['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitConfirmation();
          },
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Soru ${_currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _quizCompleted
          ? _buildResultScreen(isDark, questions.length)
          : _buildQuizContent(currentQuestion, questions, isDark),
    );
  }

  Widget _buildQuizContent(Map<String, dynamic> question,
      List<Map<String, dynamic>> questions, bool isDark) {
    final questionType = question['type'] as String? ?? 'multiple_choice';

    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / questions.length,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          minHeight: 6,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soru Tipi Göstergesi
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.color.withOpacity(0.3)),
                  ),
                  child: Text(
                    _getQuestionTypeLabel(questionType),
                    style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Soru
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF242424) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
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
                              color: widget.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getQuestionTypeIcon(questionType),
                              color: widget.color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Soru ${_currentQuestionIndex + 1}',
                            style: TextStyle(
                              color: widget.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Soru metni
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (question['hint'] != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.5),
                                ),
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
                                      question['hint'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            question['question'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      if (question['imageUrl'] != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade200,
                            image: DecorationImage(
                              image: AssetImage(question['imageUrl'] as String),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                      if (question['example'] != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.indigo.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Örnek:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                question['example'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cevap alanı (soru tipine göre değişir)
                _buildAnswerWidget(question, questionType, isDark),

                const SizedBox(height: 16),

                // Geri bildirim
                if (_answered) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF303030)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedOptionIndex == question['correctAnswer']
                            ? Colors.green.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedOptionIndex == question['correctAnswer']
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: _selectedOptionIndex ==
                                      question['correctAnswer']
                                  ? Colors.green
                                  : Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedOptionIndex == question['correctAnswer']
                                  ? 'Doğru Cevap! 👍'
                                  : 'Yanlış Cevap! 🤔',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _selectedOptionIndex ==
                                        question['correctAnswer']
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Açıklama:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          question['explanation'] as String? ??
                              'Bu türdeki sorularda, verilen gramer yapısını doğru şekilde uygulamanız gerekir.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                          ),
                        ),
                        if (question['grammarRule'] != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.school,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Gramer Kuralı:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  question['grammarRule'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Alt kısımdaki buton
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF242424) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _answered
                ? () => _nextQuestion(questions.length)
                : _selectedOptionIndex != null
                    ? _checkAnswer
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              _answered
                  ? _currentQuestionIndex == questions.length - 1
                      ? 'Sonuçları Gör'
                      : 'Sonraki Soru'
                  : 'Cevabı Kontrol Et',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Soru tipine göre ikon belirleme
  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'multiple_choice':
        return Icons.help_outline;
      case 'fill_in_the_blank':
        return Icons.text_fields;
      case 'true_false':
        return Icons.rule;
      case 'matching':
        return Icons.compare_arrows;
      default:
        return Icons.help_outline;
    }
  }

  // Soru tipi etiketi
  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Çoktan Seçmeli';
      case 'fill_in_the_blank':
        return 'Boşluk Doldurma';
      case 'true_false':
        return 'Doğru/Yanlış';
      case 'matching':
        return 'Eşleştirme';
      default:
        return 'Çoktan Seçmeli';
    }
  }

  // Soru tipine göre cevap widget'ı oluşturma
  Widget _buildAnswerWidget(
      Map<String, dynamic> question, String questionType, bool isDark) {
    switch (questionType) {
      case 'multiple_choice':
        return _buildMultipleChoiceWidget(question, isDark);
      case 'true_false':
        return _buildTrueFalseWidget(question, isDark);
      case 'fill_in_the_blank':
        return _buildFillInTheBlankWidget(question, isDark);
      case 'matching':
        return _buildMatchingWidget(question, isDark);
      default:
        return _buildMultipleChoiceWidget(question, isDark);
    }
  }

  // Çoktan seçmeli soru widgetı
  Widget _buildMultipleChoiceWidget(
      Map<String, dynamic> question, bool isDark) {
    final options = question['options'] as List<String>;

    // correctAnswer'ın değişken tipini kontrol et
    dynamic correctAnswer = question['correctAnswer'];
    int correctIndex;

    if (correctAnswer is int) {
      correctIndex = correctAnswer;
    } else if (correctAnswer is String) {
      // "Doğru", "A", "B" gibi string cevapları ya da sayısal string cevapları işle
      if (int.tryParse(correctAnswer) != null) {
        correctIndex = int.parse(correctAnswer);
      } else {
        // Eğer "Doğru" gibi bir string ise ve seçenekler içinde varsa, index'ini bul
        correctIndex = options.indexOf(correctAnswer);
        // Eğer bulunamazsa, varsayılan olarak 0 kullan
        if (correctIndex == -1) correctIndex = 0;
      }
    } else if (correctAnswer is bool) {
      // Boolean değer için: true=0, false=1 olarak kabul et
      correctIndex = correctAnswer ? 0 : 1;
    } else {
      // Hiçbir tip eşleşmezse, varsayılan olarak 0 kullan
      correctIndex = 0;
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final isSelected = _selectedOptionIndex == index;
        final isCorrect = index == correctIndex;

        Color backgroundColor = Colors.transparent;
        Color borderColor =
            isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        Color textColor = isDark ? Colors.white : Colors.black87;

        if (_answered) {
          if (isCorrect) {
            backgroundColor = Colors.green.withOpacity(0.1);
            borderColor = Colors.green;
            textColor = Colors.green;
          } else if (isSelected) {
            backgroundColor = Colors.red.withOpacity(0.1);
            borderColor = Colors.red;
            textColor = Colors.red;
          }
        } else if (isSelected) {
          backgroundColor = widget.color.withOpacity(0.1);
          borderColor = widget.color;
          textColor = widget.color;
        }

        return GestureDetector(
          onTap: _answered ? null : () => _selectOption(index),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? borderColor
                        : isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                    border: Border.all(
                      color: borderColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? Colors.white
                                : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
                if (_answered) ...[
                  Icon(
                    isCorrect
                        ? Icons.check_circle
                        : (isSelected ? Icons.cancel : null),
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Doğru/Yanlış soru widgetı
  Widget _buildTrueFalseWidget(Map<String, dynamic> question, bool isDark) {
    final correctAnswer = question['correctAnswer'] as bool;

    return Column(
      children: [
        _buildTrueFalseOption(true, correctAnswer, isDark),
        const SizedBox(height: 12),
        _buildTrueFalseOption(false, correctAnswer, isDark),
      ],
    );
  }

  Widget _buildTrueFalseOption(bool value, bool correctAnswer, bool isDark) {
    final isSelected = _selectedOptionIndex == (value ? 0 : 1);
    final isCorrect = value == correctAnswer;

    Color backgroundColor = Colors.transparent;
    Color borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    Color textColor = isDark ? Colors.white : Colors.black87;

    if (_answered) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = widget.color.withOpacity(0.1);
      borderColor = widget.color;
      textColor = widget.color;
    }

    return GestureDetector(
      onTap: _answered ? null : () => _selectOption(value ? 0 : 1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? borderColor
                    : isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  value ? Icons.check : Icons.close,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white
                          : Colors.black87,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              value ? 'Doğru' : 'Yanlış',
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const Spacer(),
            if (_answered && (value ? 0 : 1) == _selectedOptionIndex) ...[
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Boşluk doldurma soru widgetı
  Widget _buildFillInTheBlankWidget(
      Map<String, dynamic> question, bool isDark) {
    final options = question['options'] as List<String>;
    final correctAnswer = question['correctAnswer'];
    int correctIndex = 0;

    // correctAnswer'ı işle
    if (correctAnswer is int) {
      correctIndex = correctAnswer;
    } else if (correctAnswer is String) {
      if (int.tryParse(correctAnswer) != null) {
        correctIndex = int.parse(correctAnswer);
      } else {
        correctIndex = options.indexOf(correctAnswer);
        if (correctIndex == -1) correctIndex = 0;
      }
    }

    // Sorudaki "_____" veya "..." işaretlerini vurgulayalım
    String questionText = question['question'] as String;
    final Widget formattedQuestion =
        _buildFormattedQuestion(questionText, isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Soruyu daha öne çıkan bir formatta göster
        formattedQuestion,

        const SizedBox(height: 24),

        // Daha açıklayıcı yönlendirme
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: widget.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cümledeki boşluğa uygun kelimeyi seçin:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Seçenekleri daha kullanıcı dostu bir şekilde göster
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(options.length, (index) {
            final isSelected = _selectedOptionIndex == index;
            final isCorrect = index == correctIndex;

            Color backgroundColor;
            Color borderColor;
            Color textColor;

            if (_answered) {
              if (isCorrect) {
                backgroundColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green;
                textColor = Colors.green;
              } else if (isSelected) {
                backgroundColor = Colors.red.withOpacity(0.1);
                borderColor = Colors.red;
                textColor = Colors.red;
              } else {
                backgroundColor =
                    isDark ? const Color(0xFF303030) : Colors.white;
                borderColor =
                    isDark ? Colors.grey.shade700 : Colors.grey.shade300;
                textColor =
                    isDark ? Colors.grey.shade400 : Colors.grey.shade700;
              }
            } else {
              if (isSelected) {
                backgroundColor = widget.color.withOpacity(0.1);
                borderColor = widget.color;
                textColor = widget.color;
              } else {
                backgroundColor =
                    isDark ? const Color(0xFF303030) : Colors.white;
                borderColor =
                    isDark ? Colors.grey.shade700 : Colors.grey.shade300;
                textColor = isDark ? Colors.white : Colors.black87;
              }
            }

            return GestureDetector(
              onTap: _answered ? null : () => _selectOption(index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      options[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (_answered && isCorrect) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                    ] else if (_answered && isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 18,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),

        if (_answered) ...[
          const SizedBox(height: 24),

          // Doğru cevap gösterimi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doğru Cevap:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // Sorudaki boşluğu doğru cevapla değiştirerek tam cümleyi göster
                  _getCompletedSentence(questionText, options[correctIndex]),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Sorudaki boşlukları öne çıkaran bir widget oluştur
  Widget _buildFormattedQuestion(String questionText, bool isDark) {
    // Eğer soru metninde boşluk işaretleri (___) ya da (...) varsa, onları vurgulu göster
    if (questionText.contains('___') || questionText.contains('...')) {
      // RichText kullanarak boşlukları vurgula
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
          children: _formatBlankSpaces(questionText, isDark),
        ),
      );
    } else {
      // Normal text olarak göster
      return Text(
        questionText,
        style: TextStyle(
          fontSize: 18,
          height: 1.5,
          color: isDark ? Colors.white : Colors.black87,
        ),
      );
    }
  }

  // Boşlukları vurgulu göstermek için TextSpan listesi oluştur
  List<TextSpan> _formatBlankSpaces(String text, bool isDark) {
    final List<TextSpan> spans = [];

    // Regex ile boşlukları bul: ___, ... veya [blank] gibi formatlar
    final RegExp blankPattern =
        RegExp(r'(_{3,}|\.\.\.|___|\[blank\]|\[BLANK\]|BLANK)');
    final matches = blankPattern.allMatches(text);

    int previousEnd = 0;

    for (Match match in matches) {
      // Boşluktan önceki metni ekle
      if (match.start > previousEnd) {
        spans.add(TextSpan(
          text: text.substring(previousEnd, match.start),
        ));
      }

      // Boşluğu özel şekilde göster
      spans.add(TextSpan(
        text: ' _____ ',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: widget.color,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationThickness: 2,
        ),
      ));

      previousEnd = match.end;
    }

    // Son kalan metni ekle
    if (previousEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(previousEnd),
      ));
    }

    return spans;
  }

  // Boşluğu doldurulmuş cümleyi oluştur
  String _getCompletedSentence(String questionText, String answer) {
    final RegExp blankPattern =
        RegExp(r'(_{3,}|\.\.\.|___|\[blank\]|\[BLANK\]|BLANK)');
    return questionText.replaceFirst(blankPattern, answer);
  }

  // Eşleştirme soru widgetı (basitleştirilmiş)
  Widget _buildMatchingWidget(Map<String, dynamic> question, bool isDark) {
    final options = question['options'] as List<String>;
    return _buildMultipleChoiceWidget(
        question, isDark); // Şimdilik çoktan seçmeli ile aynı
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _checkAnswer() {
    final question = (widget.exercise['questions']
        as List<Map<String, dynamic>>)[_currentQuestionIndex];

    // correctAnswer'ın tipini kontrol edip uygun şekilde işleme
    dynamic correctAnswer = question['correctAnswer'];
    bool isCorrect = false;

    if (correctAnswer is int) {
      isCorrect = _selectedOptionIndex == correctAnswer;
    } else if (correctAnswer is String) {
      // Eğer string ise ve sayısal değerse int'e dönüştür
      if (int.tryParse(correctAnswer) != null) {
        isCorrect = _selectedOptionIndex == int.parse(correctAnswer);
      } else {
        // String olarak karşılaştır (örneğin "Doğru" gibi)
        isCorrect = _selectedOptionIndex.toString() == correctAnswer;
      }
    } else if (correctAnswer is bool) {
      // Boolean değer için: true=0, false=1 olarak kabul et
      isCorrect = _selectedOptionIndex == (correctAnswer ? 0 : 1);
    }

    setState(() {
      _answered = true;
      if (isCorrect) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedOptionIndex = null;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkmak istediğinize emin misiniz?'),
        content: const Text('İlerlemeniz kaydedilmeyecek.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Evet'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(bool isDark, int totalQuestions) {
    final percentage = (_correctAnswers / totalQuestions) * 100;
    final isPassed = percentage >= 70;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPassed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
            ),
            child: Icon(
              isPassed ? Icons.check_circle : Icons.cancel,
              color: isPassed ? Colors.green : Colors.red,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isPassed ? 'Tebrikler!' : 'Tekrar Deneyin!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isPassed ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Skorunuz: %${percentage.toInt()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_correctAnswers/$totalQuestions doğru cevap',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentQuestionIndex = 0;
                _correctAnswers = 0;
                _answered = false;
                _selectedOptionIndex = null;
                _quizCompleted = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tekrar Dene',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Ana Menüye Dön',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
