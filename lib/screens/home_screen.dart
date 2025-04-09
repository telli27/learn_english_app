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
  int _currentIndex = 0;

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF242424) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Lingify',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                if (index == 3) {
                  // Tema değiştirme butonuna tıklandığında
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                } else {
                  _currentIndex = index;
                }
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? const Color(0xFF242424) : Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor:
                isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            elevation: 0,
            items: [
              _buildNavItem(Icons.home_rounded, 'Ana Sayfa'),
              _buildNavItem(Icons.card_membership, 'Kelime Kartları'),
              _buildNavItem(Icons.fitness_center, 'Alıştırmalar'),
              _buildThemeNavItem(),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildThemeNavItem() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return BottomNavigationBarItem(
      icon: Icon(
        themeProvider.isDarkMode
            ? Icons.wb_sunny_outlined
            : Icons.nightlight_round,
      ),
      label: themeProvider.isDarkMode ? 'Açık Tema' : 'Koyu Tema',
      activeIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          themeProvider.isDarkMode
              ? Icons.wb_sunny_outlined
              : Icons.nightlight_round,
          color: AppColors.primary,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
      activeIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildFlashcardsContent();
      case 2:
        return _buildExercisesContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Consumer<GrammarProvider>(
      builder: (context, grammarProvider, child) {
        if (grammarProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (grammarProvider.topics.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Henüz hiç konu yok',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<GrammarProvider>(context, listen: false)
                        .loadGrammarTopics();
                  },
                  child: const Text('Konuları Yükle'),
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
            final colors = [
              Colors.blue,
              Colors.purple,
              Colors.orange,
              Colors.green,
              Colors.red,
              Colors.teal,
            ];
            final color = colors[index % colors.length];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicDetailScreen(
                        topicId: topic.id,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          Icons.menu_book,
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topic.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildTopicInfo(
                                    Icons.subject,
                                    '${topic.subtopics.length} Alt Konu',
                                    color),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopicInfo(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcardsContent() {
    final List<Map<String, String>> flashcards = [
      {'word': 'House', 'meaning': 'Ev'},
      {'word': 'Cat', 'meaning': 'Kedi'},
      {'word': 'Dog', 'meaning': 'Köpek'},
      {'word': 'Book', 'meaning': 'Kitap'},
      {'word': 'Tree', 'meaning': 'Ağaç'},
      {'word': 'Water', 'meaning': 'Su'},
      {'word': 'Food', 'meaning': 'Yemek'},
      {'word': 'School', 'meaning': 'Okul'},
      {'word': 'Friend', 'meaning': 'Arkadaş'},
      {'word': 'Family', 'meaning': 'Aile'},
      {'word': 'Time', 'meaning': 'Zaman'},
      {'word': 'Love', 'meaning': 'Aşk, Sevgi'},
      {'word': 'City', 'meaning': 'Şehir'},
      {'word': 'Sun', 'meaning': 'Güneş'},
      {'word': 'Moon', 'meaning': 'Ay'},
      {'word': 'Star', 'meaning': 'Yıldız'},
    ];

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242424) : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_membership,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kelime Kartları',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'İngilizce - Türkçe',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      radius: 18,
                      child: Text(
                        "${flashcards.length}",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final flashcard = flashcards[index];
                return _buildFlashcard(flashcard);
              },
              childCount: flashcards.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcard(Map<String, String> flashcard) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF2D2D2D) : Colors.white,
            isDark ? const Color(0xFF222222) : const Color(0xFFF8F8F8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Kelimeye tıklandığında detay görüntüleme
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  flashcard['word']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 20,
                  height: 1,
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
                const SizedBox(height: 6),
                Text(
                  flashcard['meaning']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExercisesContent() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // İngilizce seviyeleri
    final List<Map<String, dynamic>> levels = [
      {
        'name': 'Başlangıç (A1)',
        'description': 'Temel kelimeler ve basit cümleler',
        'icon': Icons.star_border_outlined,
        'color': const Color(0xFF66BB6A),
        'exercises': 24,
      },
      {
        'name': 'Temel (A2)',
        'description': 'Günlük ifadeler ve temel yapılar',
        'icon': Icons.star_half_outlined,
        'color': const Color(0xFF26A69A),
        'exercises': 36,
      },
      {
        'name': 'Orta (B1)',
        'description': 'Sık kullanılan cümleler ve deyimler',
        'icon': Icons.star_outlined,
        'color': const Color(0xFF42A5F5),
        'exercises': 42,
      },
      {
        'name': 'Orta-Üst (B2)',
        'description': 'Akıcı konuşma ve karmaşık metinler',
        'icon': Icons.stars_outlined,
        'color': const Color(0xFF7E57C2),
        'exercises': 38,
      },
      {
        'name': 'İleri (C1)',
        'description': 'Akademik metinler ve profesyonel konular',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFEC407A),
        'exercises': 30,
      },
      {
        'name': 'Uzman (C2)',
        'description': 'Anadil seviyesinde akıcılık',
        'icon': Icons.workspace_premium,
        'color': const Color(0xFFFF7043),
        'exercises': 22,
      },
    ];

    // Alıştırma türleri
    final List<Map<String, dynamic>> exerciseTypes = [
      {
        'name': 'Kelime Bilgisi',
        'icon': Icons.text_fields_outlined,
        'count': 45,
      },
      {
        'name': 'Gramer',
        'icon': Icons.rule_outlined,
        'count': 38,
      },
      {
        'name': 'Okuma',
        'icon': Icons.menu_book_outlined,
        'count': 25,
      },
      {
        'name': 'Dinleme',
        'icon': Icons.headset_outlined,
        'count': 30,
      },
    ];

    return CustomScrollView(
      slivers: [
        // Başlık
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242424) : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İngilizce Alıştırmaları',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Seviyenize uygun alıştırmalar',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // İngilizce Seviyeleri Başlığı
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'İngilizce Seviyeleri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
          ),
        ),

        // İngilizce Seviyeleri Kartları
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return _buildLevelCard(level, isDark);
              },
            ),
          ),
        ),

        // Alıştırma Türleri Başlığı
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alıştırma Türleri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
          ),
        ),

        // Alıştırma Türleri Grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exerciseType = exerciseTypes[index];
                return _buildExerciseTypeCard(exerciseType, isDark);
              },
              childCount: exerciseTypes.length,
            ),
          ),
        ),

        // Popüler Alıştırmalar Başlığı
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popüler Alıştırmalar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
          ),
        ),

        // Popüler Alıştırmalar Listesi
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildPopularExerciseItem(index, isDark);
            },
            childCount: 5,
          ),
        ),

        // Alt boşluk
        const SliverToBoxAdapter(
          child: SizedBox(height: 30),
        ),
      ],
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> level, bool isDark) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            level['color'] as Color,
            (level['color'] as Color).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (level['color'] as Color).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Seviyeye uygun alıştırmaları içeren detay sayfasına geç
            final levelName = level['name'] as String;

            // Her seviye için farklı alıştırmalar oluştur
            List<Map<String, dynamic>> exercises = [];

            // Seviyeye göre farklı alıştırmalar tanımlama
            if (levelName.contains('A1')) {
              exercises = [
                {
                  'title': 'Kelime Bilgisi - Temel',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 5,
                  'questions': [
                    {
                      'question':
                          'İngilizce "door" kelimesinin Türkçe karşılığı nedir?',
                      'options': ['Masa', 'Kapı', 'Pencere', 'Sandalye'],
                      'correctAnswer': 1,
                      'explanation':
                          '"Door" kelimesi İngilizce\'de "kapı" anlamına gelir.',
                    },
                    {
                      'question': '"Apple" kelimesinin Türkçe anlamı nedir?',
                      'options': ['Armut', 'Muz', 'Elma', 'Üzüm'],
                      'correctAnswer': 2,
                      'explanation':
                          '"Apple" kelimesi İngilizce\'de "elma" anlamına gelir.',
                    },
                    {
                      'question': '"House" kelimesinin Türkçe anlamı nedir?',
                      'options': ['Ev', 'Araba', 'Park', 'Okul'],
                      'correctAnswer': 0,
                      'explanation':
                          '"House" kelimesi İngilizce\'de "ev" anlamına gelir.',
                    },
                  ],
                },
                {
                  'title': 'Basit Cümleler Oluşturma',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 7,
                  'questions': [
                    {
                      'question':
                          '"Ben bir öğrenciyim" ifadesinin İngilizce karşılığı nedir?',
                      'options': [
                        'I am teacher',
                        'I am a student',
                        'You are a student',
                        'We are students'
                      ],
                      'correctAnswer': 1,
                      'explanation':
                          '"Ben bir öğrenciyim" cümlesi İngilizce\'de "I am a student" şeklinde ifade edilir.',
                    },
                    {
                      'question':
                          '"O bir doktordur" cümlesinin doğru çevirisi hangisidir?',
                      'options': [
                        'I am a doctor',
                        'You are a doctor',
                        'He is a doctor',
                        'She is doctor'
                      ],
                      'correctAnswer': 2,
                      'explanation':
                          '"O bir doktordur" cümlesi cinsiyet belirtilmediğinde genellikle "He is a doctor" olarak çevrilir.',
                    },
                  ],
                },
              ];
            } else if (levelName.contains('A2')) {
              exercises = [
                {
                  'title': 'Temel İletişim Becerileri',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 8,
                  'questions': [
                    {
                      'question':
                          'Restaurant\'ta yemek sipariş ederken hangi ifade kullanılır?',
                      'options': [
                        'I want this',
                        'Give me that',
                        'I would like to order...',
                        'Food please'
                      ],
                      'correctAnswer': 2,
                      'explanation':
                          'Kibar bir sipariş için "I would like to order..." ifadesi uygundur.',
                    },
                    {
                      'question': 'Yol tarifi isterken nasıl sorarsınız?',
                      'options': [
                        'Where is...?',
                        'How can I go to...?',
                        'I need to find...',
                        'Tell me the way'
                      ],
                      'correctAnswer': 1,
                      'explanation':
                          'Yol tarifi isterken "How can I go to...?" ifadesini kullanmak uygundur.',
                    },
                  ],
                },
                {
                  'title': 'Past Simple Tense',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 10,
                  'questions': [
                    {
                      'question': '"Go" fiilinin past tense hali nedir?',
                      'options': ['Goed', 'Gone', 'Went', 'Going'],
                      'correctAnswer': 2,
                      'explanation': '"Go" fiilinin past tense hali "went"tir.',
                    },
                    {
                      'question':
                          'Düzenli fiillerin Past Simple halinde hangi ek kullanılır?',
                      'options': ['-ing', '-ed', '-s', '-ly'],
                      'correctAnswer': 1,
                      'explanation':
                          'Düzenli fiillerin Past Simple formunu oluşturmak için "-ed" eki kullanılır.',
                    },
                  ],
                },
              ];
            } else if (levelName.contains('B1')) {
              exercises = [
                {
                  'title': 'İngilizce Bağlaçlar',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 7,
                  'questions': [
                    {
                      'question': 'Hangi bağlaç zıtlık bildirir?',
                      'options': ['And', 'Because', 'But', 'So'],
                      'correctAnswer': 2,
                      'explanation':
                          '"But" (ama) bağlacı zıtlık bildiren bir bağlaçtır.',
                    },
                    {
                      'question':
                          'Neden-sonuç ilişkisi kurmak için hangi bağlaç kullanılır?',
                      'options': ['However', 'Therefore', 'Although', 'While'],
                      'correctAnswer': 1,
                      'explanation':
                          '"Therefore" (bu nedenle) bağlacı neden-sonuç ilişkisi kurmak için kullanılır.',
                    },
                  ],
                },
                {
                  'title': 'Relative Clauses',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 9,
                  'questions': [
                    {
                      'question':
                          'İnsanlar için hangi ilgi zamiri (relative pronoun) kullanılır?',
                      'options': ['Which', 'That', 'Who', 'Whose'],
                      'correctAnswer': 2,
                      'explanation':
                          'İnsanlar için "who" ilgi zamiri kullanılır.',
                    },
                    {
                      'question':
                          '"The book _____ is on the table belongs to me." cümlesindeki boşluğa ne gelmelidir?',
                      'options': ['who', 'whom', 'whose', 'which'],
                      'correctAnswer': 3,
                      'explanation':
                          'Cansız nesneler için "which" ilgi zamiri kullanılır.',
                    },
                  ],
                },
              ];
            } else if (levelName.contains('B2')) {
              exercises = [
                {
                  'title': 'Phrasal Verbs',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 12,
                  'questions': [
                    {
                      'question': '"Look after" deyiminin anlamı nedir?',
                      'options': [
                        'Aramak',
                        'Bakmak (ilgilenmek)',
                        'Sonra bakmak',
                        'Özlemek'
                      ],
                      'correctAnswer': 1,
                      'explanation':
                          '"Look after" bir kişi veya nesneye bakmak, ilgilenmek anlamına gelir.',
                    },
                    {
                      'question': '"Give up" deyiminin anlamı nedir?',
                      'options': [
                        'Vermek',
                        'Yukarı vermek',
                        'Vazgeçmek',
                        'Sunmak'
                      ],
                      'correctAnswer': 2,
                      'explanation':
                          '"Give up" vazgeçmek, bırakmak anlamına gelir.',
                    },
                  ],
                },
                {
                  'title': 'Conditionals (Koşul Cümleleri)',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 15,
                  'questions': [
                    {
                      'question':
                          'Second conditional hangi durumlarda kullanılır?',
                      'options': [
                        'Gerçekleşmesi mümkün gelecek durumlar',
                        'Gerçekleşmesi imkansız hayali durumlar',
                        'Geçmişte gerçekleşmemiş durumlar',
                        'Kesin gerçekler'
                      ],
                      'correctAnswer': 1,
                      'explanation':
                          'Second conditional (If I were rich, I would buy a house) gerçekleşmesi pek mümkün olmayan hayali durumlar için kullanılır.',
                    },
                    {
                      'question':
                          '"If it _____ tomorrow, we will cancel the picnic." cümlesindeki boşluğa ne gelmelidir?',
                      'options': ['will rain', 'rains', 'would rain', 'rained'],
                      'correctAnswer': 1,
                      'explanation':
                          'First conditional\'da if cümleciğinde simple present tense kullanılır, bu yüzden "rains" gelmelidir.',
                    },
                  ],
                },
              ];
            } else if (levelName.contains('C1')) {
              exercises = [
                {
                  'title': 'Akademik Yazma Alıştırmaları',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 12,
                  'questions': [
                    {
                      'question':
                          'Akademik yazılarda hangi zamir kullanımından kaçınılmalıdır?',
                      'options': ['It', 'This', 'I/We', 'They'],
                      'correctAnswer': 2,
                      'explanation':
                          'Akademik yazılarda genellikle birinci şahıs zamirlerinden (I/We) kaçınılır, bunun yerine daha nesnel bir dil kullanılır.',
                    },
                    {
                      'question':
                          'Akademik yazmada aşağıdakilerden hangisi önemli değildir?',
                      'options': [
                        'Kaynak gösterimi',
                        'Objektif dil kullanımı',
                        'Kişisel anekdotlar',
                        'Mantıksal yapı'
                      ],
                      'correctAnswer': 2,
                      'explanation':
                          'Akademik yazılarda kişisel anekdotlar genellikle yer almaz, bunun yerine kanıt ve nesnel bilgiler kullanılır.',
                    },
                  ],
                },
                {
                  'title': 'İleri Düzey Deyimler',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 10,
                  'questions': [
                    {
                      'question':
                          '"To bite the bullet" deyiminin anlamı nedir?',
                      'options': [
                        'Tehlikeli bir şey yapmak',
                        'Zor bir durumla cesurca yüzleşmek',
                        'Birine zarar vermek',
                        'Hızlı karar vermek'
                      ],
                      'correctAnswer': 1,
                      'explanation':
                          '"To bite the bullet" zor veya hoş olmayan bir durumla cesurca yüzleşmek anlamına gelir.',
                    },
                    {
                      'question':
                          '"It\'s not rocket science" deyimi ne anlama gelir?',
                      'options': [
                        'Çok karmaşık bir şey',
                        'Uzayla ilgili',
                        'Çok basit bir şey',
                        'İmkansız bir görev'
                      ],
                      'correctAnswer': 2,
                      'explanation':
                          '"It\'s not rocket science" bir şeyin çok zor veya karmaşık olmadığını, oldukça basit olduğunu ifade eder.',
                    },
                  ],
                },
              ];
            } else if (levelName.contains('C2')) {
              exercises = [
                {
                  'title': 'Edebi İnceleme Teknikleri',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 15,
                  'questions': [
                    {
                      'question': 'Bir metindeki "imagery" ne anlama gelir?',
                      'options': [
                        'Resimler',
                        'Duyusal betimlemeler',
                        'Karakter tasvirleri',
                        'Yazım hataları'
                      ],
                      'correctAnswer': 1,
                      'explanation':
                          '"Imagery" bir metinde duyuları (görme, duyma, dokunma, tat, koku) harekete geçiren betimlemelerdir.',
                    },
                    {
                      'question':
                          'Edebi bir metinde "irony" türleri arasında hangisi yer almaz?',
                      'options': [
                        'Verbal irony',
                        'Dramatic irony',
                        'Situational irony',
                        'Logical irony'
                      ],
                      'correctAnswer': 3,
                      'explanation':
                          'Edebi metinlerde üç temel ironi türü vardır: verbal (sözel), dramatic (dramatik) ve situational (durumsal). "Logical irony" diye bir tür yoktur.',
                    },
                  ],
                },
                {
                  'title': 'İleri Düzey Dilbilgisi',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 18,
                  'questions': [
                    {
                      'question':
                          'Hangi cümle inversion (devrik cümle) örneğidir?',
                      'options': [
                        'I have never seen such a beautiful sunset.',
                        'Never have I seen such a beautiful sunset.',
                        'The sunset was the most beautiful I have ever seen.',
                        'Seeing such a beautiful sunset was amazing.'
                      ],
                      'correctAnswer': 1,
                      'explanation':
                          '"Never have I seen..." olumsuz bir ifadeyle başlayan devrik cümle yapısıdır.',
                    },
                    {
                      'question':
                          'Hangi tense "I will have been working here for 10 years by next June" cümlesinde kullanılmıştır?',
                      'options': [
                        'Future Perfect',
                        'Future Continuous',
                        'Future Perfect Continuous',
                        'Present Perfect Continuous'
                      ],
                      'correctAnswer': 2,
                      'explanation':
                          'Bu cümlede Future Perfect Continuous Tense kullanılmıştır ve gelecekte belirli bir zamana kadar devam edecek bir eylemi ifade eder.',
                    },
                  ],
                },
              ];
            } else {
              // Varsayılan alıştırmalar (eğer seviye tanımlanmamışsa)
              exercises = [
                {
                  'title': 'Genel İngilizce Alıştırmaları',
                  'progress': 0.0,
                  'completed': false,
                  'estimatedTime': 5,
                  'questions': [
                    {
                      'question':
                          'İngilizce\'de "hello" kelimesi ne anlama gelir?',
                      'options': [
                        'Güle güle',
                        'Merhaba',
                        'Teşekkürler',
                        'Özür dilerim'
                      ],
                      'correctAnswer': 1,
                      'explanation':
                          '"Hello" İngilizce\'de "merhaba" anlamına gelir.',
                    },
                  ],
                },
              ];
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseDetailScreen(
                  title: level['name'] as String,
                  level: level['name'] as String,
                  color: level['color'] as Color,
                  exercises: exercises,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    level['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  level['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  level['description'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      '${level['exercises']} alıştırma',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseTypeCard(Map<String, dynamic> type, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF282828) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Alıştırma türüne yönlendirme
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    type['icon'],
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${type['count']} alıştırma',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
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

  Widget _buildPopularExerciseItem(int index, bool isDark) {
    // Örnek veriler
    final exercises = [
      {
        'title': 'Present Simple Tense Alıştırmaları',
        'level': 'A1-A2',
        'questions': 15,
        'icon': Icons.access_time,
        'color': const Color(0xFF42A5F5),
        'quizData': {
          'title': 'Present Simple Tense Alıştırmaları',
          'progress': 0.0,
          'completed': false,
          'estimatedTime': 10,
          'questions': [
            {
              'question': 'Present Simple Tense hangi durumlarda kullanılır?',
              'options': [
                'Geçmişte yapılan eylemler için',
                'Şu anda yapılan eylemler için',
                'Rutin ve alışkanlıklar için',
                'Gelecekte yapılacak eylemler için'
              ],
              'correctAnswer': 2,
              'explanation':
                  'Present Simple Tense genellikle rutin, alışkanlık, genel doğrular ve değişmeyen durumlar için kullanılır.',
            },
            {
              'question':
                  '"She _____ coffee every morning." cümlesindeki boşluğa ne gelmelidir?',
              'options': ['drink', 'drinks', 'drinking', 'to drink'],
              'correctAnswer': 1,
              'explanation':
                  'Üçüncü tekil şahıslarla (he, she, it) kullanırken fiile -s/-es eki gelir, bu yüzden doğru cevap "drinks"tir.',
            },
            {
              'question':
                  'Aşağıdakilerden hangisi Present Simple Tense için doğru bir örnek değildir?',
              'options': [
                'I play tennis every Sunday.',
                'Water boils at 100 degrees Celsius.',
                'She is cooking dinner now.',
                'The sun rises in the east.'
              ],
              'correctAnswer': 2,
              'explanation':
                  '"She is cooking dinner now" şu anda devam eden bir eylemi ifade ettiği için Present Continuous Tense örneğidir.',
            },
          ],
        },
      },
      {
        'title': 'İngilizce Sıfatlar Quiz',
        'level': 'A2-B1',
        'questions': 12,
        'icon': Icons.text_format,
        'color': const Color(0xFF66BB6A),
        'quizData': {
          'title': 'İngilizce Sıfatlar Quiz',
          'progress': 0.0,
          'completed': false,
          'estimatedTime': 8,
          'questions': [
            {
              'question': 'Aşağıdakilerden hangisi bir sıfat değildir?',
              'options': ['Happy', 'Beautiful', 'Quickly', 'Interesting'],
              'correctAnswer': 2,
              'explanation': '"Quickly" bir zarftır, diğerleri sıfattır.',
            },
            {
              'question':
                  '"She is a _____ student." cümlesini tamamlamak için en uygun sıfat hangisidir?',
              'options': ['success', 'successful', 'successfully', 'succeed'],
              'correctAnswer': 1,
              'explanation':
                  '"Successful" (başarılı) bir sıfattır ve cümleyi doğru şekilde tamamlar.',
            },
          ],
        },
      },
      {
        'title': 'Düzensiz Fiilleri Öğrenelim',
        'level': 'B1',
        'questions': 20,
        'icon': Icons.rule,
        'color': const Color(0xFFFFB74D),
        'quizData': {
          'title': 'Düzensiz Fiiller Quiz',
          'progress': 0.0,
          'completed': false,
          'estimatedTime': 15,
          'questions': [
            {
              'question': '"Go" fiilinin past tense hali nedir?',
              'options': ['Goed', 'Gone', 'Went', 'Going'],
              'correctAnswer': 2,
              'explanation': '"Go" fiilinin past tense hali "went"tir.',
            },
            {
              'question': '"See" fiilinin past participle hali hangisidir?',
              'options': ['Saw', 'Seen', 'Seed', 'See'],
              'correctAnswer': 1,
              'explanation': '"See" fiilinin past participle hali "seen"dir.',
            },
          ],
        },
      },
      {
        'title': 'İngilizcede Bağlaçlar',
        'level': 'B1-B2',
        'questions': 10,
        'icon': Icons.link,
        'color': const Color(0xFFBA68C8),
        'quizData': {
          'title': 'İngilizce Bağlaçlar Quiz',
          'progress': 0.0,
          'completed': false,
          'estimatedTime': 7,
          'questions': [
            {
              'question': 'Hangi bağlaç zıtlık bildirir?',
              'options': ['And', 'Because', 'But', 'So'],
              'correctAnswer': 2,
              'explanation':
                  '"But" (ama) bağlacı zıtlık bildiren bir bağlaçtır.',
            },
            {
              'question':
                  'Neden-sonuç ilişkisi kurmak için hangi bağlaç kullanılır?',
              'options': ['However', 'Therefore', 'Although', 'While'],
              'correctAnswer': 1,
              'explanation':
                  '"Therefore" (bu nedenle) bağlacı neden-sonuç ilişkisi kurmak için kullanılır.',
            },
          ],
        },
      },
      {
        'title': 'Akademik Yazma Alıştırmaları',
        'level': 'C1',
        'questions': 8,
        'icon': Icons.edit_note,
        'color': const Color(0xFFFF7043),
        'quizData': {
          'title': 'Akademik Yazma Alıştırmaları',
          'progress': 0.0,
          'completed': false,
          'estimatedTime': 12,
          'questions': [
            {
              'question':
                  'Akademik yazılarda hangi zamir kullanımından kaçınılmalıdır?',
              'options': ['It', 'This', 'I/We', 'They'],
              'correctAnswer': 2,
              'explanation':
                  'Akademik yazılarda genellikle birinci şahıs zamirlerinden (I/We) kaçınılır, bunun yerine daha nesnel bir dil kullanılır.',
            },
            {
              'question':
                  'Akademik yazmada aşağıdakilerden hangisi önemli değildir?',
              'options': [
                'Kaynak gösterimi',
                'Objektif dil kullanımı',
                'Kişisel anekdotlar',
                'Mantıksal yapı'
              ],
              'correctAnswer': 2,
              'explanation':
                  'Akademik yazılarda kişisel anekdotlar genellikle yer almaz, bunun yerine kanıt ve nesnel bilgiler kullanılır.',
            },
          ],
        },
      },
    ];

    final exercise = exercises[index];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF282828) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Alıştırmaya yönlendirme
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseQuizScreen(
                  exercise: exercise['quizData'] as Map<String, dynamic>,
                  color: exercise['color'] as Color,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (exercise['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    exercise['icon'] as IconData,
                    color: exercise['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (exercise['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exercise['level'] as String,
                              style: TextStyle(
                                color: exercise['color'] as Color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.help_outline,
                            size: 14,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${exercise['questions'] as int} soru',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
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
