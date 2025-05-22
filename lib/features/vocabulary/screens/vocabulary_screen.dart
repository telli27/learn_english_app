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
  bool _isCardFlipped = false;

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
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                    _isCardFlipped = false;
                  });
                },
              )
            : Text(
                'Kelime Kartları',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Kartlar'),
                Tab(text: 'Quiz'),
              ],
            ),
          ),
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
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  // Generate a random index different from current
                  if (ref.watch(filteredFlashcardsProvider).maybeWhen(
                        data: (flashcards) => flashcards.length > 1,
                        orElse: () => false,
                      )) {
                    int newIndex;
                    final flashcardsLength =
                        ref.watch(filteredFlashcardsProvider).maybeWhen(
                              data: (flashcards) => flashcards.length,
                              orElse: () => 0,
                            );
                    if (flashcardsLength > 0) {
                      do {
                        newIndex = Random().nextInt(flashcardsLength);
                      } while (newIndex == _currentIndex);
                      _currentIndex = newIndex;
                      _isCardFlipped = false;
                    }
                  }
                });
              },
              backgroundColor: primaryColor,
              elevation: 4,
              child: const Icon(Icons.shuffle, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFlashcardsTab(bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;
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
        // Categories filter with horizontal scroll
        if (_searchQuery.isEmpty)
          categories.when(
            data: (categoriesList) => Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 40,
              child: CategoryFilter(
                categories: categoriesList,
                selectedCategory: ref.watch(selectedCategoryProvider),
                onCategorySelected: (category) {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                  setState(() {
                    _currentIndex = 0;
                    _isCardFlipped = false;
                  });
                },
              ),
            ),
            loading: () => const SizedBox(
                height: 40, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(
                height: 40,
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
                  // Card Counter and Favorites Toggle
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Card count display
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${flashcards.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),

                        // Favorites toggle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showingFavorites = !_showingFavorites;
                              _currentIndex = 0;
                              _isCardFlipped = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _showingFavorites
                                  ? Colors.red.withOpacity(0.1)
                                  : isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _showingFavorites
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: _showingFavorites
                                      ? Colors.red
                                      : isDark
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _showingFavorites
                                      ? 'Favoriler'
                                      : 'Tüm Kartlar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _showingFavorites
                                        ? Colors.red
                                        : isDark
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flashcard with animation
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCardFlipped = !_isCardFlipped;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            final rotate =
                                Tween(begin: 0.0, end: 1.0).animate(animation);
                            return AnimatedBuilder(
                              animation: rotate,
                              child: child,
                              builder: (context, child) {
                                final angle = rotate.value * pi;
                                return Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(angle),
                                  alignment: Alignment.center,
                                  child: child,
                                );
                              },
                            );
                          },
                          child: _isCardFlipped
                              ? _buildFlashcardBack(
                                  flashcards[_currentIndex], isDark)
                              : _buildFlashcardFront(
                                  flashcards[_currentIndex], isDark),
                        ),
                      ),
                    ),
                  ),

                  // Navigation controls
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Previous button
                        _buildNavigationButton(
                          icon: Icons.arrow_back_ios_rounded,
                          onPressed: _currentIndex > 0
                              ? () {
                                  setState(() {
                                    _currentIndex--;
                                    _isCardFlipped = false;
                                  });
                                }
                              : null,
                          isDark: isDark,
                          enabled: _currentIndex > 0,
                        ),

                        // Card flip button
                        _buildFlipButton(isDark),

                        // Favorite button for current card
                        _buildFavoriteButton(flashcards[_currentIndex], isDark),

                        // Next button
                        _buildNavigationButton(
                          icon: Icons.arrow_forward_ios_rounded,
                          onPressed: _currentIndex < flashcards.length - 1
                              ? () {
                                  setState(() {
                                    _currentIndex++;
                                    _isCardFlipped = false;
                                  });
                                }
                              : null,
                          isDark: isDark,
                          enabled: _currentIndex < flashcards.length - 1,
                        ),
                      ],
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

  Widget _buildFlashcardFront(Flashcard card, bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor
                .withBlue(min(primaryColor.blue + 30, 255))
                .withRed(max(primaryColor.red - 30, 0)),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Category badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(card.category),
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    card.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Difficulty badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDifficultyColor(card.difficulty).withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _getDifficultyIcon(card.difficulty),
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    card.difficulty,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image if available
                if (card.imageUrl.isNotEmpty)
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        card.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),

                // Word text
                Text(
                  card.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Tap to flip hint
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.touch_app,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Çevirmek için dokun',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
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

  Widget _buildFlashcardBack(Flashcard card, bool isDark) {
    final backColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original word reminder
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  card.word,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),

            // Translation
            Center(
              child: Text(
                card.translation,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Example section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Örnek Cümle:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.example,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Çeviri:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.exampleTranslation,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
    required bool enabled,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enabled
            ? isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: enabled
              ? (isDark ? Colors.white : Colors.black87)
              : (isDark ? Colors.white24 : Colors.black12),
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFlipButton(bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.flip,
          color: Colors.white,
          size: 24,
        ),
        onPressed: () {
          setState(() {
            _isCardFlipped = !_isCardFlipped;
          });
        },
      ),
    );
  }

  Widget _buildFavoriteButton(Flashcard card, bool isDark) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(
          card.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: card.isFavorite
              ? Colors.red
              : (isDark ? Colors.white70 : Colors.black54),
          size: 20,
        ),
        onPressed: () {
          ref.read(flashcardNotifierProvider.notifier).toggleFavorite(card.id);
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Education':
        return Icons.school;
      case 'Technology':
        return Icons.computer;
      case 'Home':
        return Icons.home;
      case 'Transportation':
        return Icons.directions_car;
      case 'Abstract':
        return Icons.psychology;
      case 'Finance':
        return Icons.attach_money;
      case 'Relationships':
        return Icons.people;
      case 'Travel':
        return Icons.flight;
      case 'Nature':
        return Icons.eco;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.favorite;
      case 'Shopping':
        return Icons.shopping_cart;
      default:
        return Icons.category;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Icons.star_border;
      case 'Intermediate':
        return Icons.star_half;
      case 'Advanced':
        return Icons.star;
      default:
        return Icons.star_border;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.green;
    }
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
