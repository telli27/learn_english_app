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
import '../providers/daily_word_provider.dart';
import '../providers/study_progress_provider.dart';
import '../providers/sentence_builder_provider.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/category_filter.dart';
import '../widgets/custom_card_form.dart';
import '../widgets/sentence_builder_widget.dart';
import 'package:intl/intl.dart';
import 'notification_settings_screen.dart';
import '../kelime oyunları/word_games_screen.dart';
import '../listening_practice/screens/listening_practice_screen.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define a more harmonious color scheme
    final backgroundColor = isDark
        ? const Color(0xFF1A1E2E) // Dark blue-gray background
        : const Color(0xFFF5F7FA); // Light gray-blue background

    final accentColor = isDark
        ? const Color(0xFF4A80F0) // Bright blue for dark mode
        : const Color(0xFF3D7AF0); // Slightly darker blue for light mode

    final cardColor = isDark
        ? const Color(0xFF252A3D) // Darker blue-gray for cards in dark mode
        : Colors.white; // White cards in light mode

    final textColor = isDark
        ? Colors.white
        : const Color(0xFF2C3550); // Dark blue-gray for text in light mode

    final secondaryTextColor = isDark
        ? const Color(
            0xFFABB2C5) // Light gray-blue for secondary text in dark mode
        : const Color(0xFF7E869C); // Gray-blue for secondary text in light mode

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelime Kartları',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              isDark
                  ? const Color(
                      0xFF161B2C) // Slightly darker shade for bottom in dark mode
                  : const Color(
                      0xFFEBEFF5), // Slightly darker shade for bottom in light mode
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Word Games Card
              _buildMenuCard(
                context: context,
                title: 'Kelime Oyunları',
                subtitle: 'Eğlenerek kelime bilginizi artırın',
                icon: Icons.sports_esports,
                gradient: [
                  const Color(0xFFFF6B6B), // Red
                  const Color(0xFFEE5253), // Darker red
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordGamesScreen(),
                    ),
                  );
                },
              ),
            

              const SizedBox(height: 20),

              // Listening Practice Card
              _buildMenuCard(
                context: context,
                title: 'Dinleme Pratiği',
                subtitle: 'İngilizce sesleri ve konuşmaları anlayın',
                icon: Icons.headphones,
                gradient: [
                  const Color(0xFFFD9644), // Orange
                  const Color(0xFFFA8231), // Darker orange
                ],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Çok Yakında'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ListeningPracticeScreen(),
                    ),
                  );*/
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakWidget(
      BuildContext context,
      int currentStreak,
      int dailyGoal,
      bool isDark,
      Color accentColor,
      Color cardColor,
      Color textColor) {
    final progressPercentage =
        min(1.0, 7 / 10); // Example: completed 7 out of 10 daily exercises

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Streak info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currentStreak Gün',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Çalışma serisi',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Daily goal progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Günlük Hedef',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dailyGoal alıştırma',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Stack(
            children: [
              // Background
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Progress
              FractionallySizedBox(
                widthFactor: progressPercentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7/$dailyGoal tamamlandı',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              Text(
                '3 alıştırma kaldı',
                style: TextStyle(
                  fontSize: 12,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyWordWidget(
      BuildContext context,
      bool isDark,
      Color accentColor,
      Color cardColor,
      Color textColor,
      Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Günün Kelimesi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      color: accentColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Günlük',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Word and pronunciation
          Text(
            'serendipity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),

          const SizedBox(height: 4),

          // Phonetic spelling
          Row(
            children: [
              Text(
                '/ˌserənˈdɪpɪti/',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.volume_up,
                size: 16,
                color: accentColor,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Definition
          Text(
            'İyi şansa bağlı hoş şeylerin keşfi; güzel sürprizler yaşama yeteneği',
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),

          const SizedBox(height: 12),

          // Example
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black12 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Örnek Cümle:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Finding your perfect career was a moment of serendipity.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mükemmel kariyerini bulmak bir tesadüf anıydı.',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Icon with background
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.white,
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
}
