import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'word_matching_game_screen.dart';
import 'level_selection_screen.dart';

class WordGamesScreen extends ConsumerStatefulWidget {
  const WordGamesScreen({super.key});

  @override
  ConsumerState<WordGamesScreen> createState() => _WordGamesScreenState();
}

class _WordGamesScreenState extends ConsumerState<WordGamesScreen> {
  // Most valuable language learning games
  static const List<Map<String, dynamic>> _gameOptions = [
    {
      'title': 'Kelime Eşleştirme',
      'description':
          'İngilizce kelimeleri Türkçe anlamlarıyla eşleştirerek daha hızlı öğrenin',
      'icon': Icons.compare_arrows,
      'color': Color(0xFF6C5CE7),
    },
    {
      'title': 'Kelime Hatırlama',
      'description':
          'Gösterilen kelimeleri belirli bir süre sonra hatırlayarak kalıcı öğrenme sağlayın',
      'icon': Icons.psychology,
      'color': Color(0xFF00B894),
    },
    {
      'title': 'Cümle Tamamlama',
      'description':
          'Eksik kelimeleri doldurarak cümle kurma yeteneğinizi geliştirin',
      'icon': Icons.format_align_left,
      'color': Color(0xFFFF7675),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2C3550);
    final backgroundColor =
        isDark ? const Color(0xFF1A1E2E) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF252A3D) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        title: Text(
          'Kelime Oyunları',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B6B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              'Kelimeleri eğlenceli bir şekilde öğrenin ve pratik yapın',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Games list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _gameOptions.length,
              itemBuilder: (context, index) {
                final game = _gameOptions[index];
                return _buildGameCard(
                  game,
                  cardColor,
                  textColor,
                  isDark,
                );
              },
            ),
          ),

          // Coming soon section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
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
                    children: [
                      Icon(
                        Icons.new_releases,
                        color: const Color(0xFFFFC107),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Yakında Eklenecek',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Telaffuz Pratiği, Test Sınavları, Deyimler ve daha fazlası...',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    Map<String, dynamic> game,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _launchGame(game),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: game['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    game['icon'] as IconData,
                    color: game['color'],
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                // Game details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: game['color'],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Oynamak için dokunun',
                            style: TextStyle(
                              color: game['color'],
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
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

  void _launchGame(Map<String, dynamic> game) {
    // Launch the appropriate game screen based on title
    if (game['title'] == 'Kelime Eşleştirme') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LevelSelectionScreen(),
        ),
      );
    } else {
      // Other games are coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${game['title']} oyunu yakında eklenecek!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
