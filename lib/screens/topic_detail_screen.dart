import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grammar_provider.dart';
import '../providers/theme_provider.dart';
import '../models/grammar_topic.dart';
import '../screens/subtopic_detail_screen.dart';
import '../screens/exercise_detail_screen.dart';
import '../utils/constants/colors.dart';

class TopicDetailScreen extends StatefulWidget {
  final String topicId;

  const TopicDetailScreen({Key? key, required this.topicId}) : super(key: key);

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<GrammarProvider>(context, listen: false)
            .loadGrammarTopic(widget.topicId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Consumer<GrammarProvider>(
      builder: (context, grammarProvider, child) {
        if (grammarProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final topic = grammarProvider.topics.firstWhere(
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
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(topic, isDark),
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Konu Açıklaması
                    _buildDescriptionSection(topic.description, isDark),
                    const SizedBox(height: 32),

                    // 2. Gramer Yapısı ve Bilgisi
                    _buildGrammarStructureSection(topic, isDark),
                    const SizedBox(height: 32),

                    // 3. Örnek Cümleler
                    if (topic.examples.isNotEmpty)
                      _buildExamplesSection(topic.examples, isDark),
                    const SizedBox(height: 50),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(GrammarTopic topic, bool isDark) {
    final color = AppColors.getColorByName(topic.color);

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
      backgroundColor: color,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        title: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Text(
            topic.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 30, bottom: 15),
        centerTitle: false,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color,
                    color.withOpacity(0.8),
                  ],
                ),
              ),
            ),
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
            Positioned(
              right: 30,
              bottom: 100,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
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

  Widget _buildDescriptionSection(String description, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242424) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
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
                    Icons.info_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Konu Özeti',
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
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesSection(List<String> examples, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF00897B) : AppColors.tertiary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.tertiary.withOpacity(isDark ? 0.3 : 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Örnek Cümleler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${examples.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF242424) : Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: examples.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildExampleCard(examples[index], index, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExampleCard(String example, int index, bool isDark) {
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

    return Container(
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
                  'Örnek ${index + 1}',
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
                color:
                    isDark ? color.withOpacity(0.07) : color.withOpacity(0.05),
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
                  color:
                      isDark ? const Color(0xFF1A1A1A) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Türkçe Çevirisi:',
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
                        height: 1.5,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : AppColors.textPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarStructureSection(GrammarTopic topic, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242424) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
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

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gramer yapısı başlığı
                Text(
                  '${topic.title} - Temel Bilgiler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),

                // Açıklama
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.deepPurple.withOpacity(0.15)
                        : Colors.deepPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(isDark ? 0.3 : 0.2),
                    ),
                  ),
                  child: Text(
                    topic.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Gramer yapısı başlığı
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(isDark ? 0.3 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_list_numbered,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Cümle Yapısı ve Kurallar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Gramer yapısı detayları - bu bölüm dinamik olarak oluşturuluyor
                ..._buildGrammarStructureDetails(topic, isDark),

                const SizedBox(height: 24),

                // Dikkat edilmesi gereken noktalar
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(isDark ? 0.3 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Dikkat Edilmesi Gerekenler',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(isDark ? 0.1 : 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(isDark ? 0.3 : 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bu yapıyı kullanırken dikkat edilmesi gerekenler:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getWarningTextForTopic(topic),
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark ? Colors.white : AppColors.textPrimary,
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
    );
  }

  // Gramer Yapısı Detaylarını Oluştur
  List<Widget> _buildGrammarStructureDetails(GrammarTopic topic, bool isDark) {
    List<Widget> widgets = [];

    // Gramer verilerini doğrudan topic.grammar_structure'dan alıyoruz
    String grammarContent = topic.grammar_structure;

    // Eğer içerik yoksa default bir mesaj göster
    if (grammarContent.isEmpty) {
      grammarContent =
          'Bu konu için detaylı gramer bilgileri henüz eklenmemiştir.';
    }

    // İçeriği formatlı bir şekilde göster
    widgets.add(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildFormattedGrammarText(grammarContent, isDark),
        ),
      ),
    );

    return widgets;
  }

  // Gramer metnini formatlamak için yeni fonksiyon
  List<Widget> _buildFormattedGrammarText(String text, bool isDark) {
    List<Widget> widgets = [];

    // Satırları böl
    List<String> lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Boş satırları atla ve ekstra boşluk ekle
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // 1. Olumlu cümleler: gibi başlıkları formatlama
      if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        );
      }
      // - I/you/we/they + V1 gibi alt başlıklar için
      else if (line.trim().startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 4, bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }
      // Örnek: gibi örnekler için
      else if (line.contains('Örnek:')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.deepPurple.withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(top: 2, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 14,
                    color: Colors.deepPurple.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line.trim(),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      // Diğer metinler için
      else {
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
}
