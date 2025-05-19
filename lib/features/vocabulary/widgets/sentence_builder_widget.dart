import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import 'dart:math';

class SentenceBuilderWidget extends ConsumerStatefulWidget {
  final Flashcard flashcard;
  final Function(int score) onComplete;

  const SentenceBuilderWidget({
    Key? key,
    required this.flashcard,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<SentenceBuilderWidget> createState() =>
      _SentenceBuilderWidgetState();
}

class _SentenceBuilderWidgetState extends ConsumerState<SentenceBuilderWidget> {
  bool _isCompleted = false;
  String _userSentence = '';
  String _feedback = '';
  int _score = 0;
  final List<String> _wordBank = [];
  final List<String> _selectedWords = [];

  // List of example contexts/sentence starters based on word difficulty
  final Map<String, List<String>> _contextStarters = {
    'Beginner': [
      'I want to...',
      'Yesterday, I...',
      'Can you please...',
      'I need to...',
      'Every day, I...',
    ],
    'Intermediate': [
      'Although it was difficult,...',
      'Despite the challenges,...',
      'If I had the opportunity, I would...',
      'The reason why I...',
      'Not only..., but also...',
    ],
    'Advanced': [
      'Having considered all the alternatives,...',
      'Contrary to popular belief,...',
      'In light of recent developments,...',
      'Notwithstanding the previous agreement,...',
      'The extent to which... determines...',
    ],
  };

  late String _contextStarter;
  String _targetSentencePattern = '';

  @override
  void initState() {
    super.initState();
    _initializeExercise();
  }

  void _initializeExercise() {
    // Select a random context starter based on difficulty
    final starters = _contextStarters[widget.flashcard.difficulty] ??
        _contextStarters['Beginner']!;
    _contextStarter = starters[Random().nextInt(starters.length)];

    // Create word bank from the target word, synonyms, and additional words
    _wordBank.add(widget.flashcard.word);
    _wordBank.addAll(widget.flashcard.synonyms.take(2));

    // Add some connecting words based on difficulty
    final connecting = _getConnectingWords(widget.flashcard.difficulty);
    _wordBank.addAll(connecting.take(5));

    // Add some distractor words
    final distractors = _getDistractorWords(widget.flashcard.difficulty);
    _wordBank.addAll(distractors.take(4));

    // Shuffle the word bank
    _wordBank.shuffle();

    // Create a target sentence pattern to evaluate against
    _createTargetSentencePattern();
  }

  List<String> _getConnectingWords(String difficulty) {
    if (difficulty == 'Beginner') {
      return [
        'and',
        'but',
        'so',
        'or',
        'because',
        'with',
        'to',
        'for',
        'in',
        'on'
      ];
    } else if (difficulty == 'Intermediate') {
      return [
        'however',
        'therefore',
        'although',
        'since',
        'while',
        'unless',
        'despite',
        'moreover',
        'furthermore',
        'consequently'
      ];
    } else {
      return [
        'nevertheless',
        'nonetheless',
        'accordingly',
        'subsequently',
        'alternatively',
        'conversely',
        'henceforth',
        'notwithstanding',
        'whereby',
        'wherein'
      ];
    }
  }

  List<String> _getDistractorWords(String difficulty) {
    if (difficulty == 'Beginner') {
      return [
        'happy',
        'sad',
        'big',
        'small',
        'fast',
        'slow',
        'good',
        'bad',
        'hot',
        'cold'
      ];
    } else if (difficulty == 'Intermediate') {
      return [
        'efficient',
        'sustainable',
        'relevant',
        'crucial',
        'significant',
        'innovative',
        'essential',
        'comprehensive',
        'potential',
        'strategic'
      ];
    } else {
      return [
        'ambiguous',
        'paradigm',
        'meticulous',
        'unprecedented',
        'ubiquitous',
        'intrinsic',
        'pragmatic',
        'esoteric',
        'ambivalent',
        'clandestine'
      ];
    }
  }

  void _createTargetSentencePattern() {
    // This is a simple pattern to check if the sentence contains the target word
    // and has a reasonable structure. In a real app, this would be more sophisticated.
    _targetSentencePattern =
        r'.*\b' + widget.flashcard.word.toLowerCase() + r'\b.*';
  }

  void _selectWord(String word) {
    if (!_isCompleted) {
      setState(() {
        _selectedWords.add(word);
        _wordBank.remove(word);
        _userSentence = _contextStarter + ' ' + _selectedWords.join(' ');
      });
    }
  }

  void _removeWord(int index) {
    if (!_isCompleted) {
      setState(() {
        final removedWord = _selectedWords.removeAt(index);
        _wordBank.add(removedWord);
        _userSentence = _contextStarter + ' ' + _selectedWords.join(' ');
      });
    }
  }

  void _checkSentence() {
    if (_selectedWords.isEmpty) {
      setState(() {
        _feedback = 'Lütfen bir cümle oluşturmak için kelimeler seçin.';
      });
      return;
    }

    // Check if the sentence contains the target word
    final RegExp targetWordPattern = RegExp(
        r'\b' + widget.flashcard.word.toLowerCase() + r'\b',
        caseSensitive: false);
    final containsTargetWord =
        targetWordPattern.hasMatch(_userSentence.toLowerCase());

    if (!containsTargetWord) {
      setState(() {
        _feedback =
            '"${widget.flashcard.word}" kelimesini cümlenizde kullanmalısınız.';
      });
      return;
    }

    // Check if the sentence has a reasonable length
    if (_selectedWords.length < 3) {
      setState(() {
        _feedback = 'Lütfen daha uzun bir cümle oluşturun (en az 3 kelime).';
      });
      return;
    }

    // Evaluate the sentence quality (this is a simplified version)
    int score = 0;

    // Base score for using the target word
    score += 5;

    // Additional points for using synonyms
    for (final synonym in widget.flashcard.synonyms) {
      if (RegExp(r'\b' + synonym.toLowerCase() + r'\b', caseSensitive: false)
          .hasMatch(_userSentence.toLowerCase())) {
        score += 3;
      }
    }

    // Points for sentence length (up to a point)
    score += min(_selectedWords.length, 10);

    // Normalize score to a max of 10
    _score = min(score, 10);

    setState(() {
      _isCompleted = true;
      _feedback = _score >= 7
          ? 'Harika! Mükemmel bir cümle oluşturdunuz.'
          : _score >= 5
              ? 'İyi iş! Cümleniz doğru, ancak biraz daha geliştirilebilir.'
              : 'İyi başlangıç. Daha karmaşık bir cümle için çalışmaya devam edin.';
    });

    // Notify parent
    widget.onComplete(_score);
  }

  void _reset() {
    setState(() {
      _isCompleted = false;
      _userSentence = '';
      _feedback = '';
      _score = 0;
      _wordBank.clear();
      _selectedWords.clear();
      _initializeExercise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cümle Oluşturucu',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Aşağıdaki kelimelerden bazılarını kullanarak "${widget.flashcard.word}" kelimesini içeren anlamlı bir cümle oluşturun.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Target word info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.indigo.shade900 : Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.indigo.shade700 : Colors.indigo.shade200,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Hedef Kelime: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.indigo.shade700,
                  ),
                ),
                Text(
                  widget.flashcard.word,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${widget.flashcard.translation})',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sentence construction area
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cümleniz:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                constraints: const BoxConstraints(
                  minHeight: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contextStarter,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_selectedWords.length, (index) {
                        return InkWell(
                          onTap: () => _removeWord(index),
                          child: Chip(
                            label: Text(_selectedWords[index]),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 16,
                            ),
                            onDeleted: () => _removeWord(index),
                            backgroundColor:
                                _selectedWords[index].toLowerCase() ==
                                        widget.flashcard.word.toLowerCase()
                                    ? primaryColor.withOpacity(0.2)
                                    : isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade200,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Word bank
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelime Bankası:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _wordBank.map((word) {
                    final isTargetWord = word.toLowerCase() ==
                        widget.flashcard.word.toLowerCase();
                    final isSynonym = widget.flashcard.synonyms
                        .map((s) => s.toLowerCase())
                        .contains(word.toLowerCase());

                    return ActionChip(
                      label: Text(word),
                      onPressed: () => _selectWord(word),
                      backgroundColor: isTargetWord
                          ? primaryColor.withOpacity(0.2)
                          : isSynonym
                              ? Colors.amber.withOpacity(0.2)
                              : isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isTargetWord
                            ? primaryColor
                            : isSynonym
                                ? Colors.amber.shade800
                                : isDark
                                    ? Colors.white
                                    : Colors.black87,
                        fontWeight: isTargetWord || isSynonym
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Feedback area
          if (_feedback.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCompleted
                    ? (_score >= 7
                        ? Colors.green.withOpacity(0.1)
                        : _score >= 5
                            ? Colors.amber.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1))
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isCompleted
                      ? (_score >= 7
                          ? Colors.green.withOpacity(0.3)
                          : _score >= 5
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3))
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isCompleted
                            ? (_score >= 7
                                ? Icons.check_circle
                                : _score >= 5
                                    ? Icons.thumb_up
                                    : Icons.info)
                            : Icons.warning,
                        color: _isCompleted
                            ? (_score >= 7
                                ? Colors.green
                                : _score >= 5
                                    ? Colors.amber
                                    : Colors.orange)
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCompleted ? 'Geri Bildirim' : 'Dikkat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isCompleted
                              ? (_score >= 7
                                  ? Colors.green
                                  : _score >= 5
                                      ? Colors.amber
                                      : Colors.orange)
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _feedback,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (_isCompleted) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Puan: $_score/10',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
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
                child: ElevatedButton.icon(
                  onPressed: _isCompleted ? _reset : _checkSentence,
                  icon: Icon(_isCompleted ? Icons.refresh : Icons.check),
                  label:
                      Text(_isCompleted ? 'Yeni Cümle' : 'Cümleyi Kontrol Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
