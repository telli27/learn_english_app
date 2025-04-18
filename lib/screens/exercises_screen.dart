import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants/colors.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({Key? key}) : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  // Seçili seviye
  int _selectedLevel = 0;

  // Seviye kategorileri
  final List<Map<String, dynamic>> _levels = [
    {
      'title': 'Başlangıç Seviyesi (A1-A2)',
      'icon': Icons.school_outlined,
      'color': const Color(0xFF4F6CFF),
      'description':
          'İngilizce öğrenmeye yeni başlayanlar için temel kavramlar ve yapılar',
    },
    {
      'title': 'Orta Seviye (B1-B2)',
      'icon': Icons.psychology_outlined,
      'color': const Color(0xFF00BFA5),
      'description':
          'Günlük konuşmada akıcılık kazanmak için orta seviye kavramlar',
    },
    {
      'title': 'İleri Seviye (C1-C2)',
      'icon': Icons.auto_awesome,
      'color': const Color(0xFFFF375F),
      'description':
          'Profesyonel ve akademik ortamlarda kullanılacak ileri seviye İngilizce',
    },
  ];

  // Her seviye için alıştırma kategorileri
  final List<List<Map<String, dynamic>>> _exerciseCategories = [
    // Başlangıç Seviyesi Kategorileri
    [
      {
        'title': 'Kelime Bilgisi',
        'icon': Icons.menu_book_outlined,
        'color': const Color(0xFF4F6CFF),
        'exercises': [
          {
            'title': 'Temel Kelimeler',
            'subtitle': 'Günlük hayatta sık kullanılan kelimeler',
            'count': '15 Alıştırma',
          },
          {
            'title': 'Renkler ve Sayılar',
            'subtitle': 'Temel renk ve sayı kelimeleri',
            'count': '10 Alıştırma',
          },
          {
            'title': 'Vücudumuz',
            'subtitle': 'Vücut bölümleri ve organlar',
            'count': '12 Alıştırma',
          },
        ]
      },
      {
        'title': 'Cümle Kurma',
        'icon': Icons.text_fields_outlined,
        'color': const Color(0xFFFF9500),
        'exercises': [
          {
            'title': 'Basit Cümleler',
            'subtitle': 'Temel cümle yapıları ve soru cümleleri',
            'count': '18 Alıştırma',
          },
          {
            'title': 'To Be Fiilleri',
            'subtitle': 'Am, Is, Are kullanımları',
            'count': '12 Alıştırma',
          },
          {
            'title': 'Tanışma Cümleleri',
            'subtitle': 'Kendinizi tanıtma ve selamlaşma',
            'count': '8 Alıştırma',
          },
        ]
      },
      {
        'title': 'Dilbilgisi',
        'icon': Icons.architecture_outlined,
        'color': const Color(0xFF00BFA5),
        'exercises': [
          {
            'title': 'Articles (a/an/the)',
            'subtitle': 'Tanımlık kullanımları',
            'count': '10 Alıştırma',
          },
          {
            'title': 'Present Simple',
            'subtitle': 'Geniş zaman kullanımı',
            'count': '15 Alıştırma',
          },
          {
            'title': 'Çoğul Yapılar',
            'subtitle': 'İsimlerin çoğul halleri',
            'count': '8 Alıştırma',
          },
        ]
      },
    ],

    // Orta Seviye Kategorileri
    [
      {
        'title': 'Kelime Bilgisi',
        'icon': Icons.menu_book_outlined,
        'color': const Color(0xFF4F6CFF),
        'exercises': [
          {
            'title': 'Sıfatlar ve Zarflar',
            'subtitle': 'Tanımlayıcı kelimeler',
            'count': '14 Alıştırma',
          },
          {
            'title': 'Deyimler',
            'subtitle': 'Sık kullanılan İngilizce deyimler',
            'count': '12 Alıştırma',
          },
          {
            'title': 'Eş Anlamlı Kelimeler',
            'subtitle': 'Zengin kelime hazinesi için eş anlamlılar',
            'count': '10 Alıştırma',
          },
        ]
      },
      {
        'title': 'Cümle Kurma',
        'icon': Icons.text_fields_outlined,
        'color': const Color(0xFFFF9500),
        'exercises': [
          {
            'title': 'Karmaşık Cümleler',
            'subtitle': 'Birleşik ve sıralı cümleler',
            'count': '16 Alıştırma',
          },
          {
            'title': 'Dolaylı Anlatım',
            'subtitle': 'Reported speech kullanımı',
            'count': '12 Alıştırma',
          },
          {
            'title': 'Pasif Yapılar',
            'subtitle': 'Passive voice kullanımı',
            'count': '14 Alıştırma',
          },
        ]
      },
      {
        'title': 'Dilbilgisi',
        'icon': Icons.architecture_outlined,
        'color': const Color(0xFF00BFA5),
        'exercises': [
          {
            'title': 'Past Tense',
            'subtitle': 'Geçmiş zaman kullanımları',
            'count': '15 Alıştırma',
          },
          {
            'title': 'Present Perfect',
            'subtitle': 'Present Perfect kullanımı',
            'count': '12 Alıştırma',
          },
          {
            'title': 'Conditionals',
            'subtitle': 'Koşul cümleleri',
            'count': '10 Alıştırma',
          },
        ]
      },
    ],

    // İleri Seviye Kategorileri
    [
      {
        'title': 'Kelime Bilgisi',
        'icon': Icons.menu_book_outlined,
        'color': const Color(0xFF4F6CFF),
        'exercises': [
          {
            'title': 'Akademik Kelimeler',
            'subtitle': 'Akademik metinlerde kullanılan kelimeler',
            'count': '15 Alıştırma',
          },
          {
            'title': 'İdiyomatik İfadeler',
            'subtitle': 'Native speaker gibi konuşma',
            'count': '20 Alıştırma',
          },
          {
            'title': 'Formal İngilizce',
            'subtitle': 'Resmi ortamlarda kullanılan kelimeler',
            'count': '12 Alıştırma',
          },
        ]
      },
      {
        'title': 'Cümle Kurma',
        'icon': Icons.text_fields_outlined,
        'color': const Color(0xFFFF9500),
        'exercises': [
          {
            'title': 'Akademik Yazı',
            'subtitle': 'Essay ve bilimsel yazı teknikleri',
            'count': '12 Alıştırma',
          },
          {
            'title': 'İş İngilizcesi',
            'subtitle': 'Profesyonel iletişim cümleleri',
            'count': '15 Alıştırma',
          },
          {
            'title': 'Retorik Teknikler',
            'subtitle': 'İkna edici konuşma yapıları',
            'count': '10 Alıştırma',
          },
        ]
      },
      {
        'title': 'Dilbilgisi',
        'icon': Icons.architecture_outlined,
        'color': const Color(0xFF00BFA5),
        'exercises': [
          {
            'title': 'Advanced Tenses',
            'subtitle': 'Karmaşık zaman yapıları',
            'count': '15 Alıştırma',
          },
          {
            'title': 'Subjunctives',
            'subtitle': 'Dilek ve şart kipleri',
            'count': '10 Alıştırma',
          },
          {
            'title': 'Cleft Sentences',
            'subtitle': 'Vurgu yapıları',
            'count': '8 Alıştırma',
          },
        ]
      },
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(isDark),

            // Seviye seçimi
            Container(
              height: 110,
              margin: const EdgeInsets.only(top: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _levels.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return _buildLevelCard(index, isDark);
                },
              ),
            ),

            // Seviye açıklaması
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _levels[_selectedLevel]['description'],
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),

            // Alıştırma kategorileri başlığı
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                'Alıştırma Kategorileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),

            // Alıştırma kategorileri listesi
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _exerciseCategories[_selectedLevel].length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                      _exerciseCategories[_selectedLevel][index], isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İngilizce Alıştırmalar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seviyenize uygun alıştırmalarla İngilizce öğrenin',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(int index, bool isDark) {
    final level = _levels[index];
    final isSelected = _selectedLevel == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = index;
        });
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected
                  ? level['color'].withOpacity(0.3)
                  : const Color(0xFF1E1E1E))
              : (isSelected ? level['color'].withOpacity(0.1) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? level['color']
                : (isDark ? Colors.white12 : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              level['icon'],
              color: isSelected
                  ? level['color']
                  : (isDark ? Colors.white70 : Colors.grey[600]),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              level['title'].split(' ')[0], // Just the level name, not the code
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? level['color']
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              level['title']
                  .split(' ')[1], // Just the level code in parentheses
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? level['color']
                    : (isDark ? Colors.white70 : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori başlığı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category['color'].withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  category['icon'],
                  color: category['color'],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  category['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Kategori içindeki alıştırmalar
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: category['exercises'].length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final exercise = category['exercises'][index];
              return _buildExerciseItem(exercise, category['color'], isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(
      Map<String, dynamic> exercise, Color color, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Alıştırma detayına git
          final exerciseList = _getExerciseDetails(exercise['title']);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(
                title: exercise['title'],
                level: _levels[_selectedLevel]['title'].split(' ')[0],
                color: color,
                exercises: exerciseList,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['title'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise['subtitle'],
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      exercise['count'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDark ? Colors.white54 : Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Alıştırma detayları için örnek veriler
  List<Map<String, dynamic>> _getExerciseDetails(String topicTitle) {
    // Başlangıç seviyesi için alıştırma detayları
    if (_selectedLevel == 0) {
      // Temel Kelimeler - Başlangıç Seviyesi
      if (topicTitle == 'Temel Kelimeler') {
        return [
          {
            'title': 'Günlük Yaşam Kelimeleri',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Temel Günlük Kelimeler',
                'explanation':
                    'Günlük hayatta sık kullanılan kelimeler ve kullanımları:',
                'examples': [
                  {'english': 'Hello / Hi', 'turkish': 'Merhaba'},
                  {'english': 'Good morning', 'turkish': 'Günaydın'},
                  {
                    'english': 'Good afternoon',
                    'turkish': 'İyi günler / Tünaydın'
                  },
                  {'english': 'Good evening', 'turkish': 'İyi akşamlar'},
                  {'english': 'Goodbye', 'turkish': 'Hoşçakal'},
                  {'english': 'Thank you', 'turkish': 'Teşekkür ederim'},
                  {'english': 'Please', 'turkish': 'Lütfen'},
                  {'english': 'Yes / No', 'turkish': 'Evet / Hayır'},
                ],
                'practice':
                    'Bu günlük selamlaşma kelimelerini kullanarak kısa diyaloglar yazın.'
              }
            ],
            'estimatedTime': '5',
            'completed': false,
            'progress': 0.0,
          },
          {
            'title': 'Ev Eşyaları',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Ev Eşyaları',
                'explanation': 'Evde bulunan eşyaların isimleri:',
                'examples': [
                  {'english': 'Table', 'turkish': 'Masa'},
                  {'english': 'Chair', 'turkish': 'Sandalye'},
                  {'english': 'Bed', 'turkish': 'Yatak'},
                  {'english': 'Door', 'turkish': 'Kapı'},
                  {'english': 'Window', 'turkish': 'Pencere'},
                  {'english': 'Kitchen', 'turkish': 'Mutfak'},
                  {'english': 'Bathroom', 'turkish': 'Banyo'},
                  {'english': 'Living room', 'turkish': 'Oturma odası'},
                ],
                'practice':
                    'Evinizi tanıtan basit cümleler yazın, örneğin: "This is my table." (Bu benim masam.)'
              }
            ],
            'estimatedTime': '6',
            'completed': false,
            'progress': 0.0,
          },
        ];
      }
      // Renkler ve Sayılar - Başlangıç Seviyesi
      else if (topicTitle == 'Renkler ve Sayılar') {
        return [
          {
            'title': 'Renkler',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Temel Renkler',
                'explanation': 'İngilizcede temel renkler:',
                'examples': [
                  {'english': 'Red', 'turkish': 'Kırmızı'},
                  {'english': 'Blue', 'turkish': 'Mavi'},
                  {'english': 'Green', 'turkish': 'Yeşil'},
                  {'english': 'Yellow', 'turkish': 'Sarı'},
                  {'english': 'Black', 'turkish': 'Siyah'},
                  {'english': 'White', 'turkish': 'Beyaz'},
                  {'english': 'Orange', 'turkish': 'Turuncu'},
                  {'english': 'Purple', 'turkish': 'Mor'},
                ],
                'practice':
                    'Renkleri kullanarak şu tarzda cümleler yazın: "My pen is blue." (Kalemim mavi.)'
              },
              {
                'type': 'example_sentence',
                'title': 'Renklerle İlgili Basit Cümleler',
                'explanation': 'Renkleri tanımlamada kullanılan ifadeler:',
                'examples': [
                  {
                    'english': 'The sky is blue.',
                    'turkish': 'Gökyüzü mavidir.'
                  },
                  {
                    'english': 'I have a red car.',
                    'turkish': 'Kırmızı bir arabam var.'
                  },
                  {
                    'english': 'Her dress is green.',
                    'turkish': 'Onun elbisesi yeşil.'
                  },
                  {
                    'english': 'This flower is yellow.',
                    'turkish': 'Bu çiçek sarı.'
                  },
                ],
                'practice':
                    'Çevrenizdeki nesnelerin renklerini anlatan 5 cümle yazın.'
              }
            ],
            'estimatedTime': '4',
            'completed': false,
            'progress': 0.0,
          },
          {
            'title': 'Sayılar',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Temel Sayılar (1-20)',
                'explanation': 'İngilizcede 1\'den 20\'ye kadar sayılar:',
                'examples': [
                  {'english': 'One', 'turkish': 'Bir'},
                  {'english': 'Two', 'turkish': 'İki'},
                  {'english': 'Three', 'turkish': 'Üç'},
                  {'english': 'Four', 'turkish': 'Dört'},
                  {'english': 'Five', 'turkish': 'Beş'},
                  {'english': 'Ten', 'turkish': 'On'},
                  {'english': 'Fifteen', 'turkish': 'On beş'},
                  {'english': 'Twenty', 'turkish': 'Yirmi'},
                ],
                'practice':
                    'Sayıları kullanarak cümleler yazın, örneğin: "I have three books." (Üç kitabım var.)'
              },
              {
                'type': 'example_sentence',
                'title': 'Sayılarla İlgili Basit Cümleler',
                'explanation': 'Günlük hayatta sayıları kullanırken:',
                'examples': [
                  {
                    'english': 'I am 18 years old.',
                    'turkish': '18 yaşındayım.'
                  },
                  {
                    'english': 'She has two brothers.',
                    'turkish': 'İki erkek kardeşi var.'
                  },
                  {
                    'english': 'There are five people in my family.',
                    'turkish': 'Ailemde beş kişi var.'
                  },
                  {
                    'english': 'The book costs ten dollars.',
                    'turkish': 'Kitap on dolar.'
                  },
                ],
                'practice': 'Kendi yaşamınızdan sayı içeren 4 cümle yazın.'
              }
            ],
            'estimatedTime': '4',
            'completed': false,
            'progress': 0.0,
          },
        ];
      }
      // Basit Cümleler - Başlangıç Seviyesi
      else if (topicTitle == 'Basit Cümleler') {
        return [
          {
            'title': 'Kendini Tanıtma',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Kendini Tanıtma Cümleleri',
                'explanation':
                    'Kendinizi tanıtırken kullanabileceğiniz basit cümleler:',
                'examples': [
                  {
                    'english': 'My name is John.',
                    'turkish': 'Benim adım John.'
                  },
                  {
                    'english': 'I am from Turkey.',
                    'turkish': 'Ben Türkiye\'denim.'
                  },
                  {
                    'english': 'I am a student.',
                    'turkish': 'Ben bir öğrenciyim.'
                  },
                  {
                    'english': 'I live in Istanbul.',
                    'turkish': 'İstanbul\'da yaşıyorum.'
                  },
                  {
                    'english': 'I am 20 years old.',
                    'turkish': '20 yaşındayım.'
                  },
                ],
                'practice': 'Kendinizi tanıtan beş cümle yazın.'
              }
            ],
            'estimatedTime': '5',
            'completed': false,
            'progress': 0.0,
          },
          {
            'title': 'Günlük Aktiviteler',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Günlük Aktivite Cümleleri',
                'explanation':
                    'Günlük aktiviteleri anlatırken kullanabileceğiniz basit cümleler:',
                'examples': [
                  {
                    'english': 'I wake up at 7 AM.',
                    'turkish': 'Sabah 7\'de uyanırım.'
                  },
                  {
                    'english': 'I have breakfast at 8 AM.',
                    'turkish': 'Sabah 8\'de kahvaltı yaparım.'
                  },
                  {
                    'english': 'I go to school by bus.',
                    'turkish': 'Okula otobüsle giderim.'
                  },
                  {
                    'english': 'I eat lunch at noon.',
                    'turkish': 'Öğle yemeğimi öğlen yerim.'
                  },
                  {
                    'english': 'I sleep at 11 PM.',
                    'turkish': 'Gece 11\'de uyurum.'
                  },
                ],
                'practice': 'Günlük rutininizi anlatan beş cümle yazın.'
              }
            ],
            'estimatedTime': '5',
            'completed': false,
            'progress': 0.0,
          },
        ];
      }
      // To Be Fiilleri - Başlangıç Seviyesi
      else if (topicTitle == 'To Be Fiilleri') {
        return [
          {
            'title': 'To Be - Olumlu Cümleler',
            'questions': [
              {
                'type': 'example_sentence',
                'title': '"Be" Fiilinin Olumlu Kullanımı',
                'explanation':
                    '"To be" fiili (am/is/are) kişilere göre farklı şekillerde kullanılır:',
                'examples': [
                  {
                    'english': 'I am a teacher.',
                    'turkish': 'Ben bir öğretmenim.'
                  },
                  {
                    'english': 'You are a student.',
                    'turkish': 'Sen bir öğrencisin.'
                  },
                  {'english': 'He is a doctor.', 'turkish': 'O bir doktordur.'},
                  {
                    'english': 'She is a nurse.',
                    'turkish': 'O bir hemşiredir.'
                  },
                  {'english': 'It is a book.', 'turkish': 'O bir kitaptır.'},
                  {'english': 'We are friends.', 'turkish': 'Biz arkadaşız.'},
                  {
                    'english': 'They are students.',
                    'turkish': 'Onlar öğrencilerdir.'
                  },
                ],
                'practice':
                    'Kendiniz ve aileniz hakkında "am/is/are" kullanarak 5 cümle yazın.'
              }
            ],
            'estimatedTime': '5',
            'completed': false,
            'progress': 0.0,
          },
          {
            'title': 'To Be - Olumsuz Cümleler',
            'questions': [
              {
                'type': 'example_sentence',
                'title': '"Be" Fiilinin Olumsuz Kullanımı',
                'explanation':
                    '"To be" fiilinin olumsuz formu "not" eklenerek yapılır:',
                'examples': [
                  {
                    'english': 'I am not a teacher.',
                    'turkish': 'Ben öğretmen değilim.'
                  },
                  {
                    'english': 'You are not a student.',
                    'turkish': 'Sen öğrenci değilsin.'
                  },
                  {
                    'english': 'He is not a doctor.',
                    'turkish': 'O doktor değildir.'
                  },
                  {
                    'english': 'She is not at home.',
                    'turkish': 'O evde değil.'
                  },
                  {
                    'english': 'It is not expensive.',
                    'turkish': 'O pahalı değil.'
                  },
                  {
                    'english': 'We are not tired.',
                    'turkish': 'Biz yorgun değiliz.'
                  },
                  {
                    'english': 'They are not ready.',
                    'turkish': 'Onlar hazır değiller.'
                  },
                ],
                'practice':
                    'Olumsuz cümleler yazın: "I am not..." / "She is not..." / "They are not..."'
              }
            ],
            'estimatedTime': '5',
            'completed': false,
            'progress': 0.0,
          },
        ];
      }
    }
    // Orta seviye için alıştırma detayları
    else if (_selectedLevel == 1) {
      // Karmaşık Cümleler - Orta Seviye
      if (topicTitle == 'Karmaşık Cümleler') {
        return [
          {
            'title': 'Bağlaçlar ile Cümle Birleştirme',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Bağlaçlarla Cümle Birleştirme',
                'explanation':
                    'Bağlaçlar (and, but, or, so, because) kullanarak iki cümleyi birleştirme:',
                'examples': [
                  {
                    'english': 'I was tired, so I went to bed early.',
                    'turkish': 'Yorgundum, bu yüzden erken yattım.'
                  },
                  {
                    'english': 'She likes coffee, but she doesn\'t like tea.',
                    'turkish': 'Kahveyi sever, ama çayı sevmez.'
                  },
                  {
                    'english':
                        'He studied hard because he wanted to pass the exam.',
                    'turkish': 'Sınavı geçmek istediği için çok çalıştı.'
                  },
                  {
                    'english': 'You can eat now or you can wait until dinner.',
                    'turkish':
                        'Şimdi yiyebilirsin veya akşam yemeğine kadar bekleyebilirsin.'
                  },
                  {
                    'english': 'I called him, and he answered immediately.',
                    'turkish': 'Onu aradım ve hemen cevap verdi.'
                  },
                ],
                'practice':
                    'Her bir bağlaç (and, but, so, because, or) için bir cümle yazın.'
              }
            ],
            'estimatedTime': '7',
            'completed': false,
            'progress': 0.0,
          },
          {
            'title': 'Sıfat Yan Cümleleri',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Sıfat Yan Cümleleri',
                'explanation':
                    'Sıfat yan cümleleri bir ismi tanımlamak veya açıklamak için kullanılır:',
                'examples': [
                  {
                    'english': 'The woman who lives next door is a doctor.',
                    'turkish': 'Yan dairede yaşayan kadın bir doktordur.'
                  },
                  {
                    'english':
                        'The book that I read last week was very interesting.',
                    'turkish': 'Geçen hafta okuduğum kitap çok ilginçti.'
                  },
                  {
                    'english':
                        'The car which is parked outside belongs to my father.',
                    'turkish': 'Dışarıda park edilmiş olan araba babama aittir.'
                  },
                  {
                    'english': 'I know the man who called you.',
                    'turkish': 'Seni arayan adamı tanıyorum.'
                  },
                ],
                'practice':
                    'Her biri who, which veya that içeren üç cümle yazın.'
              }
            ],
            'estimatedTime': '6',
            'completed': false,
            'progress': 0.0,
          },
        ];
      }
      // Past Tense - Orta Seviye
      else if (topicTitle == 'Past Tense') {
        return [
          {
            'title': 'Simple Past - Düzenli Fiiller',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Simple Past - Düzenli Fiiller',
                'explanation':
                    'Düzenli fiillerin geçmiş zaman çekimleri -ed eklenir:',
                'examples': [
                  {
                    'english': 'I worked all day yesterday.',
                    'turkish': 'Dün bütün gün çalıştım.'
                  },
                  {
                    'english': 'She visited her grandmother last week.',
                    'turkish': 'Geçen hafta büyükannesini ziyaret etti.'
                  },
                  {
                    'english': 'They played football in the park.',
                    'turkish': 'Parkta futbol oynadılar.'
                  },
                  {
                    'english': 'We watched a movie last night.',
                    'turkish': 'Dün gece film izledik.'
                  },
                  {
                    'english': 'He cleaned his room on Sunday.',
                    'turkish': 'Pazar günü odasını temizledi.'
                  },
                ],
                'practice': 'Dün yaptığınız etkinliklerle ilgili 5 cümle yazın.'
              }
            ],
            'estimatedTime': '6',
            'completed': false,
            'progress': 0.0,
          },
          {
            'title': 'Simple Past - Düzensiz Fiiller',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Simple Past - Düzensiz Fiiller',
                'explanation':
                    'Düzensiz fiillerin geçmiş zaman çekimleri kendine özgüdür:',
                'examples': [
                  {
                    'english': 'I went to the cinema yesterday.',
                    'turkish': 'Dün sinemaya gittim.'
                  },
                  {
                    'english': 'She saw her friend at the mall.',
                    'turkish': 'Arkadaşını alışveriş merkezinde gördü.'
                  },
                  {
                    'english': 'They came to the party late.',
                    'turkish': 'Partiye geç geldiler.'
                  },
                  {
                    'english': 'He took the bus to work.',
                    'turkish': 'İşe otobüsle gitti.'
                  },
                  {
                    'english': 'We ate dinner at a restaurant.',
                    'turkish': 'Akşam yemeğini bir restoranda yedik.'
                  },
                ],
                'practice':
                    'Geçmiş zaman içeren ve düzensiz fiil kullanarak 5 cümle yazın.'
              }
            ],
            'estimatedTime': '7',
            'completed': false,
            'progress': 0.0,
          },
        ];
      }
    }
    // İleri seviye için alıştırma detayları
    else if (_selectedLevel == 2) {
      // Akademik Yazı - İleri Seviye
      if (topicTitle == 'Akademik Yazı') {
        return [
          {
            'title': 'Akademik Yazı Yapısı',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Akademik Yazılarda Giriş Cümleleri',
                'explanation':
                    'Akademik yazılarda giriş paragrafı nasıl yazılır:',
                'examples': [
                  {
                    'english':
                        'This paper examines the effects of climate change on marine ecosystems.',
                    'turkish':
                        'Bu makale, iklim değişikliğinin deniz ekosistemleri üzerindeki etkilerini incelemektedir.'
                  },
                  {
                    'english':
                        'Recent research suggests that social media has a significant impact on mental health.',
                    'turkish':
                        'Son araştırmalar, sosyal medyanın ruh sağlığı üzerinde önemli bir etkisi olduğunu göstermektedir.'
                  },
                  {
                    'english':
                        'The aim of this study is to investigate the relationship between sleep patterns and academic performance.',
                    'turkish':
                        'Bu çalışmanın amacı, uyku düzenleri ile akademik performans arasındaki ilişkiyi araştırmaktır.'
                  },
                  {
                    'english':
                        'This essay argues that renewable energy sources are essential for sustainable development.',
                    'turkish':
                        'Bu makale, yenilenebilir enerji kaynaklarının sürdürülebilir kalkınma için gerekli olduğunu savunmaktadır.'
                  },
                ],
                'practice':
                    'İlgilendiğiniz bir konu hakkında akademik bir giriş paragrafı yazın.'
              }
            ],
            'estimatedTime': '10',
            'completed': false,
            'progress': 0.0,
          },
          {
            'title': 'Akademik Bağlaçlar Kullanımı',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Akademik Yazılarda Bağlaçlar',
                'explanation':
                    'Akademik yazılarda kullanılan bağlaçlar ve geçiş ifadeleri:',
                'examples': [
                  {
                    'english':
                        'However, the results contradict previous findings in this field.',
                    'turkish':
                        'Ancak, sonuçlar bu alandaki önceki bulguları çürütmektedir.'
                  },
                  {
                    'english':
                        'Moreover, the study highlights the importance of early intervention.',
                    'turkish':
                        'Ayrıca, çalışma erken müdahalenin önemini vurgulamaktadır.'
                  },
                  {
                    'english':
                        'Consequently, businesses need to adapt their strategies to remain competitive.',
                    'turkish':
                        'Sonuç olarak, işletmelerin rekabetçi kalabilmek için stratejilerini uyarlamaları gerekmektedir.'
                  },
                  {
                    'english':
                        'In contrast to earlier studies, this research found a significant correlation.',
                    'turkish':
                        'Önceki çalışmaların aksine, bu araştırma önemli bir korelasyon buldu.'
                  },
                ],
                'practice':
                    'Her biri farklı bir akademik bağlaç içeren 5 cümle yazın.'
              }
            ],
            'estimatedTime': '8',
            'completed': false,
            'progress': 0.0,
          },
        ];
      }
      // Advanced Tenses - İleri Seviye
      else if (topicTitle == 'Advanced Tenses') {
        return [
          {
            'title': 'Perfect Tenses',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Present Perfect Tense',
                'explanation':
                    'Present Perfect zamanı, geçmişte başlayıp şimdiye kadar devam eden veya şimdiyi etkileyen olayları anlatır:',
                'examples': [
                  {
                    'english': 'I have lived in London for five years.',
                    'turkish': 'Beş yıldır Londra\'da yaşıyorum.'
                  },
                  {
                    'english': 'She has studied English since 2018.',
                    'turkish': '2018\'den beri İngilizce çalışıyor.'
                  },
                  {
                    'english': 'They have visited Paris three times.',
                    'turkish': 'Paris\'i üç kez ziyaret ettiler.'
                  },
                  {
                    'english': 'He has never eaten sushi before.',
                    'turkish': 'Daha önce hiç suşi yemedi.'
                  },
                  {
                    'english': 'Have you seen the new movie yet?',
                    'turkish': 'Yeni filmi izledin mi henüz?'
                  },
                ],
                'practice':
                    'Kendi hayatınızdan Present Perfect zamanda 5 cümle yazın.'
              }
            ],
            'estimatedTime': '8',
            'completed': false,
            'progress': 0.0,
          },
          {
            'title': 'Conditional Sentences',
            'questions': [
              {
                'type': 'example_sentence',
                'title': 'Conditional Sentences (If Clauses)',
                'explanation':
                    'Koşul cümleleri (if clauses) farklı durumlardaki olasılıkları anlatır:',
                'examples': [
                  {
                    'english': 'If it rains tomorrow, I will stay at home.',
                    'turkish': 'Yarın yağmur yağarsa, evde kalacağım.'
                  },
                  {
                    'english': 'If I had more time, I would travel more.',
                    'turkish':
                        'Daha fazla zamanım olsaydı, daha çok seyahat ederdim.'
                  },
                  {
                    'english':
                        'If I had studied harder, I would have passed the exam.',
                    'turkish': 'Daha çok çalışsaydım, sınavı geçerdim.'
                  },
                  {
                    'english': 'If you need help, you can call me anytime.',
                    'turkish':
                        'Yardıma ihtiyacın olursa, beni istediğin zaman arayabilirsin.'
                  },
                ],
                'practice':
                    'Her bir tür koşul cümlesi için bir örnek yazın (Type 1, Type 2, Type 3).'
              }
            ],
            'estimatedTime': '9',
            'completed': false,
            'progress': 0.0,
          },
        ];
      }
    }

    // Varsayılan olarak boş liste döndür
    return [
      {
        'title': 'Alıştırma',
        'questions': [
          {
            'type': 'example_sentence',
            'title': 'Örnek Cümleler',
            'explanation': 'Bu konu için henüz içerik hazırlanmamıştır.',
            'examples': [
              {
                'english': 'This is an example sentence.',
                'turkish': 'Bu bir örnek cümledir.'
              },
              {
                'english': 'More content will be added soon.',
                'turkish': 'Yakında daha fazla içerik eklenecektir.'
              },
            ],
            'practice': 'Alıştırma için kendi cümlelerinizi yazabilirsiniz.'
          }
        ],
        'estimatedTime': '5',
        'completed': false,
        'progress': 0.0,
      },
    ];
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Çoktan Seçmeli';
      case 'true_false':
        return 'Doğru/Yanlış';
      case 'fill_blank':
        return 'Boşluk Doldurma';
      case 'sentence_building':
        return 'Cümle Oluşturma';
      case 'listening':
        return 'Dinleme';
      case 'matching':
        return 'Eşleştirme';
      default:
        return 'Alıştırma';
    }
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'multiple_choice':
        return Icons.check_circle_outline;
      case 'true_false':
        return Icons.fact_check_outlined;
      case 'fill_blank':
        return Icons.text_fields_outlined;
      case 'sentence_building':
        return Icons.format_align_left;
      case 'listening':
        return Icons.hearing_outlined;
      case 'matching':
        return Icons.compare_arrows_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
