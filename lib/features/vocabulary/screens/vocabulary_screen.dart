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
import '../providers/study_progress_provider.dart';
import '../providers/sentence_builder_provider.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/category_filter.dart';
import '../widgets/quiz_widget.dart';
import '../widgets/custom_card_form.dart';
import '../widgets/daily_word_widget.dart';
import '../widgets/sentence_builder_widget.dart';
import 'package:intl/intl.dart';
import 'notification_settings_screen.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
          // Notification settings button
          if (_tabController.index == 1)
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
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
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          tabs: const [
            Tab(text: 'Kartlar'),
            Tab(text: 'Quiz'),
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
        ],
      ),
      floatingActionButton: null,
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
                      padding: const EdgeInsets.all(0.0),
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
}
