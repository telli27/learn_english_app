import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import '../models/flashcard.dart';
import '../providers/immersive_learning_provider.dart';

class ImmersiveLearningWidget extends ConsumerStatefulWidget {
  final Flashcard flashcard;
  final Function() onSessionComplete;

  const ImmersiveLearningWidget({
    Key? key,
    required this.flashcard,
    required this.onSessionComplete,
  }) : super(key: key);

  @override
  ConsumerState<ImmersiveLearningWidget> createState() =>
      _ImmersiveLearningWidgetState();
}

class _ImmersiveLearningWidgetState
    extends ConsumerState<ImmersiveLearningWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;
  bool _audioPlaying = false;
  final _pageController = PageController();
  Timer? _autoProgressTimer;
  Timer? _highlightTimer;
  List<int> _highlightedWordIndices = [];

  // For the context section
  final List<LearningContext> _contexts = [];
  int _selectedContextIndex = 0;

  // For the comprehension section
  bool _showingAnswer = false;
  bool? _userGotCorrectAnswer;
  int _correctAnswerIndex = 0;
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadContexts();

    // Start auto-progress timer for context exploration
    _startAutoProgressTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _autoProgressTimer?.cancel();
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Reset state when changing tabs
      setState(() {
        _audioPlaying = false;
        _highlightedWordIndices = [];
        _highlightTimer?.cancel();
        _autoProgressTimer?.cancel();
      });

      // If moving to context tab, restart auto-progress
      if (_tabController.index == 0) {
        _startAutoProgressTimer();
      }
    }
  }

  void _startAutoProgressTimer() {
    _autoProgressTimer?.cancel();
    _autoProgressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentStep < 5 && mounted) {
        setState(() {
          _currentStep++;
          _highlightRandomWord();
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _highlightRandomWord() {
    _highlightTimer?.cancel();
    _highlightTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          // Get context sentences
          final context = _contexts[_selectedContextIndex];
          final words = context.sentences.join(' ').split(' ');

          // Choose a random word to highlight
          if (words.isNotEmpty) {
            final randomIndex = Random().nextInt(words.length);
            _highlightedWordIndices = [randomIndex];

            // Look for target word and synonyms to highlight
            for (int i = 0; i < words.length; i++) {
              final cleanWord =
                  words[i].replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
              if (cleanWord == widget.flashcard.word.toLowerCase() ||
                  widget.flashcard.synonyms.contains(cleanWord)) {
                _highlightedWordIndices.add(i);
              }
            }
          }
        });
      }
    });
  }

  void _loadContexts() {
    final contextProvider = ref.read(immersiveContextProvider.notifier);

    // Get contexts related to the flashcard
    contextProvider.getContextsForWord(widget.flashcard.word).then((contexts) {
      if (mounted) {
        setState(() {
          _contexts.clear();
          _contexts.addAll(contexts);

          // Set up comprehension questions
          _generateComprehensionTest();
        });
      }
    });
  }

  void _generateComprehensionTest() {
    // In a real app, these would be generated based on the contexts and difficulty
    // Here we're simulating with some basic questions
    if (_contexts.isNotEmpty) {
      final context = _contexts[_selectedContextIndex];
      context.questions = [
        ComprehensionQuestion(
            question:
                'What is the meaning of "${widget.flashcard.word}" in this context?',
            options: [
              widget.flashcard.translation,
              'Wrong meaning 1',
              'Wrong meaning 2',
              'Wrong meaning 3',
            ],
            correctIndex: 0),
        ComprehensionQuestion(
            question: 'How is "${widget.flashcard.word}" used in the context?',
            options: [
              'As a noun',
              'As a verb',
              'As an adjective',
              'As an adverb'
            ],
            correctIndex: Random().nextInt(4) // Random for demo purposes
            ),
        ComprehensionQuestion(
            question:
                'Which sentence uses "${widget.flashcard.word}" correctly?',
            options: [
              context.sentences[0],
              'Wrong usage 1',
              'Wrong usage 2',
              'Wrong usage 3'
            ],
            correctIndex: 0),
      ];

      // Set initial test question
      _correctAnswerIndex = context.questions[0].correctIndex;
    }
  }

  void _checkAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
      _showingAnswer = true;
      _userGotCorrectAnswer = index == _correctAnswerIndex;
    });

    // Log progress to the provider
    if (_userGotCorrectAnswer == true) {
      ref
          .read(learningProgressProvider.notifier)
          .recordCorrectAnswer(widget.flashcard.id, widget.flashcard.word);
    }
  }

  void _nextContext() {
    setState(() {
      _selectedContextIndex = (_selectedContextIndex + 1) % _contexts.length;
      _showingAnswer = false;
      _selectedAnswerIndex = null;
      _currentStep = 0;
    });

    // Reset comprehension test for new context
    _generateComprehensionTest();

    // Reset auto-progress timer
    _startAutoProgressTimer();
  }

  void _toggleAudio() {
    setState(() {
      _audioPlaying = !_audioPlaying;
    });

    // In a real app, this would play/pause audio of the sentences being read
    if (_audioPlaying) {
      ref
          .read(immersiveContextProvider.notifier)
          .playAudio(_contexts[_selectedContextIndex].audioUrl);
    } else {
      ref.read(immersiveContextProvider.notifier).stopAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title and target word
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Otomatik Öğrenme Asistanı',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Öğrendiğiniz kelime doğal bağlamında gösterilecek, siz sadece izleyin ve dinleyin.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Hedef Kelime: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.flashcard.word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab bar for different learning modes
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black45,
            indicator: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            tabs: const [
              Tab(text: 'Bağlam'),
              Tab(text: 'Anlama'),
              Tab(text: 'İlerleme'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Context tab
              _buildContextTab(isDark, colorScheme),

              // Comprehension tab
              _buildComprehensionTab(isDark, colorScheme),

              // Progress tab
              _buildProgressTab(isDark, colorScheme),
            ],
          ),
        ),

        // Bottom buttons
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_tabController.index == 0) {
                      _nextContext();
                    } else if (_tabController.index == 1 && _showingAnswer) {
                      setState(() {
                        _showingAnswer = false;
                        _selectedAnswerIndex = null;
                        _correctAnswerIndex = _contexts[_selectedContextIndex]
                            .questions[Random().nextInt(
                                _contexts[_selectedContextIndex]
                                    .questions
                                    .length)]
                            .correctIndex;
                      });
                    } else if (_tabController.index == 2) {
                      widget.onSessionComplete();
                    }
                  },
                  icon: Icon(_tabController.index == 2
                      ? Icons.check
                      : Icons.arrow_forward),
                  label:
                      Text(_tabController.index == 2 ? 'Tamamla' : 'Sonraki'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContextTab(bool isDark, ColorScheme colorScheme) {
    if (_contexts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final context = _contexts[_selectedContextIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Context viewer
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scene/situation description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        context.situationIcon,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.situation,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Context sentences with highlighting
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: context.sentences.asMap().entries.map((entry) {
                        final index = entry.key;
                        final sentence = entry.value;
                        final words = sentence.split(' ');

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.5,
                              ),
                              children: words.asMap().entries.map((wordEntry) {
                                final wordIndex = wordEntry.key +
                                    (index * 10); // Approximate offset
                                final word = wordEntry.value;
                                final cleanWord = word
                                    .replaceAll(RegExp(r'[^\w\s]'), '')
                                    .toLowerCase();

                                bool isHighlighted =
                                    _highlightedWordIndices.contains(wordIndex);
                                bool isTargetWord = cleanWord ==
                                    widget.flashcard.word.toLowerCase();
                                bool isSynonym = widget.flashcard.synonyms
                                    .contains(cleanWord);

                                Color textColor;
                                FontWeight fontWeight;

                                if (isTargetWord) {
                                  textColor = colorScheme.primary;
                                  fontWeight = FontWeight.bold;
                                } else if (isSynonym) {
                                  textColor = Colors.orange;
                                  fontWeight = FontWeight.bold;
                                } else if (isHighlighted) {
                                  textColor =
                                      isDark ? Colors.yellow : Colors.blue;
                                  fontWeight = FontWeight.normal;
                                } else {
                                  textColor =
                                      isDark ? Colors.white : Colors.black87;
                                  fontWeight = FontWeight.normal;
                                }

                                return TextSpan(
                                  text: '$word ',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: fontWeight,
                                    backgroundColor: isHighlighted
                                        ? (isDark
                                            ? Colors.yellow.withOpacity(0.2)
                                            : Colors.yellow.withOpacity(0.2))
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <= _currentStep
                            ? colorScheme.primary
                            : (isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Audio control
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleAudio,
                      icon:
                          Icon(_audioPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_audioPlaying ? 'Sesi Durdur' : 'Sesi Çal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComprehensionTab(bool isDark, ColorScheme colorScheme) {
    if (_contexts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final context = _contexts[_selectedContextIndex];
    if (context.questions.isEmpty) {
      return Center(
        child: Text(
          'Sorular yüklenemedi',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    final currentQuestion =
        context.questions[0]; // Use first question for simplicity

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Anlama Testi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentQuestion.question,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Answer options
          Expanded(
            child: ListView.builder(
              itemCount: currentQuestion.options.length,
              itemBuilder: (context, index) {
                final option = currentQuestion.options[index];

                // Determine styling based on selection and correctness
                Color borderColor;
                Color fillColor;
                IconData? trailingIcon;

                if (_showingAnswer) {
                  if (index == _correctAnswerIndex) {
                    borderColor = Colors.green;
                    fillColor = Colors.green.withOpacity(0.1);
                    trailingIcon = Icons.check_circle;
                  } else if (index == _selectedAnswerIndex) {
                    borderColor = Colors.red;
                    fillColor = Colors.red.withOpacity(0.1);
                    trailingIcon = Icons.cancel;
                  } else {
                    borderColor =
                        isDark ? Colors.grey.shade700 : Colors.grey.shade300;
                    fillColor = Colors.transparent;
                    trailingIcon = null;
                  }
                } else {
                  borderColor =
                      isDark ? Colors.grey.shade700 : Colors.grey.shade300;
                  fillColor = _selectedAnswerIndex == index
                      ? colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent;
                  trailingIcon = _selectedAnswerIndex == index
                      ? Icons.check_circle_outline
                      : null;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: _showingAnswer ? null : () => _checkAnswer(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (trailingIcon != null)
                            Icon(
                              trailingIcon,
                              color: index == _correctAnswerIndex
                                  ? Colors.green
                                  : Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Feedback when answer is shown
          if (_showingAnswer)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _userGotCorrectAnswer == true
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _userGotCorrectAnswer == true
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
                        _userGotCorrectAnswer == true
                            ? Icons.check_circle
                            : Icons.error,
                        color: _userGotCorrectAnswer == true
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _userGotCorrectAnswer == true ? 'Doğru!' : 'Yanlış!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _userGotCorrectAnswer == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userGotCorrectAnswer == true
                        ? 'Tebrikler! Doğru cevabı verdiniz.'
                        : 'Doğru cevap: ${currentQuestion.options[_correctAnswerIndex]}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(bool isDark, ColorScheme colorScheme) {
    return Consumer(
      builder: (context, ref, child) {
        final progressAsync = ref.watch(learningProgressProvider);

        return progressAsync.when(
          data: (progress) {
            final wordProgress =
                progress.wordProgress[widget.flashcard.word] ?? 0;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Öğrenme İlerlemesi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Word mastery progress
                  Row(
                    children: [
                      Text(
                        '"${widget.flashcard.word}" kelimesinin öğrenilme düzeyi:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: wordProgress / 100,
                      backgroundColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        HSLColor.fromColor(colorScheme.primary)
                            .withLightness(wordProgress / 200 + 0.4)
                            .toColor(),
                      ),
                      minHeight: 20,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '%${wordProgress.toInt()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Word learning stages
                  Column(
                    children: [
                      _buildLearningStage(
                        isDark,
                        colorScheme,
                        'Tanıma',
                        'Kelimeyi gördüğünüzde tanıyabilirsiniz',
                        wordProgress >= 20 ? 1.0 : wordProgress / 20,
                        Icons.visibility,
                        wordProgress >= 20,
                      ),
                      _buildLearningStage(
                        isDark,
                        colorScheme,
                        'Anlama',
                        'Kelimenin anlamını bilirsiniz',
                        wordProgress >= 40 ? 1.0 : (wordProgress - 20) / 20,
                        Icons.psychology,
                        wordProgress >= 40,
                      ),
                      _buildLearningStage(
                        isDark,
                        colorScheme,
                        'Bağlamda Kullanım',
                        'Kelimeyi doğru bağlamda kullanabilirsiniz',
                        wordProgress >= 60 ? 1.0 : (wordProgress - 40) / 20,
                        Icons.text_fields,
                        wordProgress >= 60,
                      ),
                      _buildLearningStage(
                        isDark,
                        colorScheme,
                        'Akıcı Kullanım',
                        'Kelimeyi doğal bir şekilde kullanabilirsiniz',
                        wordProgress >= 80 ? 1.0 : (wordProgress - 60) / 20,
                        Icons.auto_stories,
                        wordProgress >= 80,
                      ),
                      _buildLearningStage(
                        isDark,
                        colorScheme,
                        'Tam Hakimiyet',
                        'Kelimeye tamamen hakimsiniz',
                        wordProgress >= 100 ? 1.0 : (wordProgress - 80) / 20,
                        Icons.star,
                        wordProgress >= 100,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Overall vocabulary stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800.withOpacity(0.5)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genel İstatistikler',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Toplam Kelime',
                              '${progress.totalWords}',
                              Icons.menu_book,
                              colorScheme.primary,
                            ),
                            _buildStatItem(
                              'Öğrenilen',
                              '${progress.masteredWords}',
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildStatItem(
                              'Öğrenme Oranı',
                              '%${((progress.masteredWords / max(1, progress.totalWords)) * 100).toInt()}',
                              Icons.trending_up,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text(
              'İlerleme bilgileri yüklenemedi',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearningStage(
    bool isDark,
    ColorScheme colorScheme,
    String title,
    String description,
    double progress,
    IconData icon,
    bool completed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: completed
                  ? colorScheme.primary
                  : isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: completed
                  ? Colors.white
                  : isDark
                      ? Colors.white54
                      : Colors.black45,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: completed
                            ? colorScheme.primary
                            : isDark
                                ? Colors.white70
                                : Colors.black87,
                      ),
                    ),
                    if (completed)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor:
                        isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completed ? Colors.green : colorScheme.primary,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
      ],
    );
  }
}
