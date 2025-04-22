import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grammar_topic.dart';
import '../utils/constants/colors.dart';
import '../providers/theme_provider.dart';
import '../screens/exercise_detail_screen.dart';

class SubtopicDetailScreen extends ConsumerStatefulWidget {
  final GrammarTopic topic;
  final GrammarSubtopic subtopic;

  const SubtopicDetailScreen({
    Key? key,
    required this.topic,
    required this.subtopic,
  }) : super(key: key);

  @override
  ConsumerState<SubtopicDetailScreen> createState() =>
      _SubtopicDetailScreenState();
}

class _SubtopicDetailScreenState extends ConsumerState<SubtopicDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color topicColor = AppColors.getColorByName(widget.topic.color);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              backgroundColor: topicColor,
              foregroundColor: Colors.white,
              elevation: 0,
              title: _showAppBarTitle
                  ? Text(
                      widget.subtopic.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18),
                    )
                  : null,
              leadingWidth: 56,
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left_outlined,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.bookmark_outline_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(topicColor),
              ),
            ),
          ];
        },
        body: _buildContent(topicColor),
      ),
    );
  }

  Widget _buildHeader(Color topicColor) {
    final isDark = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: topicColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            topicColor,
            topicColor.withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: 0,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white.withOpacity(0.9),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.topic.title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: MediaQuery.of(context).size.width - 48,
                child: Text(
                  widget.subtopic.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildHeaderBadge(Icons.format_quote_rounded,
                      '${widget.subtopic.examples.length} örnek'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color topicColor) {
    final isDark = ref.watch(themeProvider);

    return Container(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: CustomScrollView(
        slivers: [
          // 1. Konu Açıklaması
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242424) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: topicColor.withOpacity(isDark ? 0.4 : 0.15),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: topicColor.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: topicColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Konu Özeti',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.subtopic.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Gramer Yapısı ve Kuralları (Yeni Bölüm)
          if (widget.subtopic.grammar_structure.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242424) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple,
                            Colors.deepPurple.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.architecture,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Gramer Yapısı ve Kuralları',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildFormattedGrammarStructure(
                          widget.subtopic.grammar_structure,
                          isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Örnek Cümleler
          if (widget.subtopic.examples.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242424) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.secondary,
                            AppColors.secondary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.format_quote,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Example Sentences',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.subtopic.examples.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.subtopic.examples
                            .asMap()
                            .entries
                            .map((entry) {
                          return _buildExampleItem(
                              entry.value, isDark, topicColor, entry.key);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Nasıl Öğrenilir?
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242424) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          topicColor,
                          topicColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'How to Learn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildLearningGuideSteps(isDark, topicColor),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Alıştırmalar
          if (widget.subtopic.exercises != null &&
              (widget.subtopic.exercises?.isNotEmpty ?? false))
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242424) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.orange,
                            Colors.orange.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.assignment,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Exercises',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.subtopic.exercises?.length ?? 0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Practice with exercises to master the ${widget.subtopic.title} topic:',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseDetailScreen(
                                    title: widget.subtopic.title,
                                    level: 'Intermediate',
                                    color: AppColors.getColorByName(
                                        widget.topic.color),
                                    exercises: _createExercisesFromSubtopic(
                                        widget.subtopic),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_circle_outline),
                                SizedBox(width: 8),
                                Text(
                                  'Start Exercises',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
            ),
        ],
      ),
    );
  }

  List<Widget> _buildLearningGuideSteps(bool isDark, Color topicColor) {
    final List<String> steps = [
      'First read the rules and try to understand them.',
      'Practice by repeating example sentences aloud.',
      'Compare English sentences with their Turkish meanings.',
      'Try to create similar sentences on your own.',
    ];

    return steps.asMap().entries.map((entry) {
      final int index = entry.key;
      final String step = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: topicColor.withOpacity(isDark ? 0.3 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: topicColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildExampleItem(
      String example, bool isDark, Color topicColor, int index) {
    // İlk parantez içindeki Türkçe kısmını ve İngilizce kısmını ayıralım
    String turkishExample = '';
    String englishExample = '';

    // Örnek genellikle "İngilizce → Türkçe" formatında olacaktır
    if (example.contains('→')) {
      final parts = example.split('→');
      englishExample = parts[0].trim();
      turkishExample = parts[1].trim();
    } else if (example.contains('(') && example.contains(')')) {
      // Veya "İngilizce (Türkçe)" formatında olabilir
      final regex = RegExp(r'^(.*)\s*\((.*)\)');
      final match = regex.firstMatch(example);
      if (match != null) {
        englishExample = match.group(1)?.trim() ?? '';
        turkishExample = match.group(2)?.trim() ?? '';
      } else {
        // Eğer hiçbir format tanınmazsa, tamamını bir örnek olarak kullan
        englishExample = example;
      }
    } else {
      englishExample = example;
    }

    final colors = [
      const Color(0xFF6A81EC), // Mavi
      const Color(0xFFFF8A65), // Turuncu
      const Color(0xFF66BB6A), // Yeşil
      const Color(0xFFBA68C8), // Mor
      const Color(0xFFFFB74D), // Amber
      const Color(0xFF4FC3F7), // Açık mavi
    ];
    final color = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242424) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Example ${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Sesli okuma işlevselliği buraya eklenebilir
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        size: 18,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? color.withOpacity(0.07)
                      : color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(isDark ? 0.3 : 0.2),
                  ),
                ),
                child: Text(
                  englishExample,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              if (turkishExample.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A1A)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Turkish Translation:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        turkishExample,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          color: isDark
                              ? Colors.white.withOpacity(0.9)
                              : AppColors.textPrimary.withOpacity(0.9),
                          fontFamily: null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormattedGrammarStructure(String structure, bool isDark) {
    // Satırları bölelim
    final lines = structure.split('\n');
    final List<Widget> widgets = [];

    for (String line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Başlık kontrolü
      if (line.contains(':') &&
          !line.contains(':') &&
          !line.contains('\":\"')) {
        final parts = line.split(':');
        if (parts.length >= 2 && parts[0].trim().length < 30) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                parts[0].trim() + ':',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          );
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                parts.sublist(1).join(':').trim(),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
          continue;
        }
      }

      // Rakamla başlayan maddeleri formatlayalım
      if (RegExp(r'^\d+\.').hasMatch(line)) {
        final match = RegExp(r'^(\d+\.)(.*)$').firstMatch(line);
        if (match != null) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.group(1) ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.group(2)?.trim() ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          continue;
        }
      }

      // Normal metin
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            line,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  List<Map<String, dynamic>> _createExercisesFromSubtopic(
      GrammarSubtopic subtopic) {
    // Alıştırma verilerini oluşturan metod
    final exercises = <Map<String, dynamic>>[];

    if (subtopic.exercises != null && subtopic.exercises!.isNotEmpty) {
      // Her alıştırmayı bir Map'e dönüştürüyoruz
      for (int i = 0; i < subtopic.exercises!.length; i++) {
        final exercise = subtopic.exercises![i];

        // Soru tipini belirle
        final questionType = _getQuestionTypeForExercise(exercise, i);

        // Tip belirlendikten sonra soruyu formatlayalım
        String formattedQuestion =
            _formatQuestionBasedOnType(exercise, questionType);

        // Seçenekleri ve doğru cevabı belirle
        final options = _getOptionsForExercise(formattedQuestion, questionType);
        final correctAnswer =
            _getCorrectAnswerForExercise(options, questionType);

        exercises.add({
          'id': i.toString(),
          'title': 'Alıştırma ${i + 1}',
          'description': subtopic.title,
          'level': 'Başlangıç',
          'estimatedTime': '3',
          'completed': false,
          'progress': 0.0,
          'questions': [
            {
              'id': '1',
              'type': questionType,
              'question': formattedQuestion,
              'options': options,
              'correctAnswer': correctAnswer,
              'hint': _getHintForExercise(formattedQuestion, questionType),
              'explanation': _getExplanationForExercise(
                  formattedQuestion, questionType, correctAnswer, options),
            }
          ],
        });
      }
    } else {
      // Örnek alıştırma
      exercises.add({
        'id': '1',
        'title': 'Temel Alıştırma',
        'description': '${subtopic.title} için temel kavramlar',
        'level': 'Başlangıç',
        'estimatedTime': '5',
        'completed': false,
        'progress': 0.0,
        'questions': [
          {
            'id': '1',
            'type': 'multiple_choice',
            'question': 'Bu bir örnek sorudur',
            'options': ['Cevap 1', 'Cevap 2', 'Cevap 3'],
            'correctAnswer': 0,
            'explanation': 'Doğru cevap: Cevap 1'
          }
        ],
      });
    }

    return exercises;
  }

  // İçeriğe göre uygun soru tipi belirleme
  String _getQuestionTypeForExercise(String exercise, int index) {
    // Cümlede boşluk işaretleri veya "boşluk doldurun" ifadesi varsa boşluk doldurma tipi
    if (exercise.contains('___') ||
        exercise.contains('...') ||
        exercise.contains('boşluk') ||
        exercise.contains('doldurun') ||
        exercise.toLowerCase().contains('fill in')) {
      return 'fill_in_the_blank';
    }

    // Doğru/yanlış sorularını tespit et
    if (exercise.toLowerCase().contains('doğru mu') ||
        exercise.toLowerCase().contains('yanlış mı') ||
        exercise.toLowerCase().contains('true or false')) {
      return 'true_false';
    }

    // Diğer durumlarda, çoktan seçmeli
    return 'multiple_choice';
  }

  // Soru metnini soru tipine göre formatla
  String _formatQuestionBasedOnType(String exercise, String questionType) {
    if (questionType == 'fill_in_the_blank') {
      // Eğer metinde zaten boşluk işareti yoksa, otomatik olarak ekleyelim
      if (!exercise.contains('___') && !exercise.contains('...')) {
        // Cümleyi kelimelere ayır
        final words = exercise.split(' ');
        if (words.length > 5) {
          // Cümlenin ortasına yakın bir kelimeyi boşlukla değiştir
          final replaceIndex = words.length ~/ 2;
          words[replaceIndex] = '___';
          return words.join(' ');
        } else {
          // Kısa cümleler için sona boşluk ekle
          return exercise + ' ___';
        }
      }
    }

    return exercise;
  }

  // Soru tipi için uygun seçenekler oluşturma
  List<String> _getOptionsForExercise(String exercise, String questionType) {
    switch (questionType) {
      case 'true_false':
        return ['Doğru', 'Yanlış'];

      case 'fill_in_the_blank':
        // Boşluk doldurma için daha uygun seçenekler
        final exerciseLower = exercise.toLowerCase();

        // Geçmiş zaman soruları için
        if (exerciseLower.contains('went') ||
            exerciseLower.contains('did') ||
            exerciseLower.contains('was') ||
            exerciseLower.contains('were')) {
          return ['was', 'were', 'went', 'did'];
        }

        // Modal yardımcı fiiller için
        else if (exerciseLower.contains('can') ||
            exerciseLower.contains('could') ||
            exerciseLower.contains('may')) {
          return ['can', 'could', 'may', 'might'];
        }

        // To be fiilleri için
        else if (exerciseLower.contains('am') ||
            exerciseLower.contains('is') ||
            exerciseLower.contains('are')) {
          return ['am', 'is', 'are', 'be'];
        }

        // Geniş zaman için
        else if (exerciseLower.contains('have') ||
            exerciseLower.contains('has') ||
            exerciseLower.contains('had')) {
          return ['have', 'has', 'had', 'having'];
        }

        // Yardımcı fiiller
        else if (exerciseLower.contains('do') ||
            exerciseLower.contains('does') ||
            exerciseLower.contains('did')) {
          return ['do', 'does', 'did', 'done'];
        }

        // Varsayılan boşluk doldurma seçenekleri
        else {
          return ['will', 'would', 'should', 'must'];
        }

      case 'multiple_choice':
      default:
        // Çoktan seçmeli için anlamlı seçenekler oluştur
        final options =
            ['A', 'B', 'C', 'D'].map((letter) => 'Seçenek $letter').toList();

        return options;
    }
  }

  // Soru tipi için doğru cevabı belirleme
  dynamic _getCorrectAnswerForExercise(
      List<String> options, String questionType) {
    // Basitleştirilmiş: İlk seçeneği doğru kabul ediyoruz
    return 0;
  }

  // Soru için ipucu oluşturma
  String? _getHintForExercise(String exercise, String questionType) {
    switch (questionType) {
      case 'fill_in_the_blank':
        return 'Cümlede boş bırakılan yere uygun kelimeyi seçin';

      case 'true_false':
        return 'Cümlenin doğru mu yanlış mı olduğunu belirleyin';

      case 'multiple_choice':
        return 'En uygun seçeneği işaretleyin';

      default:
        return null;
    }
  }

  // Açıklama oluşturma
  String _getExplanationForExercise(String exercise, String questionType,
      dynamic correctAnswer, List<String> options) {
    final correctOption = options[correctAnswer as int];

    switch (questionType) {
      case 'fill_in_the_blank':
        return 'Doğru cevap: "$correctOption". Bu kelimenin cümledeki boşluğa gelmesi dil bilgisi açısından uygundur.';

      case 'true_false':
        return 'Doğru cevap: $correctOption. Bu cümle dil bilgisi açısından ${correctAnswer == 0 ? 'doğrudur' : 'yanlıştır'}.';

      case 'multiple_choice':
        return 'Doğru cevap: $correctOption';

      default:
        return 'Doğru cevap açıklaması burada yer alacak.';
    }
  }
}
