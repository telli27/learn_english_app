import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '../providers/grammar_provider.dart';
import '../providers/theme_provider.dart';
import '../core/models/grammar_topic.dart';
import '../screens/subtopic_detail_screen.dart';
import '../screens/exercise_detail_screen.dart';
import '../utils/constants/colors.dart';

class TopicDetailScreen extends ConsumerStatefulWidget {
  final String topicId;

  const TopicDetailScreen({Key? key, required this.topicId}) : super(key: key);

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(grammarProvider.notifier).loadGrammarTopic(widget.topicId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final grammarState = ref.watch(grammarProvider);

    if (grammarState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final topic = grammarState.topics.firstWhere(
      (t) => t.id == widget.topicId,
      orElse: () => GrammarTopic(
        id: '',
        title: 'Konu bulunamadı',
        description: '',
        examples: [],
        color: 'blue',
        iconPath: '',
      ),
    );

    if (topic.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Konu bulunamadı')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(topic, isDark),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Gramer Yapısı ve Bilgisi
                _buildGrammarStructureSection(topic, isDark),
                const SizedBox(height: 32),

                // Örnek Cümleler
                if (topic.examples.isNotEmpty)
                  _buildExamplesSection(topic.examples, isDark),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(GrammarTopic topic, bool isDark) {
    final color = AppColors.getColorByName(topic.color);
    final darkColor = isDark ? Colors.black : color;

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      leadingWidth: 56,
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left_outlined,
          color: Colors.white,
          size: 35,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: darkColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        title: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Text(
            topic.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: isDark ? Colors.white.withOpacity(0.95) : Colors.white,
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 15),
        centerTitle: false,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF0F0F0F),
                        ]
                      : [
                          color,
                          color.withOpacity(0.8),
                        ],
                ),
              ),
            ),
            if (!isDark) ...[
              Positioned(
                right: -100,
                top: -100,
                child: CircleAvatar(
                  radius: 130,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: -80,
                bottom: -60,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
            Positioned(
              right: 30,
              bottom: 100,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book,
                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [],
    );
  }

  Widget _buildGrammarStructureSection(GrammarTopic topic, bool isDark) {
    final color = AppColors.getColorByName(topic.color);
    final headingColor = isDark ? const Color(0xFF4F6CFF) : color;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1C21) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2026) : color,
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
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.architecture,
                    color:
                        isDark ? Colors.white.withOpacity(0.9) : Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Gramer Yapısı ve Kuralları',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? Colors.white.withOpacity(0.95) : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Genel Tanım ve Açıklama kısmı
                Text(
                  "Genel Tanım ve Açıklama:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2026)
                        : color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: isDark
                        ? null
                        : Border.all(
                            color: color.withOpacity(0.2),
                          ),
                  ),
                  child: Text(
                    "Şimdiki zaman (Present Continuous), şu anda devam eden veya yakın gelecekte planlanan eylemleri ifade etmek için kullanılan bir zaman yapısıdır.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  '${topic.title} - Temel Bilgiler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2026)
                        : color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: isDark
                        ? null
                        : Border.all(
                            color: color.withOpacity(0.2),
                          ),
                  ),
                  child: Text(
                    topic.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2026)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isDark
                        ? null
                        : Border.all(
                            color: Colors.transparent,
                          ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_list_numbered,
                        color: isDark ? headingColor : color,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Cümle Yapısı ve Kurallar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? headingColor : color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildGrammarStructureDetails(topic, isDark, color),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gramer yapısı detaylarını oluştur
  List<Widget> _buildGrammarStructureDetails(
      GrammarTopic topic, bool isDark, Color color) {
    List<Widget> widgets = [];
    final headingColor = isDark ? const Color(0xFF4F6CFF) : color;

    String grammarContent = topic.grammar_structure;

    if (grammarContent.isEmpty) {
      grammarContent =
          'Bu konu için detaylı gramer bilgileri henüz eklenmemiştir.';
    }

    widgets.add(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2026) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: isDark
              ? null
              : Border.all(
                  color: color.withOpacity(0.2),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildFormattedGrammarText(grammarContent, isDark, color),
        ),
      ),
    );

    return widgets;
  }

  // Gramer metnini formatla
  List<Widget> _buildFormattedGrammarText(
      String text, bool isDark, Color color) {
    List<Widget> widgets = [];
    List<String> lines = text.split('\n');
    final headingColor = isDark ? const Color(0xFF4F6CFF) : color;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
          ),
        );
      } else if (line.trim().startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 4, bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: isDark
                    ? Colors.white.withOpacity(0.9)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark
                    ? Colors.white.withOpacity(0.85)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // Konuya göre uyarı metni oluşturma
  String _getWarningTextForTopic(GrammarTopic topic) {
    final String topicTitle = topic.title.toLowerCase();

    if (topicTitle.contains('present') || topicTitle.contains('geniş zaman')) {
      return '• Remember to add -s or -es to the verb for third person singular (he/she/it)\n'
          '• Don\'t forget to use auxiliary verbs "do/does" in negative and question forms\n'
          '• Pay attention to time adverbs (always, never, sometimes, often)\n'
          '• Be careful with special verb forms (have→has, go→goes, do→does)';
    } else if (topicTitle.contains('past') ||
        topicTitle.contains('geçmiş zaman')) {
      return '• Use correct forms of regular and irregular verbs\n'
          '• Remember to use the auxiliary verb "did" in negative and question forms\n'
          '• Pay attention to past time expressions (yesterday, last week, ago)\n'
          '• Be mindful of the correct pronunciation of -ed endings for regular verbs';
    } else if (topicTitle.contains('future') ||
        topicTitle.contains('gelecek')) {
      return '• Note the difference between "will" and "going to"\n'
          '• Remember that present continuous can also be used to express future actions\n'
          '• Pay attention to future time expressions (tomorrow, next week, soon)\n'
          '• Remember that present simple is used for scheduled events in the future';
    } else if (topicTitle.contains('conditional') ||
        topicTitle.contains('koşul')) {
      return '• Pay attention to the time correspondence in different conditional types\n'
          '• Use the correct tense in both the if-clause and the result clause\n'
          '• Learn other conditionals using "unless, as long as, provided that"\n'
          '• Be mindful of how to use would/could/might correctly';
    } else if (topicTitle.contains('passive') ||
        topicTitle.contains('edilgen')) {
      return '• Pay attention to the subject-object change when converting active to passive\n'
          '• Use the appropriate form of "be" and past participle for each tense\n'
          '• Use "by" to mention who performs the action\n'
          '• Ensure subject-verb agreement when there is no object in the passive form';
    } else if (topicTitle.contains('modal')) {
      return '• Remember that bare infinitives (without to) are used after modal verbs\n'
          '• Consider the different meanings and uses of each modal verb\n'
          '• Modal verbs don\'t change form according to time or person\n'
          '• Learn the correct structures for past modals (could have done, should have done)';
    } else {
      return '• Pay attention to time consistency\n'
          '• Ensure subject-verb agreement\n'
          '• Use the correct auxiliary verbs\n'
          '• Be mindful of word order in sentence structure';
    }
  }

  // Örnek cümle için gramer yapısını belirleme
  String _getGrammarStructureForExample(String example, String topicTitle) {
    if (topicTitle.contains('present simple') ||
        topicTitle.contains('geniş zaman')) {
      if (example.contains("don't") || example.contains("doesn't")) {
        return "Olumsuz cümle: Subject + don't/doesn't + V1";
      } else if (example.contains("Do") || example.contains("Does")) {
        return "Soru cümlesi: Do/Does + subject + V1?";
      } else {
        return "Olumlu cümle: Subject + V1 (he/she/it için V1+s/es)";
      }
    } else if (topicTitle.contains('present continuous') ||
        topicTitle.contains('şimdiki zaman')) {
      if (example.contains("isn't") || example.contains("aren't")) {
        return "Olumsuz cümle: Subject + am/is/are + not + V-ing";
      } else if (example.contains("Is") || example.contains("Are")) {
        return "Soru cümlesi: Am/Is/Are + subject + V-ing?";
      } else {
        return "Olumlu cümle: Subject + am/is/are + V-ing";
      }
    } else if (topicTitle.contains('past simple') ||
        topicTitle.contains('geçmiş zaman')) {
      if (example.contains("didn't")) {
        return "Olumsuz cümle: Subject + didn't + V1";
      } else if (example.contains("Did")) {
        return "Soru cümlesi: Did + subject + V1?";
      } else {
        return "Olumlu cümle: Subject + V2 (düzenli fiiller için V1+ed)";
      }
    } else if (topicTitle.contains('future') ||
        topicTitle.contains('gelecek')) {
      if (example.contains("won't")) {
        return "Olumsuz cümle: Subject + won't + V1";
      } else if (example.contains("Will")) {
        return "Soru cümlesi: Will + subject + V1?";
      } else {
        return "Olumlu cümle: Subject + will + V1";
      }
    } else if (topicTitle.contains('present perfect') ||
        topicTitle.contains('yakın geçmiş')) {
      if (example.contains("haven't") || example.contains("hasn't")) {
        return "Olumsuz cümle: Subject + haven't/hasn't + V3";
      } else if (example.contains("Have") || example.contains("Has")) {
        return "Soru cümlesi: Have/Has + subject + V3?";
      } else {
        return "Olumlu cümle: Subject + have/has + V3";
      }
    }
    return "Gramer yapısı: ${topicTitle}";
  }

  Widget _buildExamplesSection(List<String> examples, bool isDark) {
    final grammarState = ref.watch(grammarProvider);

    final topic = grammarState.topics.firstWhere((t) => t.id == widget.topicId);
    final headingColor =
        isDark ? const Color(0xFF4F6CFF) : const Color(0xFF4F6CFF);
    final cardBackgroundColor =
        isDark ? const Color(0xFF1B1C21) : const Color(0xFFF0F3FF);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1C21) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            'Örnekler ve Kullanım',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 20),

          // I am + Ving - Olumlu örnek
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: !isDark
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Örnek cümle
                Text(
                  '"I am reading a book."',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : AppColors.textPrimary,
                  ),
                ),
                // Anlamı
                const SizedBox(height: 6),
                Text(
                  'Bir kitap okuyorum.',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.7),
                  ),
                ),
                // Kural
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Kural: I + am + Ving',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // You/They are + Ving - Olumlu örnek
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: !isDark
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Örnek cümle
                Text(
                  '"You are watching TV."',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : AppColors.textPrimary,
                  ),
                ),
                // Anlamı
                const SizedBox(height: 6),
                Text(
                  'Televizyon izliyorsun.',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.7),
                  ),
                ),
                // Kural
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Kural: You/We/They + are + Ving',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // He/She/It is + Ving - Olumlu örnek
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: !isDark
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Örnek cümle
                Text(
                  '"She is studying for her exam."',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : AppColors.textPrimary,
                  ),
                ),
                // Anlamı
                const SizedBox(height: 6),
                Text(
                  'Sınavı için ders çalışıyor.',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.7),
                  ),
                ),
                // Kural
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Kural: He/She/It + is + Ving',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Olumsuz Örnek
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: !isDark
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Örnek cümle
                Text(
                  '"You aren\'t listening to me."',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : AppColors.textPrimary,
                  ),
                ),
                // Anlamı
                const SizedBox(height: 6),
                Text(
                  'Beni dinlemiyorsun.',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.7),
                  ),
                ),
                // Kural
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Kural: Subject + am/is/are + not + Ving',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Soru örneği
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: !isDark
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Örnek cümle
                Text(
                  '"Are you waiting for someone?"',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : AppColors.textPrimary,
                  ),
                ),
                // Anlamı
                const SizedBox(height: 6),
                Text(
                  'Birini mi bekliyorsun?',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.7),
                  ),
                ),
                // Kural
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Kural: Am/Is/Are + subject + Ving?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Kullanım alanları başlığı
          const SizedBox(height: 12),
          Text(
            'Kullanım Alanları:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 12),

          // Kullanım örneği 1
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: !isDark
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanım adı
                Text(
                  'Şu anda devam eden eylemler:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Örnek
                Text(
                  '"I am writing an email right now." (Şu anda bir e-posta yazıyorum.)',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? Colors.white.withOpacity(0.85)
                        : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Kullanım örneği 2
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: !isDark
                  ? null
                  : Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanım adı
                Text(
                  'Planlanmış yakın gelecek:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Örnek
                Text(
                  '"We are meeting at 6 PM tomorrow." (Yarın saat 6\'da buluşuyoruz.)',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? Colors.white.withOpacity(0.85)
                        : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
