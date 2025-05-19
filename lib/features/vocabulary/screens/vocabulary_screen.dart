import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../core/providers.dart';
import '../../../core/models/grammar_topic.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../features/grammar/screens/grammar_topic_screen.dart';
import '../../../screens/topic_detail_screen.dart';
import '../../../core/data/grammar_data.dart';
import '../../../utils/update_dialog.dart';
import '../../../auth/screens/login_screen.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../core/providers/topic_progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../providers/daily_word_provider.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/category_filter.dart';
import '../widgets/quiz_widget.dart';
import '../widgets/custom_card_form.dart';
import '../widgets/daily_word_widget.dart';
import 'package:intl/intl.dart';

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showingFavorites = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          // Reset state when changing tabs
          _isSearching = false;
          _searchQuery = '';
          _searchController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Kelime ara...',
                  hintStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentIndex = 0;
                  });
                },
              )
            : Text(
                'Kelime Kartları',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
        backgroundColor: isDark ? const Color(0xFF242424) : Colors.white,
        elevation: 0,
        actions: [
          // Search button
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          // Favorites button (only show in flashcards tab)
          if (_tabController.index == 0)
            IconButton(
              icon: Icon(
                _showingFavorites ? Icons.favorite : Icons.favorite_border,
                color: _showingFavorites
                    ? Colors.red
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
              onPressed: () {
                setState(() {
                  _showingFavorites = !_showingFavorites;
                  _currentIndex = 0;
                });
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          tabs: const [
            Tab(text: 'Kartlar'),
            Tab(text: 'Quiz'),
            Tab(text: 'Kendi Kartlarım'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Flashcards Tab
          _buildFlashcardsTab(isDark),

          // Quiz Tab
          _buildQuizTab(isDark),

          // My Cards Tab
          _buildMyCardsTab(isDark),
        ],
      ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton(
              onPressed: _showAddCardDialog,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFlashcardsTab(bool isDark) {
    final filteredCardsProvider = _searchQuery.isNotEmpty
        ? Provider<AsyncValue<List<Flashcard>>>((ref) {
            final allCards = _showingFavorites
                ? ref.watch(favoriteFlashcardsProvider)
                : ref.watch(filteredFlashcardsProvider);

            return allCards.whenData((cards) {
              return cards
                  .where((card) =>
                      card.word
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      card.translation
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList();
            });
          })
        : _showingFavorites
            ? favoriteFlashcardsProvider
            : filteredFlashcardsProvider;

    final flashcardsAsync = ref.watch(filteredCardsProvider);
    final categories = ref.watch(categoriesProvider);

    return Column(
      children: [
        // Categories filter
        if (_searchQuery.isEmpty)
          categories.when(
            data: (categoriesList) => CategoryFilter(
              categories: categoriesList,
              selectedCategory: ref.watch(selectedCategoryProvider),
              onCategorySelected: (category) {
                ref.read(selectedCategoryProvider.notifier).state = category;
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            loading: () => const SizedBox(
                height: 50, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(
                height: 50,
                child: Center(child: Text('Kategoriler yüklenemedi'))),
          ),

        // Flashcards
        Expanded(
          child: flashcardsAsync.when(
            data: (flashcards) {
              if (flashcards.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : _showingFavorites
                                ? Icons.favorite_border
                                : Icons.menu_book,
                        size: 64,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Arama sonucu bulunamadı'
                            : _showingFavorites
                                ? 'Favori kelime kartınız bulunmamaktadır'
                                : 'Bu kategoride kelime kartı bulunmamaktadır',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Flashcard
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FlashcardWidget(
                        flashcard: flashcards[_currentIndex],
                        onFavoriteToggle: () {
                          ref
                              .read(flashcardNotifierProvider.notifier)
                              .toggleFavorite(
                                flashcards[_currentIndex].id,
                              );
                        },
                      ),
                    ),
                  ),

                  // Navigation controls
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous button
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: _currentIndex > 0
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white24 : Colors.black12),
                          ),
                          onPressed: _currentIndex > 0
                              ? () {
                                  setState(() {
                                    _currentIndex--;
                                  });
                                }
                              : null,
                        ),

                        // Card index indicator
                        Text(
                          '${_currentIndex + 1} / ${flashcards.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),

                        // Next button
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: _currentIndex < flashcards.length - 1
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white24 : Colors.black12),
                          ),
                          onPressed: _currentIndex < flashcards.length - 1
                              ? () {
                                  setState(() {
                                    _currentIndex++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),

                  // Shuffle button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          // Generate a random index different from current
                          if (flashcards.length > 1) {
                            int newIndex;
                            do {
                              newIndex = Random().nextInt(flashcards.length);
                            } while (newIndex == _currentIndex);
                            _currentIndex = newIndex;
                          }
                        });
                      },
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Karıştır'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(
                'Kelime kartları yüklenemedi',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizTab(bool isDark) {
    final flashcardsAsync = ref.watch(filteredFlashcardsProvider);

    return flashcardsAsync.when(
      data: (flashcards) {
        if (flashcards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz,
                  size: 64,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
                const SizedBox(height: 16),
                Text(
                  'Quiz için kelime kartı bulunamadı',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return QuizWidget(flashcards: flashcards);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(
          'Kelime kartları yüklenemedi',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildMyCardsTab(bool isDark) {
    final customCardsAsync = ref.watch(customFlashcardsProvider);
    final todayWordAsync = ref.watch(todayWordProvider);
    final weeklyWordsAsync = ref.watch(weeklyWordsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Today's Word Section
          Expanded(
            child: todayWordAsync.when(
              data: (todayWord) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Today's word
                      DailyWordWidget(
                        word: todayWord,
                        onAddToCollection: () {
                          // Refresh custom cards list after adding
                          ref.refresh(customFlashcardsProvider);
                        },
                      ),

                      const SizedBox(height: 32),

                      // Past words section header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 20,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Geçmiş Kelimeler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Past daily words
                      weeklyWordsAsync.when(
                        data: (weeklyWords) {
                          // Skip today's word
                          final pastWords = weeklyWords.skip(1).toList();

                          if (pastWords.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black12
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 48,
                                    color: isDark
                                        ? Colors.white30
                                        : Colors.black26,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Henüz geçmiş kelime bulunmamaktadır',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                pastWords.length > 6 ? 6 : pastWords.length,
                            itemBuilder: (context, index) {
                              // Use Card instead of DailyWordListTile
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Show bottom sheet with full daily word
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          DraggableScrollableSheet(
                                        initialChildSize: 0.9,
                                        maxChildSize: 0.9,
                                        minChildSize: 0.5,
                                        builder: (_, controller) => Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            ),
                                          ),
                                          child: ListView(
                                            controller: controller,
                                            padding: const EdgeInsets.all(20),
                                            children: [
                                              DailyWordWidget(
                                                word: pastWords[index],
                                                onAddToCollection: () {
                                                  // Refresh custom cards list after adding
                                                  ref.refresh(
                                                      customFlashcardsProvider);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // Date container
                                        Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                DateFormat('d').format(
                                                    pastWords[index].date),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('MMM').format(
                                                    pastWords[index].date),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Word info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pastWords[index].word,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                pastWords[index].translation,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Saved indicator
                                        if (pastWords[index].saved)
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.green.shade700,
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => Center(
                          child: Text(
                            'Kelimeler yüklenemedi',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),

                      // View your flashcards button if user has custom cards
                      customCardsAsync.when(
                        data: (cards) {
                          if (cards.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 32.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Show custom card management screen or dialog
                                  _showCustomCardsDialog();
                                },
                                icon: const Icon(Icons.collections_bookmark),
                                label: const Text('Kelime Koleksiyonum'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Günün kelimesi yüklenemedi',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(dailyWordProvider.notifier).loadDailyWords();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: CustomCardForm(
            onSave: (flashcard) {
              ref
                  .read(flashcardNotifierProvider.notifier)
                  .addFlashcard(flashcard);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showEditCardDialog(Flashcard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: CustomCardForm(
            initialFlashcard: card,
            onSave: (flashcard) {
              ref
                  .read(flashcardNotifierProvider.notifier)
                  .updateFlashcard(flashcard);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showCustomCardsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kelime Koleksiyonum',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showAddCardDialog,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final customCards = ref.watch(customFlashcardsProvider);

                    return customCards.when(
                      data: (cards) {
                        if (cards.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_add,
                                  size: 64,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white38
                                      : Colors.black26,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Henüz bir kelime kaydetmediniz',
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showAddCardDialog();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Kart Ekle'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            return Dismissible(
                              key: Key(card.id),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) {
                                ref
                                    .read(flashcardNotifierProvider.notifier)
                                    .deleteFlashcard(card.id);
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    card.word,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        card.translation,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                      if (card.example.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          card.example,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white60
                                                    : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      card.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          card.isFavorite ? Colors.red : null,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(flashcardNotifierProvider
                                              .notifier)
                                          .toggleFavorite(card.id);
                                    },
                                  ),
                                  onTap: () => _showEditCardDialog(card),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Center(
                        child: Text(
                          'Özel kartlar yüklenemedi',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
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
      ),
    );
  }
}
