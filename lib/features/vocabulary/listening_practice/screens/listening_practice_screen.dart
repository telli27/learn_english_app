import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../models/listening_models.dart';
import '../providers/listening_provider.dart';
import 'listening_level_detail_screen.dart';

/// Professional listening practice main screen with modern design
class ListeningPracticeScreen extends ConsumerStatefulWidget {
  const ListeningPracticeScreen({super.key});

  @override
  ConsumerState<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState
    extends ConsumerState<ListeningPracticeScreen>
    with TickerProviderStateMixin {
  /// Animation controllers
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _statsAnimationController;
  late AnimationController _floatingAnimationController;

  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _floatingAnimation;

  /// Current filter
  ListeningDifficulty? _selectedDifficulty;
  ListeningTopic? _selectedTopic;

  /// Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    _statsAnimationController.dispose();
    _floatingAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize animations with professional timing
  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutExpo,
    );
    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutCubic,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.elasticOut,
    );
    _floatingAnimation = CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    );

    // Staggered animation sequence
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _statsAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _cardsAnimationController.forward();
    });

    // Continuous floating animation
    _floatingAnimationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final levels = ref.watch(listeningLevelsProvider);
    final progress = ref.watch(listeningProgressProvider);

    // Professional color scheme
    final primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF667EEA),
        const Color(0xFF764BA2),
      ],
    );

    final secondaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFF093FB),
        const Color(0xFFF5576C),
      ],
    );

    final backgroundColor =
        isDarkMode ? const Color(0xFF0A0E27) : const Color(0xFFF8FAFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Professional app bar
          _buildProfessionalAppBar(primaryGradient, isDarkMode),

          // Statistics overview
          SliverToBoxAdapter(
            child:
                _buildStatisticsOverview(progress, primaryGradient, isDarkMode),
          ),

          // Search and filters
          SliverToBoxAdapter(
            child: _buildSearchAndFilters(primaryGradient, isDarkMode),
          ),

          // Levels grid with professional design
          _buildProfessionalLevelsGrid(
              levels, primaryGradient, secondaryGradient, isDarkMode),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Floating action button for quick access
      floatingActionButton: _buildFloatingActionButton(primaryGradient),
    );
  }

  /// Build professional app bar with glassmorphism effect
  Widget _buildProfessionalAppBar(
      LinearGradient primaryGradient, bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          final animationValue = _headerAnimation.value.clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(0, -50 * (1 - animationValue)),
            child: Opacity(
              opacity: animationValue,
              child: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated background pattern
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _ProfessionalBackgroundPainter(
                                animation:
                                    _floatingAnimation.value.clamp(0.0, 1.0),
                                isDarkMode: isDarkMode,
                              ),
                            );
                          },
                        ),
                      ),

                      // Content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row
                              Row(
                                children: [
                                  _buildGlassmorphicButton(
                                    icon: Icons.arrow_back_ios_new,
                                    onTap: () => Navigator.pop(context),
                                  ),
                                  const Spacer(),
                                  _buildGlassmorphicButton(
                                    icon: Icons.settings,
                                    onTap: _showAdvancedSettings,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Title section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Listening Practice',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Master English through immersive audio experiences',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Quick stats
                              _buildQuickStats(isDarkMode),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build glassmorphic button
  Widget _buildGlassmorphicButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Build quick stats
  Widget _buildQuickStats(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildStatItem('12', 'Levels', Icons.layers),
          const SizedBox(width: 24),
          _buildStatItem('45', 'Stories', Icons.book),
          const SizedBox(width: 24),
          _buildStatItem('8.5h', 'Content', Icons.schedule),
        ],
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build statistics overview
  Widget _buildStatisticsOverview(
    ListeningProgress progress,
    LinearGradient primaryGradient,
    bool isDarkMode,
  ) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        final animationValue = _statsAnimation.value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 0.8 + (0.2 * animationValue),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Keep up the great work!',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Progress metrics
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressMetric(
                          'Stories Completed',
                          '${progress.totalStoriesCompleted}',
                          Icons.check_circle,
                          const Color(0xFF4CAF50),
                          isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildProgressMetric(
                          'Average Score',
                          '${progress.averageComprehensionScore.round()}%',
                          Icons.star,
                          const Color(0xFFFF9800),
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build progress metric
  Widget _buildProgressMetric(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build search and filters
  Widget _buildSearchAndFilters(
      LinearGradient primaryGradient, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search levels, topics, or stories...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: Icon(
                          Icons.clear,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'All Levels',
                  _selectedDifficulty == null,
                  () => setState(() => _selectedDifficulty = null),
                  primaryGradient,
                  isDarkMode,
                ),
                const SizedBox(width: 12),
                ...ListeningDifficulty.values.map((difficulty) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildFilterChip(
                      _getDifficultyText(difficulty),
                      _selectedDifficulty == difficulty,
                      () => setState(() => _selectedDifficulty = difficulty),
                      primaryGradient,
                      isDarkMode,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build professional filter chip
  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    LinearGradient primaryGradient,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected ? primaryGradient : null,
        color: isSelected
            ? null
            : (isDarkMode ? const Color(0xFF1A1F3A) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.grey[700]),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build professional levels grid
  Widget _buildProfessionalLevelsGrid(
    List<ListeningLevel> levels,
    LinearGradient primaryGradient,
    LinearGradient secondaryGradient,
    bool isDarkMode,
  ) {
    final filteredLevels = _getFilteredLevels(levels);

    if (filteredLevels.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(primaryGradient, isDarkMode),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      sliver: AnimatedBuilder(
        animation: _cardsAnimation,
        builder: (context, child) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final level = filteredLevels[index];
                final delay = index * 0.1;
                final animationValue = math
                    .max(0.0,
                        math.min(1.0, (_cardsAnimation.value - delay) / 0.3))
                    .clamp(0.0, 1.0);

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: _buildProfessionalLevelCard(
                      level: level,
                      primaryGradient: primaryGradient,
                      secondaryGradient: secondaryGradient,
                      isDarkMode: isDarkMode,
                      index: index,
                    ),
                  ),
                );
              },
              childCount: filteredLevels.length,
            ),
          );
        },
      ),
    );
  }

  /// Build professional level card
  Widget _buildProfessionalLevelCard({
    required ListeningLevel level,
    required LinearGradient primaryGradient,
    required LinearGradient secondaryGradient,
    required bool isDarkMode,
    required int index,
  }) {
    final isLocked =
        level.isPremium && !ref.watch(isLevelUnlockedProvider(level));

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: isLocked
              ? () => _showPremiumDialog(level)
              : () => _navigateToLevel(level),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLocked
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Background gradient overlay
                if (!isLocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            const Color(0xFF667EEA).withOpacity(0.05),
                            const Color(0xFF764BA2).withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Row(
                        children: [
                          // Level icon with professional styling
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: isLocked ? null : primaryGradient,
                              color: isLocked ? Colors.grey.shade400 : null,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                if (!isLocked)
                                  BoxShadow(
                                    color: const Color(0xFF667EEA)
                                        .withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    isLocked ? Icons.lock : Icons.headphones,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                if (!isLocked)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${level.stories.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Title and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        level.title,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                    if (isLocked)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: secondaryGradient,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'PRO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  level.description,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Difficulty badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(level.difficulty)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getDifficultyColor(level.difficulty)
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getDifficultyText(level.difficulty),
                              style: TextStyle(
                                color: _getDifficultyColor(level.difficulty),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Professional stats section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : const Color(0xFFE8EEFF),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildLevelStatItem(
                                icon: Icons.book_outlined,
                                label: 'Stories',
                                value: '${level.stories.length}',
                                color: const Color(0xFF667EEA),
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : const Color(0xFFE8EEFF),
                            ),
                            Expanded(
                              child: _buildLevelStatItem(
                                icon: Icons.schedule_outlined,
                                label: 'Duration',
                                value: '${level.estimatedDuration}min',
                                color: const Color(0xFF764BA2),
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : const Color(0xFFE8EEFF),
                            ),
                            Expanded(
                              child: _buildLevelStatItem(
                                icon: Icons.category_outlined,
                                label: 'Topic',
                                value: level.topic.displayName.split(' ').first,
                                color: const Color(0xFFF5576C),
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Professional action button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isLocked ? null : primaryGradient,
                          color: isLocked ? Colors.grey.shade400 : null,
                          boxShadow: [
                            if (!isLocked)
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: isLocked
                                ? () => _showPremiumDialog(level)
                                : () => _navigateToLevel(level),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isLocked ? Icons.lock : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isLocked
                                        ? 'Upgrade to Pro'
                                        : 'Start Listening',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  if (!isLocked) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.headphones,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build level stat item with professional styling
  Widget _buildLevelStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white60 : Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState(LinearGradient primaryGradient, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.search_off,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No levels found',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your search or filters to find what you\'re looking for.',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(LinearGradient primaryGradient) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        final animationValue = _floatingAnimation.value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 5 * math.sin(animationValue * 2 * math.pi)),
          child: Container(
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _showQuickStart,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods remain the same...
  List<ListeningLevel> _getFilteredLevels(List<ListeningLevel> levels) {
    var filtered = levels;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((level) {
        return level.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            level.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            level.topic.displayName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedDifficulty != null) {
      filtered = filtered
          .where((level) => level.difficulty == _selectedDifficulty)
          .toList();
    }

    return filtered;
  }

  Color _getDifficultyColor(ListeningDifficulty difficulty) {
    switch (difficulty) {
      case ListeningDifficulty.beginner:
        return const Color(0xFF4CAF50);
      case ListeningDifficulty.intermediate:
        return const Color(0xFFFF9800);
      case ListeningDifficulty.advanced:
        return const Color(0xFFE91E63);
      case ListeningDifficulty.native:
        return const Color(0xFF9C27B0);
    }
  }

  String _getDifficultyText(ListeningDifficulty difficulty) {
    switch (difficulty) {
      case ListeningDifficulty.beginner:
        return 'Beginner';
      case ListeningDifficulty.intermediate:
        return 'Intermediate';
      case ListeningDifficulty.advanced:
        return 'Advanced';
      case ListeningDifficulty.native:
        return 'Native';
    }
  }

  void _navigateToLevel(ListeningLevel level) async {
    HapticFeedback.mediumImpact();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListeningLevelDetailScreen(level: level),
        ),
      );
    }
  }

  void _showPremiumDialog(ListeningLevel level) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Premium Feature',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This level is available for premium users. Upgrade to access all listening exercises.',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upgrade',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdvancedSettings() {
    // Advanced settings implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced settings coming soon!')),
    );
  }

  void _showQuickStart() {
    // Quick start implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quick start feature coming soon!')),
    );
  }
}

/// Professional background painter
class _ProfessionalBackgroundPainter extends CustomPainter {
  final double animation;
  final bool isDarkMode;

  _ProfessionalBackgroundPainter({
    required this.animation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final safeAnimation = animation.clamp(0.0, 1.0);

    // Draw floating circles
    for (int i = 0; i < 8; i++) {
      final x = (i * size.width / 7) +
          (20 * math.sin(safeAnimation * 2 * math.pi + i));
      final y = (i * size.height / 7) +
          (15 * math.cos(safeAnimation * 2 * math.pi + i));
      final radius =
          30 + (10 * math.sin(safeAnimation * 2 * math.pi + i * 0.5));

      canvas.drawCircle(
        Offset(x, y),
        radius.clamp(10.0, 50.0), // Radius'u da güvenli aralıkta tut
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
