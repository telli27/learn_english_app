import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grammar_provider.dart';
import '../providers/theme_provider.dart';
import '../models/grammar_topic.dart';
import '../screens/topic_detail_screen.dart';
import '../screens/exercise_detail_screen.dart';
import '../screens/exercise_quiz_screen.dart';
import '../utils/constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GrammarProvider>(context, listen: false).loadGrammarTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181818) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Engly',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<GrammarProvider>(
        builder: (context, grammarProvider, child) {
          if (grammarProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (grammarProvider.topics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 64,
                    color: isDark ? Colors.white70 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ders bulunmuyor',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grammarProvider.topics.length,
            itemBuilder: (context, index) {
              final topic = grammarProvider.topics[index];
              return _buildTopicCard(context, topic, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(
      BuildContext context, GrammarTopic topic, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TopicDetailScreen(topicId: topic.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF4F6CFF).withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isDark
                        ? Border.all(
                            color: const Color(0xFF4F6CFF).withOpacity(0.2),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: isDark ? const Color(0xFF4F6CFF) : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white.withOpacity(0.95)
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Search functionality implementation
class TopicSearchDelegate extends SearchDelegate {
  final List<String> searchResults = [
    'Kelimeler',
    'Cümleler',
    'Fiiller',
    'Zamirler',
    'Sıfatlar',
    'Zarflar',
    'İsim Tamlamaları',
    'Sıfat Tamlamaları',
    'Zaman Ekleri',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var result in searchResults) {
      if (result.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(result);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(matchQuery[index]),
          onTap: () {
            // Navigate to topic detail
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var result in searchResults) {
      if (result.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(result);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(matchQuery[index]),
          onTap: () {
            // Navigate to topic detail
            query = matchQuery[index];
            showResults(context);
          },
        );
      },
    );
  }
}

// Alıştırma seviyesi veri modeli
class ExerciseLevel {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int exercises;

  ExerciseLevel({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.exercises,
  });
}

// Alıştırma türü veri modeli
class ExerciseType {
  final String name;
  final IconData icon;
  final int count;

  ExerciseType({
    required this.name,
    required this.icon,
    required this.count,
  });
}

// Popüler alıştırma veri modeli
class PopularExercise {
  final String title;
  final String level;
  final int questions;
  final IconData icon;

  PopularExercise({
    required this.title,
    required this.level,
    required this.questions,
    required this.icon,
  });
}
