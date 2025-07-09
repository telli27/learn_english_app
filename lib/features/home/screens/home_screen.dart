import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:revenue_cat_integration/configs/packages_text_config.dart';
import 'package:revenue_cat_integration/revenue_cat_integration.dart';
import 'package:revenue_cat_integration/widgets/feature_item.dart';
import 'dart:ui';
import '../../../core/providers.dart';
import '../../../core/models/grammar_topic.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../features/grammar/screens/grammar_topic_screen.dart';
import '../../../screens/topic_detail_screen.dart';
import '../../../core/data/grammar_data.dart';
import '../../../core/data/grammar_version_checker.dart';
import '../../../utils/update_dialog.dart';
import '../../../auth/screens/login_screen.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../core/providers/topic_progress_provider.dart';
import '../../../core/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart' show showUserMenu;

// State provider for selected filter
final selectedFilterProvider = StateProvider<String>((ref) => 'all');

// Function to get grammar categories for filters
List<String> getGrammarCategories(AppLocalizations l10n) {
  return [
    l10n.all,
    l10n.verb_tenses,
    l10n.sentence_structure,
    l10n.nouns_adjectives,
    l10n.spoken_language
  ];
}

// State provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');
final isSearchingProvider = StateProvider<bool>((ref) => false);

// Firebase auth state provider - would be replaced with real Firebase implementation
// In a real app, you'd have something like:
// final authStateProvider = StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());
final isUserLoggedInProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Static flag to track if dialog has been shown in current app session
  static bool _hasShownUpdateDialogForSession = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadGrammarTopics();

    // Setup search controller listener
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  void _loadGrammarTopics() {
    // Load grammar topics when the screen loads
    Future.microtask(() {
      // Get current locale for loading appropriate language data
      final currentLocale = ref.read(localeProvider);
      final languageCode = currentLocale.languageCode;

      print("🏠 HomeScreen loading topics for language: $languageCode");
      print(
          "📊 Current GrammarData.topics count: ${GrammarData.topics.length}");

      // Check if we already have topics loaded (from language change)
      if (GrammarData.topics.isNotEmpty) {
        print("✅ Topics already available, updating controller directly");
        ref
            .read(grammarControllerProvider.notifier)
            .updateTopicsDirectly(GrammarData.topics);
      } else {
        print("📥 No topics available, loading from server");
        ref
            .read(grammarControllerProvider.notifier)
            .loadGrammarTopics(languageCode: languageCode, forceReload: true);
      }

      // Load user progress if user is logged in
      final authState = ref.read(authProvider);
      if (authState.isLoggedIn) {
        ref.read(topicProgressProvider.notifier).loadUserProgress();
      }

      // Delay showing dialog slightly to ensure screen is fully built
      Future.delayed(const Duration(milliseconds: 500), () {
        // Check for updates and show dialog if needed, but only if not already shown in this session
        if (mounted && !_hasShownUpdateDialogForSession) {
          GrammarData.showUpdateDialogIfNeeded(context,
              languageCode: languageCode);
          _hasShownUpdateDialogForSession = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Method to show the update dialog for testing
  void _showTestUpdateDialog() {
    // Show a test update dialog
    UpdateDialog.showUpdateDialog(
      context,
      ['tasarım düzenlendi', 'kullanıcı deneyimi açısından ynilikler yapıldı'],
    );
  }

  // Method to force update checking by clearing SharedPreferences
  void _forceUpdateCheck() async {
    // Reset the session flag when forcing an update check
    _hasShownUpdateDialogForSession = false;

    // Get current locale
    final currentLocale = ref.read(localeProvider);
    final languageCode = currentLocale.languageCode;

    await GrammarVersionChecker.clearAllData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Önbellek temizlendi. Güncelleme kontrolü yapılıyor...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Clear GrammarData topics and reload with current language
    GrammarData.topics.clear();
    await GrammarData.loadTopics(languageCode: languageCode);
    if (mounted) {
      GrammarData.showUpdateDialogIfNeeded(context, languageCode: languageCode);
      _hasShownUpdateDialogForSession = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = ref.watch(grammarTopicsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final grammarCategories = getGrammarCategories(l10n);

    // Check if we need to load topics for current language on every build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (topics.isEmpty && !isLoading && errorMessage == null) {
        print(
            "🔄 Build detected empty topics, checking for language: ${currentLocale.languageCode}");
        if (GrammarData.topics.isNotEmpty) {
          print("📥 Found topics in GrammarData, updating controller");
          ref
              .read(grammarControllerProvider.notifier)
              .updateTopicsDirectly(GrammarData.topics);
        } else {
          print(
              "📥 No topics found, loading for language: ${currentLocale.languageCode}");
          ref.read(grammarControllerProvider.notifier).loadGrammarTopics(
              languageCode: currentLocale.languageCode, forceReload: true);
        }
      }
    });

    // Listen for locale changes and update grammar controller with new data
    ref.listen<Locale>(localeProvider, (previous, next) {
      if (previous != null && previous.languageCode != next.languageCode) {
        print(
            "🌍 Locale changed from ${previous.languageCode} to ${next.languageCode}");
        print("🔄 Updating grammar controller with new language data");

        // Wait a moment for the language loading to complete, then update controller
        Future.delayed(const Duration(milliseconds: 500), () {
          if (GrammarData.topics.isNotEmpty) {
            print(
                "📊 Updating GrammarController with ${GrammarData.topics.length} topics");
            // Directly update the controller state with the new topics
            ref
                .read(grammarControllerProvider.notifier)
                .updateTopicsDirectly(GrammarData.topics);
          } else {
            print(
                "⚠️ No topics found after language change, force reloading...");
            ref.read(grammarControllerProvider.notifier).loadGrammarTopics(
                languageCode: next.languageCode, forceReload: true);
          }
        });
      }
    });

    // Konular boş ve yükleme tamamlanmışsa, loading durumunu doğru göster
    final bool effectiveLoading =
        isLoading || (topics.isEmpty && errorMessage == null);

    // Update to use authState
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;

    // Get user progress
    final progressState = ref.watch(topicProgressProvider);

    // Filter topics based on selected category and search query
    final filteredTopics = topics.where((topic) {
      // If there's a search query, search in all topics regardless of category
      if (searchQuery.isNotEmpty) {
        // Search in title and description
        return topic.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            topic.description.toLowerCase().contains(searchQuery.toLowerCase());
      }

      // If no search query, apply category filter
      if (selectedFilter != l10n.all) {
        bool matchesCategory = false;
        switch (selectedFilter) {
          case String filter when filter == l10n.verb_tenses:
            matchesCategory = topic.title.toLowerCase().contains('zaman') ||
                topic.title.toLowerCase().contains('tense') ||
                topic.title.toLowerCase().contains('present') ||
                topic.title.toLowerCase().contains('past') ||
                topic.title.toLowerCase().contains('future') ||
                topic.title.toLowerCase().contains('perfect') ||
                topic.title.toLowerCase().contains('continuous');
            break;
          case String filter when filter == l10n.sentence_structure:
            matchesCategory = topic.title.toLowerCase().contains('cümle') ||
                topic.title.toLowerCase().contains('sentence') ||
                topic.title.toLowerCase().contains('clause') ||
                topic.title.toLowerCase().contains('question') ||
                topic.title.toLowerCase().contains('soru') ||
                topic.title.toLowerCase().contains('passive') ||
                topic.title.toLowerCase().contains('active') ||
                topic.title.toLowerCase().contains('edilgen') ||
                topic.title.toLowerCase().contains('conditional') ||
                topic.title.toLowerCase().contains('şart');
            break;
          case String filter when filter == l10n.nouns_adjectives:
            matchesCategory = topic.title.toLowerCase().contains('noun') ||
                topic.title.toLowerCase().contains('isim') ||
                topic.title.toLowerCase().contains('adj') ||
                topic.title.toLowerCase().contains('sıfat') ||
                topic.title.toLowerCase().contains('zamir') ||
                topic.title.toLowerCase().contains('pronoun') ||
                topic.title.toLowerCase().contains('article') ||
                topic.title.toLowerCase().contains('tanımlık');
            break;
          case String filter when filter == l10n.spoken_language:
            matchesCategory = topic.title.toLowerCase().contains('speak') ||
                topic.title.toLowerCase().contains('konuşma') ||
                topic.title.toLowerCase().contains('dialogue') ||
                topic.title.toLowerCase().contains('diyalog') ||
                topic.title.toLowerCase().contains('informal') ||
                topic.title.toLowerCase().contains('slang') ||
                topic.title.toLowerCase().contains('expression') ||
                topic.title.toLowerCase().contains('deyim') ||
                topic.title.toLowerCase().contains('phrasal');
            break;
          default:
            matchesCategory = true;
        }

        return matchesCategory;
      }

      return true;
    }).toList();

    // If user just logged in, load progress data
    if (authState.isLoggedIn &&
        !progressState.isLoading &&
        progressState.progressList.isEmpty) {
      Future.microtask(
          () => ref.read(topicProgressProvider.notifier).loadUserProgress());
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
            _buildAppBar(isDark, filteredTopics.length, isLoggedIn,
                grammarCategories, l10n),

            // Search field when searching is active
            if (isSearching) _buildSearchField(isDark, l10n),

            // Error message if there is an error
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Loading indicator - shows even if topics are empty
            if (effectiveLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        l10n.loading_topics,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // When no topics are found after filtering and not loading
            else if (filteredTopics.isEmpty && !effectiveLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: isDark ? Colors.grey[700] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isNotEmpty
                            ? l10n.no_search_results
                            : l10n.no_topics_in_category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      if (searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(isSearchingProvider.notifier).state =
                                false;
                            _searchFocusNode.unfocus();
                          },
                          icon: const Icon(Icons.close),
                          label: Text(l10n.clear_search),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            // Scrollable list of topics when there are topics to show
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Get current locale for reloading appropriate language data
                    final currentLocale = ref.read(localeProvider);
                    final languageCode = currentLocale.languageCode;

                    // Reload topics and progress on pull to refresh
                    await ref
                        .read(grammarControllerProvider.notifier)
                        .loadGrammarTopics(languageCode: languageCode);
                    // Also reload progress if user is logged in
                    if (authState.isLoggedIn) {
                      await ref
                          .read(topicProgressProvider.notifier)
                          .loadUserProgress();
                    }
                  },
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];

                      // Get progress for this topic
                      double progress = 0;
                      if (isLoggedIn && !progressState.isLoading) {
                        progress = progressState.getProgressForTopic(topic.id);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTopicCard(topic, progress, isDark),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget method for topic cards
  Widget _buildTopicCard(GrammarTopic topic, double progress, bool isDark) {
    final color = AppColors.getColorByName(topic.color);

    return GestureDetector(
      onTap: () async {
        // Navigate to topic detail
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopicDetailScreen(topicId: topic.id),
          ),
        );

        // When returning from topic detail, refresh progress data
        if (ref.read(authProvider).isLoggedIn) {
          await ref.read(topicProgressProvider.notifier).loadUserProgress();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left side with icon and colored background
            Container(
              width: 90,
              height: 90,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Icon
                  Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 40,
                      color: color,
                    ),
                  ),

                  // Progress indicator if logged in
                  if (progress > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '%${progress.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Topic content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      topic.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      topic.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Progress bar if logged in
                    if (progress > 0) ...[
                      const SizedBox(height: 8),
                      // Progress bar
                      Stack(
                        children: [
                          // Background
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // Progress
                          Container(
                            height: 4,
                            width: (MediaQuery.of(context).size.width - 160) *
                                (progress / 100),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Arrow on the right
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1D2939),
        ),
        decoration: InputDecoration(
          hintText: l10n.search_placeholder,
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                  },
                  child: Icon(
                    Icons.close,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                )
              : null,
        ),
        onSubmitted: (value) {
          // Hide keyboard
          FocusScope.of(context).unfocus();
        },
        onChanged: (value) {
          // Update search query
          ref.read(searchQueryProvider.notifier).state = value;

          // When searching, always set filter to "Tümü" (All)
          if (value.isNotEmpty) {
            ref.read(selectedFilterProvider.notifier).state = 'Tümü';
          }
        },
      ),
    );
  }

  Widget _buildAppBar(bool isDark, int resultCount, bool isLoggedIn,
      List<String> grammarCategories, AppLocalizations l10n) {
    final isSearching = ref.watch(isSearchingProvider);
    final authState = ref.watch(authProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isSearching
                  ? GestureDetector(
                      onTap: () {
                        // Exit search mode
                        ref.read(isSearchingProvider.notifier).state = false;
                        ref.read(searchQueryProvider.notifier).state = '';
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF667085),
                          size: 22,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Englitics',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : const Color(0xFF1D2939),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSearching
                              ? '$resultCount ${l10n.results_found}'
                              : l10n.app_subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
              Row(
                children: [
                  _buildPremiumButton(),
                  // Account button - redirects to login/profile
                  /*  GestureDetector(
                    onTap: () {
                      final isLoggedIn = ref.read(authProvider).isLoggedIn;
                      if (isLoggedIn) {
                        // Kullanıcı giriş yapmışsa global showUserMenu fonksiyonunu kullan
                        showUserMenu(context, ref, isDark);
                      } else {
                        _showAuthDialog(context, isDark);
                      }
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isLoggedIn
                            ? AppColors.primary
                            : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isLoggedIn
                                ? AppColors.primary.withOpacity(0.3)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: isLoggedIn &&
                              authState.username != null &&
                              authState.username!.isNotEmpty
                          ? Center(
                              child: Text(
                                "E",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person_outline,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF667085),
                              size: 22,
                            ),
                    ),
                  ),*/
                  // Search button
                  GestureDetector(
                    onTap: () {
                      // Toggle search mode
                      ref
                          .read(isSearchingProvider.notifier)
                          .update((state) => !state);
                      if (!isSearching) {
                        // When entering search mode, automatically set filter to "All"
                        ref.read(selectedFilterProvider.notifier).state =
                            l10n.all;

                        // Focus the search field immediately
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          FocusScope.of(context).requestFocus(_searchFocusNode);
                        });
                      } else {
                        // Clear search when exiting search mode
                        ref.read(searchQueryProvider.notifier).state = '';
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isSearching ? Icons.close : Icons.search_rounded,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF667085),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isSearching) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: grammarCategories
                    .map((category) => _buildFilterChip(isDark, category))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Arama sonuçları bilgisi
          if (isSearching && searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '"$searchQuery" için $resultCount sonuç',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(bool isDark, String label) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final isSelected = selectedFilter == label;
    final isSearching = ref.watch(isSearchingProvider);
    final isSearchingActive =
        isSearching && ref.watch(searchQueryProvider).isNotEmpty;

    return GestureDetector(
      onTap: () {
        // Don't allow filter changes while actively searching
        if (isSearchingActive) return;

        // Update selected filter
        ref.read(selectedFilterProvider.notifier).state = label;
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.white70
                          .withOpacity(isSearchingActive ? 0.5 : 1.0)
                      : Color(0xFF667085)
                          .withOpacity(isSearchingActive ? 0.5 : 1.0),
            ),
          ),
        ),
      ),
    );
  }

  // Add this method to show the authentication dialog
  void _showAuthDialog(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    // Get the auth state
    final authState = ref.read(authProvider);

    // Popup menu pozisyonunu hesapla - avatar'ın hemen altında
    showMenu(
      context: context,
      color: Colors.transparent,
      elevation: 0,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width -
            220 -
            20, // Sol taraftan (Sağa hizalı)
        kToolbarHeight +
            MediaQuery.of(context).padding.top +
            10, // Avatar'ın hemen altı
        20, // Sağdan
        0, // Alttan (önemsiz)
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // App icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'E',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // App info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Englitics',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.english_app,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.withOpacity(0.1)),

                  // Login/Logout button
                  if (!authState.isLoggedIn)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context); // Menüyü kapat
                        // Navigate to login screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.login_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Giriş Yap',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (authState.isLoggedIn)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context); // Menüyü kapat
                        // Log user out directly
                        ref.read(authProvider.notifier).logout();

                        // Show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Çıkış yapıldı',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green.shade600,
                            margin: const EdgeInsets.only(
                                bottom: 80, left: 40, right: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Çıkış Yap',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
        ),
      ],
    );
  }

  Widget _buildPremiumButton() {
    return SubscriptionButton(
      uiConfig: SubscriptionScreenUiConfig(
        activePackageText: "Aktif paket",
        description:
            "Hizmetimize abone olarak reklamları kaldırın ve tüm özelliklerin kilidini açın",
        editingSavePercentageText: (value) => "${value}  % tasarruf et",
        includesTitle: "İçerir",
        popularBadgeText: "Popüler",
        purchaseButtonTitle: "Abone Ol",
        restorePurchases: "Satın Alımları Geri Yükle",
        title: "Size en uygun planı seçin",
        specialOfferTitle: "Özel Teklifi Göster",
        editingTrialDaysText: (value, periodUnit) {
          switch (periodUnit) {
            case PeriodUnit.day:
              return "$value günlük deneme";
            case PeriodUnit.month:
              return "$value aylık deneme";
            case PeriodUnit.year:
              return "$value yıllık deneme";
            case PeriodUnit.week:
              return "$value haftalık deneme";
            default:
              return "";
          }
        },
        features: [
          FeatureItem(
            title: "Tüm özelliklere sınırsız erişim",
            icon: const Icon(Icons.check_circle),
          ),
          FeatureItem(
            title: "Reklamsız kullanım",
            description: "Tüm Özelliklere reklamsız erişim",
            icon: const Icon(Icons.analytics_outlined),
          ),
        ],
        packagesTextConfig: PackagesTextConfig(
          annualPackageText: "Yıllık Paket",
          customPackageText: "Özel Paket",
          lifetimePackageText: "Ömür Boyu",
          monthlyPackageText: "Aylık Paket",
          sixMonthPackageText: "6 Aylık Paket",
          threeMonthPackageText: "3 Aylık Paket",
          twoMonthPackageText: "2 Aylık Paket",
          unknowPackageText: "Bilinmeyen Paket",
          weeklyPackageText: "Haftalık Paket",
        ),
      ),
      onPaywallResult: (result) {},
    );
  }
}
