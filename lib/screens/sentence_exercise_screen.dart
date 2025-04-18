import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SentenceExerciseScreen extends StatefulWidget {
  final String topic;
  final Color color;

  const SentenceExerciseScreen({
    Key? key,
    required this.topic,
    required this.color,
  }) : super(key: key);

  @override
  State<SentenceExerciseScreen> createState() => _SentenceExerciseScreenState();
}

class _SentenceExerciseScreenState extends State<SentenceExerciseScreen> {
  int _currentExerciseIndex = 0;
  List<String> _selectedWords = [];
  List<int> _selectedIndices = [];
  bool _showResult = false;
  bool _isCorrect = false;
  bool _showExplanation = true;

  // Topic grammar explanations
  final Map<String, String> _grammarExplanations = {
    'Present Simple':
        'Geniş zaman (Present Simple), düzenli olarak yaptığımız işleri, alışkanlıkları veya genel gerçekleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + Fiil (3. tekil şahısta -s eklenir)\n'
            '• Olumsuz cümle: Özne + do/does + not + Fiil\n'
            '• Soru cümlesi: Do/Does + Özne + Fiil',
    'Present Continuous':
        'Şimdiki zaman (Present Continuous), şu anda gerçekleşen veya yakın gelecekte planlanan eylemleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + am/is/are + Fiil-ing\n'
            '• Olumsuz cümle: Özne + am/is/are + not + Fiil-ing\n'
            '• Soru cümlesi: Am/Is/Are + Özne + Fiil-ing',
    'Past Simple':
        'Geçmiş zaman (Past Simple), geçmişte belirli bir zamanda tamamlanmış eylemleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + Fiil-ed/2. hali\n'
            '• Olumsuz cümle: Özne + did + not + Fiil\n'
            '• Soru cümlesi: Did + Özne + Fiil',
    'Future Tense':
        'Gelecek zaman (Future Tense), gelecekte gerçekleşecek planları veya tahminleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + will/be going to + Fiil\n'
            '• Olumsuz cümle: Özne + will/be going to + not + Fiil\n'
            '• Soru cümlesi: Will/Be going to + Özne + Fiil',
    'Question Forms':
        'İngilizce\'de soru cümleleri oluşturmak için genellikle yardımcı fiiller kullanılır.\n\n'
            '• Yes/No soruları: Yardımcı fiil + Özne + Ana fiil\n'
            '• Wh- soruları: Soru kelimesi + Yardımcı fiil + Özne + Ana fiil\n'
            '• Subject questions: Soru kelimesi (who/what) + fiil',
    'Passive Voice':
        'Pasif yapı (Passive Voice), öznenin eylemi gerçekleştiren değil, eylemden etkilenen olduğu durumlarda kullanılır.\n\n'
            '• Yapı: Özne (nesne) + to be + past participle (3. hali) + by + fail (isteğe bağlı)\n'
            '• Zamanlar pasif yapıda to be fiilinin çekimiyle gösterilir',
  };

