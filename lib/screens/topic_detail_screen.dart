import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/grammar_topic.dart';
import '../core/providers.dart';
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
        ref
            .read(grammarControllerProvider.notifier)
            .loadGrammarTopic(widget.topicId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final grammarState = ref.watch(grammarControllerProvider);

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
        
                ..._buildGrammarStructureDetails(topic, isDark, color),
           
       
          
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


}
