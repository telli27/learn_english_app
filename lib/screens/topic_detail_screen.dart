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
import 'package:flutter_tts/flutter_tts.dart';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.45);
    flutterTts.setPitch(1.0);
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

        // Load and show interstitial ad if not reached max impression limit
        final adService = ref.read(adServiceProvider);
        if (!ref.read(isInterstitialLimitReachedProvider)) {
          adService.loadInterstitialAd().then((_) {
            if (mounted) {
              adService.showInterstitialAd();
            }
          });
        }
        // Load banner ad
        adService.loadBannerAd();
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    _scrollController.removeListener(_updateProgressOnScroll);
    _scrollController.dispose();
    _progressTimer?.cancel();

    // Save progress one last time when leaving the screen

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
                  AppLocalizations.of(context)!
                      .progressMessage(progress.toInt()),
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
      if (_isUserScrolling) {}
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
        message = AppLocalizations.of(context)!.milestone25;
        backgroundColor = Colors.blue;
        break;
      case 50:
        message = AppLocalizations.of(context)!.milestone50;
        backgroundColor = Colors.green;
        break;
      case 75:
        message = AppLocalizations.of(context)!.milestone75;
        backgroundColor = Colors.orange;
        break;
      case 100:
        message = AppLocalizations.of(context)!.milestone100;
        backgroundColor = Colors.purple;
        break;
      default:
        message = AppLocalizations.of(context)!.milestoneDefault;
        backgroundColor = Colors.blue;
    }

    /* ScaffoldMessenger.of(context).showSnackBar(
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
    );*/
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
        title: AppLocalizations.of(context)!.topicNotFound,
        description: '',
        examples: [],
        color: 'blue',
        iconPath: '',
      ),
    );

    if (topic.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(AppLocalizations.of(context)!.topicNotFound)),
      );
    }

    return WillPopScope(
      onWillPop: () {
        // Save progress before leaving screen

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

                  // Banner Ad
                  RevenueCatIntegrationService.instance.isPremium.value == true
                      ? Container()
                      : Consumer(
                          builder: (context, ref, child) {
                            final adService = ref.watch(adServiceProvider);
                            final bannerAd = adService.getBannerAdWidget();
                            if (bannerAd != null) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: bannerAd,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
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
      grammarContent = AppLocalizations.of(context)!.noGrammarDetails;
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
        // Gramer formülü: İngilizce ve Türkçe kısmı ayır
        // Format: - I/you/we/they + V1 (fiilin yalın hali) veya - G
        final trimmed = line.trim().substring(1).trim(); // '-' işaretini at
        String rule = trimmed;
        String explanation = '';
        // Parantez varsa ayır
        final parenIndex = trimmed.indexOf('(');
        if (parenIndex != -1 && trimmed.endsWith(')')) {
          rule = trimmed.substring(0, parenIndex).trim();
          explanation =
              trimmed.substring(parenIndex + 1, trimmed.length - 1).trim();
        }
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: grammarRuleCard(rule, explanation, isDark),
          ),
        );
      } else if (line.trim().startsWith('Örnek:')) {
        // Örnek cümleleri ayır: İngilizce ve Türkçe kısmı
        // Format: Örnek: "I work every day." (Her gün çalışırım.)
        final exampleRegex = RegExp(r'Örnek:\s*"(.+?)"\s*\((.+?)\)');
        final match = exampleRegex.firstMatch(line);
        if (match != null) {
          final english = match.group(1) ?? '';
          final turkish = match.group(2) ?? '';
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: exampleCard(english, turkish, isDark),
            ),
          );
        } else {
          // Eğer format uymuyorsa düz metin olarak ekle
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

  // Örnek cümleler için özel kart widget'ı
  Widget exampleCard(String english, String turkish, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey.shade900 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade100,
        ),
      ),
      child: Stack(
        children: [
          // Ses ikonu daha yukarı ve sağ köşede
          Positioned(
            top: -18,
            right: -12,
            child: IconButton(
              icon: Icon(Icons.volume_up, color: Colors.blue, size: 22),
              tooltip: AppLocalizations.of(context)!.pronounceEnglish,
              onPressed: () async {
                await flutterTts.stop();
                await flutterTts.speak(english);
              },
            ),
          ),
          // Kart içeriği
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.example,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                english,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                turkish,
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Gramer formülleri için özel kart widget'ı
  Widget grammarRuleCard(String rule, String explanation, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_outlined, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (explanation.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    explanation,
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