  // Exercise data for each topic
  final Map<String, List<Map<String, dynamic>>> _exercises = {
    'Present Simple': [
      {
        'words': ['she', 'coffee', 'drinks', 'every', 'morning'],
        'correctSentence': 'she drinks coffee every morning',
        'type': 'Olumlu Cümle',
        'meaning': 'O her sabah kahve içer.',
      },
      {
        'words': ['do', 'like', 'you', 'pizza'],
        'correctSentence': 'do you like pizza',
        'type': 'Soru Cümlesi',
        'meaning': 'Pizza sever misin?',
      },
      {
        'words': ['they', 'to', 'school', 'walk', 'usually'],
        'correctSentence': 'they usually walk to school',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar genellikle okula yürüyerek giderler.',
      },
    ],
    'Present Continuous': [
      {
        'words': ['is', 'now', 'raining', 'it'],
        'correctSentence': 'it is raining now',
        'type': 'Olumlu Cümle',
        'meaning': 'Şu anda yağmur yağıyor.',
      },
      {
        'words': ['are', 'what', 'doing', 'you'],
        'correctSentence': 'what are you doing',
        'type': 'Soru Cümlesi',
        'meaning': 'Ne yapıyorsun?',
      },
      {
        'words': ['she', 'is', 'for', 'studying', 'exam', 'the'],
        'correctSentence': 'she is studying for the exam',
        'type': 'Olumlu Cümle',
        'meaning': 'O, sınav için çalışıyor.',
      },
    ],
    'Past Simple': [
      {
        'words': ['visited', 'museum', 'they', 'the', 'yesterday'],
        'correctSentence': 'they visited the museum yesterday',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar dün müzeyi ziyaret ettiler.',
      },
      {
        'words': ['did', 'last', 'weekend', 'what', 'you', 'do'],
        'correctSentence': 'what did you do last weekend',
        'type': 'Soru Cümlesi',
        'meaning': 'Geçen hafta sonu ne yaptın?',
      },
      {
        'words': ['not', 'did', 'the', 'I', 'finish', 'book'],
        'correctSentence': 'I did not finish the book',
        'type': 'Olumsuz Cümle',
        'meaning': 'Kitabı bitirmedim.',
      },
    ],
    'Future Tense': [
      {
        'words': ['will', 'tomorrow', 'rain', 'it'],
        'correctSentence': 'it will rain tomorrow',
        'type': 'Olumlu Cümle',
        'meaning': 'Yarın yağmur yağacak.',
      },
      {
        'words': ['going', 'are', 'to', 'university', 'you', 'attend'],
        'correctSentence': 'are you going to attend university',
        'type': 'Soru Cümlesi',
        'meaning': 'Üniversiteye gitmeyi düşünüyor musun?',
      },
      {
        'words': ['will', 'dinner', 'cook', 'she', 'tonight'],
        'correctSentence': 'she will cook dinner tonight',
        'type': 'Olumlu Cümle',
        'meaning': 'O bu akşam yemek pişirecek.',
      },
    ],
    'Question Forms': [
      {
        'words': ['do', 'where', 'live', 'you'],
        'correctSentence': 'where do you live',
        'type': 'Soru Cümlesi (Wh-)',
        'meaning': 'Nerede yaşıyorsun?',
      },
      {
        'words': ['is', 'favorite', 'your', 'what', 'color'],
        'correctSentence': 'what is your favorite color',
        'type': 'Soru Cümlesi (Wh-)',
        'meaning': 'En sevdiğin renk nedir?',
      },
      {
        'words': ['how', 'are', 'old', 'you'],
        'correctSentence': 'how old are you',
        'type': 'Soru Cümlesi (Wh-)',
        'meaning': 'Kaç yaşındasın?',
      },
    ],
    'Passive Voice': [
      {
        'words': ['book', 'was', 'the', 'by', 'written', 'her'],
        'correctSentence': 'the book was written by her',
        'type': 'Pasif Yapı',
        'meaning': 'Kitap onun tarafından yazıldı.',
      },
      {
        'words': ['English', 'in', 'spoken', 'is', 'many', 'countries'],
        'correctSentence': 'English is spoken in many countries',
        'type': 'Pasif Yapı',
        'meaning': 'İngilizce birçok ülkede konuşulur.',
      },
      {
        'words': ['been', 'has', 'car', 'the', 'fixed'],
        'correctSentence': 'the car has been fixed',
        'type': 'Pasif Yapı',
        'meaning': 'Araba tamir edildi.',
      },
    ],
  };

  void _selectWord(int index, String word) {
    setState(() {
      if (!_selectedIndices.contains(index)) {
        _selectedWords.add(word);
        _selectedIndices.add(index);
      }
    });
  }

  void _removeWord(int index) {
    setState(() {
      _selectedWords.removeAt(index);
      _selectedIndices.removeAt(index);
    });
  }

