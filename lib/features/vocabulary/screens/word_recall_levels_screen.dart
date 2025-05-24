import 'package:flutter/material.dart';
import 'professional_word_recall_screen.dart';
import '../core/game_enums.dart';

/// Modern Kelime Hatırlama Seviyeleri Ekranı
class WordRecallLevelsScreen extends StatefulWidget {
  const WordRecallLevelsScreen({super.key});

  @override
  State<WordRecallLevelsScreen> createState() => _WordRecallLevelsScreenState();
}

class _WordRecallLevelsScreenState extends State<WordRecallLevelsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Modern seviye tanımları
  static const List<Map<String, dynamic>> _levelOptions = [
    {
      'level': 1,
      'title': 'Başlangıç',
      'subtitle': 'Temel Kelimeler',
      'description': 'Günlük hayatın en temel kelimeleri ile başlayın',
      'exerciseCount': 2,
      'wordCount': 5,
      'icon': Icons.school_outlined,
      'gradientColors': [Color(0xFF4CAF50), Color(0xFF66BB6A)],
      'difficulty': 'Kolay',
      'studyTime': '20s',
      'recallTime': '40s',
      'difficultyEnum': DifficultyLevel.beginner,
      'progress': 0.8, // Demo progress
    },
    {
      'level': 2,
      'title': 'Orta Seviye',
      'subtitle': 'Günlük Konuşma',
      'description': 'Günlük hayatta sıkça kullanılan kelimeleri öğrenin',
      'exerciseCount': 2,
      'wordCount': 5,
      'icon': Icons.trending_up_outlined,
      'gradientColors': [Color(0xFF2196F3), Color(0xFF42A5F5)],
      'difficulty': 'Orta',
      'studyTime': '25s',
      'recallTime': '50s',
      'difficultyEnum': DifficultyLevel.intermediate,
      'progress': 0.4,
    },
    {
      'level': 3,
      'title': 'İleri Seviye',
      'subtitle': 'Akademik Kelimeler',
      'description': 'Daha karmaşık ve akademik kelimeleri keşfedin',
      'exerciseCount': 2,
      'wordCount': 5,
      'icon': Icons.emoji_events_outlined,
      'gradientColors': [Color(0xFFFF9800), Color(0xFFFFB74D)],
      'difficulty': 'Zor',
      'studyTime': '30s',
      'recallTime': '60s',
      'difficultyEnum': DifficultyLevel.advanced,
      'progress': 0.1,
    },
    {
      'level': 4,
      'title': 'Uzman Seviye',
      'subtitle': 'Profesyonel Kelimeler',
      'description': 'En zorlu kelimelerle kendinizi test edin',
      'exerciseCount': 2,
      'wordCount': 5,
      'icon': Icons.military_tech_outlined,
      'gradientColors': [Color(0xFFE91E63), Color(0xFFF06292)],
      'difficulty': 'Uzman',
      'studyTime': '35s',
      'recallTime': '70s',
      'difficultyEnum': DifficultyLevel.expert,
      'progress': 0.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(),
              Expanded(
                child: _buildLevelsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title row
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Kelime Oyunu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Main title
          const Text(
            'Seviyeni Seç',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kendi seviyende kelime öğrenmeye başla',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsList() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                children: [
                  // Levels - İlerleme durumu kartını kaldırdık
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _levelOptions.length,
                      itemBuilder: (context, index) {
                        return Transform.translate(
                          offset: Offset(0,
                              (1 - _fadeAnimation.value.clamp(0.0, 1.0)) * 50),
                          child: _buildModernLevelCard(
                            _levelOptions[index],
                            index,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernLevelCard(Map<String, dynamic> level, int index) {
    final gradientColors = level['gradientColors'] as List<Color>;
    final progress = level['progress'] as double;
    final isLocked = index > 0 && _levelOptions[index - 1]['progress'] < 0.8;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: isLocked ? null : () => _launchLevel(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isLocked
                  ? LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[400]!],
                    )
                  : LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? Colors.grey.withOpacity(0.3)
                      : gradientColors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isLocked
                            ? Icons.lock_outline
                            : level['icon'] as IconData,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            level['subtitle'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLocked) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          level['difficulty'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  isLocked
                      ? 'Bu seviyeyi açmak için önceki seviyeyi tamamlayın'
                      : level['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                if (!isLocked) ...[
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      _buildStatChip(
                        Icons.assignment_outlined,
                        '${level['exerciseCount']} Alıştırma',
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        Icons.book_outlined,
                        '${level['wordCount']} Kelime',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Time info
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Çalışma: ${level['studyTime']} • Hatırlama: ${level['recallTime']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _launchLevel(Map<String, dynamic> level) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProfessionalWordRecallScreen(
          difficulty: level['difficultyEnum'] as DifficultyLevel,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
