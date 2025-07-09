import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';

import '../../../core/providers.dart';
import 'kelime eşleştirme/word_matching_game_screen.dart';
import 'kelime eşleştirme/word_matching_levels_screen.dart';
import 'kelime hatırlama/word_recall_levels_screen.dart';
import 'cümle tamamlama/sentence_completion_levels_screen.dart';
import 'cümle kurma/sentence_building_levels_screen.dart';

class WordGamesScreen extends ConsumerStatefulWidget {
  const WordGamesScreen({super.key});

  @override
  ConsumerState<WordGamesScreen> createState() => _WordGamesScreenState();
}

class _WordGamesScreenState extends ConsumerState<WordGamesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(adServiceProvider).loadBannerAd();
      }
    });
  }

  List<Map<String, dynamic>> _getGameOptions(AppLocalizations l10n) {
    return [
      {
        'id': 'word_matching',
        'title': l10n.word_matching,
        'description': l10n.match_words,
        'icon': Icons.compare_arrows,
        'color': Color(0xFF6C5CE7),
      },
      {
        'id': 'word_recall',
        'title': l10n.word_recall,
        'description': l10n.remember_words,
        'icon': Icons.psychology,
        'color': Color(0xFF00B894),
      },
      {
        'id': 'sentence_completion',
        'title': l10n.sentence_completion,
        'description': l10n.complete_sentence,
        'icon': Icons.format_align_left,
        'color': Color(0xFFFF7675),
      },
      {
        'id': 'sentence_building',
        'title': l10n.sentence_building,
        'description': l10n.create_sentence,
        'icon': Icons.construction,
        'color': Color(0xFF74B9FF),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          l10n.word_games,
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
            child: Text(
              l10n.select_words,
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
              itemCount: _getGameOptions(l10n).length,
              itemBuilder: (context, index) {
                final game = _getGameOptions(l10n)[index];
                return _buildGameCard(
                  game,
                  cardColor,
                  textColor,
                  isDark,
                );
              },
            ),
          ),

          if (RevenueCatIntegrationService.instance.isPremium.value == false)
            Consumer(
              builder: (context, ref, child) {
                final adService = ref.watch(adServiceProvider);
                final bannerAd = adService.getBannerAdWidget();
                if (bannerAd != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: bannerAd,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

          // Coming soon section
          /* Padding(
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
          ),*/
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
                            AppLocalizations.of(context)!.start,
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
    // Launch the appropriate game screen based on game ID
    switch (game['id']) {
      case 'word_matching':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WordMatchingLevelsScreen(),
          ),
        );
        break;
      case 'word_recall':
        // Seviyeler sayfasını aç
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WordRecallLevelsScreen(),
          ),
        );
        break;
      case 'sentence_completion':
        // Navigate to sentence completion levels screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SentenceCompletionLevelsScreen(),
          ),
        );
        break;
      case 'sentence_building':
        // Navigate to sentence building levels screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SentenceBuildingLevelsScreen(),
          ),
        );
        break;
      default:
        // Unknown game
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.error}: ${game['title']}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }
}