  void _checkAnswer() {
    final currentExercise = _exercises[widget.topic]![_currentExerciseIndex];
    final correctSentence = currentExercise['correctSentence'];
    final userSentence = _selectedWords.join(' ');

    setState(() {
      _showResult = true;
      _isCorrect = userSentence == correctSentence;
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _exercises[widget.topic]!.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _resetExercise();
      });
    } else {
      // All exercises completed
      Navigator.pop(context);
    }
  }

  void _resetExercise() {
    setState(() {
      _selectedWords = [];
      _selectedIndices = [];
      _showResult = false;
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final currentExercise = _exercises[widget.topic]![_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topic,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Grammar explanation card (collapsible)
                      if (_showExplanation)
                        Card(
                          margin: const EdgeInsets.all(16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color:
                              isDark ? const Color(0xFF242424) : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gramer Bilgisi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: widget.color,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _showExplanation = false;
                                        });
                                      },
                                      color: isDark
                                          ? Colors.grey
                                          : Colors.grey.shade700,
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _grammarExplanations[widget.topic] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Exercise info (sentence type)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${currentExercise['type']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: widget.color,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Alıştırma ${_currentExerciseIndex + 1}/${_exercises[widget.topic]!.length}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            if (!_showExplanation)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showExplanation = true;
                                  });
                                },
                                icon: const Icon(Icons.info_outline, size: 16),
                                label: const Text('Gramer',
                                    style: TextStyle(fontSize: 13)),
                                style: TextButton.styleFrom(
                                  foregroundColor: widget.color,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Selected words area
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showResult
                                ? (_isCorrect ? Colors.green : Colors.red)
                                : isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        constraints: const BoxConstraints(minHeight: 80),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cümleniz:',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDark ? Colors.grey : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  List.generate(_selectedWords.length, (index) {
                                return InkWell(
                                  onTap: () => _removeWord(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: widget.color.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _selectedWords[index],
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.close,
                                          size: 14,
                                          color: isDark
                                              ? Colors.grey
                                              : Colors.grey.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_showResult)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _isCorrect
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: _isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isCorrect
                                              ? 'Doğru! Harika iş.'
                                              : 'Yanlış. Tekrar deneyin.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_isCorrect)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Anlam:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${currentExercise['meaning']}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (!_isCorrect)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Doğru cümle:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${currentExercise['correctSentence']}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Anlam:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${currentExercise['meaning']}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Words to select
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: !_showResult
                            ? Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: isDark
                                    ? const Color(0xFF242424)
                                    : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Kelimeleri seçerek cümle oluşturun:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color:
                                                  widget.color.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: widget.color
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '${currentExercise['type']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: widget.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: List.generate(
                                          currentExercise['words'].length,
                                          (index) {
                                            final word =
                                                currentExercise['words'][index];
                                            final isSelected = _selectedIndices
                                                .contains(index);

                                            return InkWell(
                                              onTap: isSelected
                                                  ? null
                                                  : () =>
                                                      _selectWord(index, word),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.grey
                                                          .withOpacity(0.5)
                                                      : widget.color
                                                          .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.grey
                                                            .withOpacity(0.7)
                                                        : widget.color
                                                            .withOpacity(0.5),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  word,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: isSelected
                                                        ? FontWeight.normal
                                                        : FontWeight.bold,
                                                    color: isSelected
                                                        ? (isDark
                                                            ? Colors.grey[350]
                                                            : Colors.grey[700])
                                                        : isDark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Add bottom padding for scrolling
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // Bottom buttons - keep outside scrollview
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _showResult
                            ? ElevatedButton.icon(
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text(
                                  'Devam Et',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: _nextExercise,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _selectedWords.isEmpty
                                    ? null
                                    : _checkAnswer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.color,
                                  disabledBackgroundColor:
                                      widget.color.withOpacity(0.3),
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Kontrol Et',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
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
    );
  }
}
