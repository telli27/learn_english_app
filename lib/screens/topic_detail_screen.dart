import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/grammar_topic.dart';
import '../core/providers.dart';
import '../screens/subtopic_detail_screen.dart';
import '../screens/exercise_detail_screen.dart';
import '../utils/constants/colors.dart';
import '../core/providers/topic_progress_provider.dart';
import '../auth/providers/auth_provider.dart';
import 'dart:async';

class TopicDetailScreen extends ConsumerStatefulWidget {
  final String topicId;

  const TopicDetailScreen({Key? key, required this.topicId}) : super(key: key);

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _progressTimer;
  double _currentProgress = 0.0;
  int _lastPosition = 0;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(grammarControllerProvider.notifier)
            .loadGrammarTopic(widget.topicId);

        // Load existing progress if user is logged in
        _loadExistingProgress();

        // Listen to scroll events to track progress
        _scrollController.addListener(_updateProgressOnScroll);

        // Start periodic progress saving
        _startProgressSaving();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgressOnScroll);
    _scrollController.dispose();
    _progressTimer?.cancel();

    // Save progress one last time when leaving the screen
    _saveProgress();

    super.dispose();
  }

  // Load existing progress from Firebase
  void _loadExistingProgress() async {
    final authState = ref.read(authProvider);

    if (!authState.isLoggedIn) return;

    // Get progress from the progress provider
    final progressState = ref.read(topicProgressProvider);
    final progress = progressState.getProgressForTopic(widget.topicId);

    if (progress > 0) {
      setState(() {
        _currentProgress = progress;

        // Show a toast message if significant progress already exists
        if (progress > 50) {
          // Delay to ensure UI is built
          Future.delayed(const Duration(milliseconds: 800), () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Bu konuda %${progress.toInt()} ilerleme kaydetmişsiniz',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.blue,
              ),
            );
          });
        }
      });
    }
  }

  // Start periodic progress saving
  void _startProgressSaving() {
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isUserScrolling) {
        _saveProgress();
      }
    });
  }

  // Update progress based on scroll position
  void _updateProgressOnScroll() {
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (!authState.isLoggedIn) return;

    // Get total scrollable area
    final totalScrollExtent = _scrollController.position.maxScrollExtent;

    if (totalScrollExtent <= 0) return;

    // Calculate current position as a percentage
    final currentScrollPosition = _scrollController.position.pixels;
    final scrollPercentage = (currentScrollPosition / totalScrollExtent) * 100;

    // We'll consider the progress as the maximum between:
    // 1. The current scroll percentage (how far they've scrolled)
    // 2. The previously recorded progress (so it never goes down)
    final newProgress = scrollPercentage > _currentProgress
        ? scrollPercentage
        : _currentProgress;

    // Check for milestone achievements (25%, 50%, 75%, 100%)
    if (_currentProgress < 25 && newProgress >= 25) {
      _showMilestoneAchievement(25);
    } else if (_currentProgress < 50 && newProgress >= 50) {
      _showMilestoneAchievement(50);
    } else if (_currentProgress < 75 && newProgress >= 75) {
      _showMilestoneAchievement(75);
    } else if (_currentProgress < 100 && newProgress >= 100) {
      _showMilestoneAchievement(100);
    }

    setState(() {
      _currentProgress = newProgress;
      _lastPosition = currentScrollPosition.toInt();
      _isUserScrolling = true;
    });
  }

  // Show milestone achievement notification
  void _showMilestoneAchievement(int milestone) {
    final topic = ref.read(grammarControllerProvider).topics.firstWhere(
          (t) => t.id == widget.topicId,
          orElse: () => GrammarTopic(
            id: '',
            title: 'Unknown Topic',
            description: '',
            examples: [],
            color: 'blue',
            iconPath: '',
          ),
        );

    String message;
    Color backgroundColor;

    switch (milestone) {
      case 25:
        message = 'Güzel gidiyorsun! %25 tamamlandı';
        backgroundColor = Colors.blue;
        break;
      case 50:
        message = 'Yarıyı tamamladın! Harika ilerleme';
        backgroundColor = Colors.green;
        break;
      case 75:
        message = 'Çok iyi! %75 tamamlandı';
        backgroundColor = Colors.orange;
        break;
      case 100:
        message = 'Tebrikler! Konuyu tamamen bitirdin';
        backgroundColor = Colors.purple;
        break;
      default:
        message = 'İyi gidiyorsun!';
        backgroundColor = Colors.blue;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Save progress to Firebase
  void _saveProgress() async {
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (!authState.isLoggedIn) return;

    // Don't save if there's no actual progress
    if (_currentProgress <= 0) return;

    // Cap progress at 100%
    final cappedProgress = _currentProgress > 100 ? 100.0 : _currentProgress;

    // Update progress via the provider
    await ref.read(topicProgressProvider.notifier).updateTopicProgress(
          widget.topicId,
          cappedProgress,
          _lastPosition,
        );

    setState(() {
      _isUserScrolling = false;
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

    return WillPopScope(
      onWillPop: () {
        // Save progress before leaving screen
        _saveProgress();

        // Refresh the topic progress list
        final authState = ref.read(authProvider);
        if (authState.isLoggedIn) {
          // Trigger refresh of progress data using microtask to avoid waiting
          Future.microtask(() =>
              ref.read(topicProgressProvider.notifier).loadUserProgress());
        }

        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(topic, isDark),
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Grammar Structure and Information
                  _buildGrammarStructureSection(topic, isDark),
                  const SizedBox(height: 32),

                  // Other sections
                  // ...

                  const SizedBox(height: 50),
                ]),
              ),
            ),
          ],
        ),
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
