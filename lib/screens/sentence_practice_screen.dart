import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants/colors.dart';
import 'sentence_exercise_screen.dart';

class SentencePracticeScreen extends StatefulWidget {
  const SentencePracticeScreen({Key? key}) : super(key: key);

  @override
  State<SentencePracticeScreen> createState() => _SentencePracticeScreenState();
}

class _SentencePracticeScreenState extends State<SentencePracticeScreen> {
  // Grammar topics for sentence construction
  final List<Map<String, dynamic>> _topics = [
    {
      'title': 'Present Simple',
      'icon': Icons.access_time,
      'color': const Color(0xFF4F6CFF),
      'description': 'Geniş zaman cümle kurma alıştırmaları',
    },
    {
      'title': 'Present Continuous',
      'icon': Icons.play_circle_outline,
      'color': const Color(0xFFFF9500),
      'description': 'Şimdiki zaman cümle kurma alıştırmaları',
    },
    {
      'title': 'Past Simple',
      'icon': Icons.history,
      'color': const Color(0xFF00BFA5),
      'description': 'Geçmiş zaman cümle kurma alıştırmaları',
    },
    {
      'title': 'Future Tense',
      'icon': Icons.update,
      'color': const Color(0xFFFF375F),
      'description': 'Gelecek zaman cümle kurma alıştırmaları',
    },
    {
      'title': 'Question Forms',
      'icon': Icons.help_outline,
      'color': const Color(0xFF8E44AD),
      'description': 'Soru cümleleri oluşturma alıştırmaları',
    },
    {
      'title': 'Passive Voice',
      'icon': Icons.switch_right,
      'color': const Color(0xFF2E7D32),
      'description': 'Pasif cümle yapıları alıştırmaları',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cümle Kurma Alıştırmaları',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _topics.length,
          itemBuilder: (context, index) {
            final topic = _topics[index];
            return _buildTopicCard(context, topic, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildTopicCard(
      BuildContext context, Map<String, dynamic> topic, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF242424) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SentenceExerciseScreen(
                topic: topic['title'],
                color: topic['color'],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: topic['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  topic['icon'],
                  size: 30,
                  color: topic['color'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey[400]
                            : Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey[600] : Colors.black45,
              )
            ],
          ),
        ),
      ),
    );
  }
}
