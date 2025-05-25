import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../kelime oyunları/kelime eşleştirme/word_matching_game_screen.dart';

class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tema durumunu al
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Tema'ya bağlı renkler
    final primaryColor =
        const Color(0xFF6C5CE7); // Ana mor renk tutarlı kalacak
    final backgroundColor =
        isDarkMode ? const Color(0xFF1F2247) : Colors.grey.shade50;
    final cardColor = isDarkMode ? const Color(0xFF2A2E5A) : Colors.white;
    final headerTextColor = Colors.white; // Başlık her zaman beyaz
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final levels = [
      {
        'level': 1,
        'title': 'Başlangıç',
        'description': 'Temel kelimeler',
        'words': 5,
        'difficulty': 'Kolay',
        'color': const Color(0xFF6C5CE7),
        'icon': Icons.emoji_events,
      },
      {
        'level': 2,
        'title': 'Orta Seviye',
        'description': 'Günlük kelimeler',
        'words': 6,
        'difficulty': 'Orta',
        'color': const Color(0xFF00CECE),
        'icon': Icons.psychology,
      },
      {
        'level': 3,
        'title': 'İleri',
        'description': 'Kompleks kelimeler',
        'words': 7,
        'difficulty': 'Zor',
        'color': const Color(0xFFFF7675),
        'icon': Icons.workspace_premium,
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Seviye Seçimi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelime Eşleştirme',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'İngilizce kelimelerle Türkçe karşılıklarını eşleştir!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoItem(Icons.timer, '60 saniye'),
                    _buildInfoItem(Icons.emoji_events, 'Puan kazan'),
                    _buildInfoItem(Icons.school, 'Kelime öğren'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seviyeler',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Seviyeni Seç',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return _buildLevelCard(context, level, cardColor, textColor,
                    secondaryTextColor, isDarkMode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, Map<String, dynamic> level,
      Color cardColor, Color textColor, Color secondaryTextColor, isDarkMode) {
    final Color levelColor = level['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        border: isDarkMode
            ? Border.all(color: Color(0xFF1F2247))
            : Border.all(color: const Color.fromARGB(255, 233, 232, 232)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: levelColor.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WordMatchingGameScreen(
                  initialLevel: level['level'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Icon(
                      level['icon'],
                      color: levelColor,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level['title'],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level['description'],
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildLevelInfoTag(
                            '${level['words']} kelime',
                            cardColor,
                            secondaryTextColor,
                          ),
                          const SizedBox(width: 8),
                          _buildLevelInfoTag(
                            level['difficulty'],
                            levelColor.withOpacity(0.9),
                            Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: levelColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelInfoTag(String text, Color bgColor, Color textColor) {
    final isDarkBg =
        ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
