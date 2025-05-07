import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

class CommonPhrasesScreen extends ConsumerStatefulWidget {
  const CommonPhrasesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommonPhrasesScreen> createState() =>
      _CommonPhrasesScreenState();
}

class _CommonPhrasesScreenState extends ConsumerState<CommonPhrasesScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Selamlaşma',
      'icon': Icons.waving_hand,
      'color': Color(0xFF4F6CFF),
      'phrases': [
        {'english': 'Hello!', 'turkish': 'Merhaba!'},
        {'english': 'Good morning!', 'turkish': 'Günaydın!'},
        {'english': 'Good afternoon!', 'turkish': 'Tünaydın!'},
        {'english': 'Good evening!', 'turkish': 'İyi akşamlar!'},
        {'english': 'How are you?', 'turkish': 'Nasılsın?'},
        {
          'english': 'Nice to meet you!',
          'turkish': 'Tanıştığımıza memnun oldum!'
        },
        {'english': 'See you later!', 'turkish': 'Sonra görüşürüz!'},
      ],
    },
    {
      'title': 'Seyahat',
      'icon': Icons.airplane_ticket,
      'color': Color(0xFFFF9500),
      'phrases': [
        {
          'english': 'Can you help me?',
          'turkish': 'Bana yardım edebilir misiniz?'
        },
        {'english': 'Where is the bathroom?', 'turkish': 'Tuvalet nerede?'},
        {'english': 'How much does it cost?', 'turkish': 'Ne kadar?'},
        {'english': 'I need a taxi.', 'turkish': 'Bir taksiye ihtiyacım var.'},
        {
          'english': 'Is there a hotel nearby?',
          'turkish': 'Yakınlarda bir otel var mı?'
        },
        {
          'english': 'What time is the check-in?',
          'turkish': 'Giriş saati kaçta?'
        },
        {'english': 'I have a reservation.', 'turkish': 'Rezervasyonum var.'},
      ],
    },
    {
      'title': 'Restoran',
      'icon': Icons.restaurant,
      'color': Color(0xFF00BFA5),
      'phrases': [
        {
          'english': 'A table for two, please.',
          'turkish': 'İki kişilik bir masa, lütfen.'
        },
        {
          'english': 'Can I see the menu?',
          'turkish': 'Menüyü görebilir miyim?'
        },
        {
          'english': 'I would like to order.',
          'turkish': 'Sipariş vermek istiyorum.'
        },
        {'english': 'What do you recommend?', 'turkish': 'Ne önerirsiniz?'},
        {'english': 'Is this dish spicy?', 'turkish': 'Bu yemek acı mı?'},
        {'english': 'The bill, please.', 'turkish': 'Hesap, lütfen.'},
        {'english': 'It was delicious!', 'turkish': 'Çok lezzetliydi!'},
      ],
    },
    {
      'title': 'Alışveriş',
      'icon': Icons.shopping_bag,
      'color': Color(0xFF3F51B5),
      'phrases': [
        {'english': 'How much is this?', 'turkish': 'Bunun fiyatı ne kadar?'},
        {
          'english': 'Do you have this in another color?',
          'turkish': 'Bunun başka bir rengini var mı?'
        },
        {'english': 'Can I try it on?', 'turkish': 'Deneyebilir miyim?'},
        {'english': 'I\'m just looking.', 'turkish': 'Sadece bakıyorum.'},
        {'english': 'I\'ll take it.', 'turkish': 'Bunu alacağım.'},
        {
          'english': 'Do you accept credit cards?',
          'turkish': 'Kredi kartı kabul ediyor musunuz?'
        },
        {'english': 'Can I have a receipt?', 'turkish': 'Fiş alabilir miyim?'},
      ],
    },
    {
      'title': 'Acil Durumlar',
      'icon': Icons.emergency,
      'color': Color(0xFFE53935),
      'phrases': [
        {'english': 'Help!', 'turkish': 'İmdat!'},
        {'english': 'Call an ambulance!', 'turkish': 'Ambulans çağırın!'},
        {
          'english': 'I need a doctor.',
          'turkish': 'Bir doktora ihtiyacım var.'
        },
        {
          'english': 'Is there a hospital nearby?',
          'turkish': 'Yakınlarda bir hastane var mı?'
        },
        {'english': 'I\'m lost.', 'turkish': 'Kayboldum.'},
        {'english': 'I don\'t feel well.', 'turkish': 'İyi hissetmiyorum.'},
        {'english': 'I\'m allergic to...', 'turkish': '...e alerjim var.'},
      ],
    },
  ];

  int _selectedCategoryIndex = 0;
  bool _showPhrases = false;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final selectedCategory = _categories[_selectedCategoryIndex];
    final phrases = selectedCategory['phrases'] as List<Map<String, String>>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Günlük Konuşma Kalıpları',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _showPhrases = false;
              });
            },
            tooltip: 'Kategorilere dön',
          ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        child: _showPhrases
            ? _buildPhrasesList(isDark, phrases, selectedCategory)
            : _buildCategoriesList(isDark),
      ),
    );
  }

  Widget _buildCategoriesList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                  _showPhrases = true;
                });
              },
              child: Ink(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242424) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: category['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category['icon'],
                          color: category['color'],
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${(category['phrases'] as List).length} kalıp',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhrasesList(bool isDark, List<Map<String, String>> phrases,
      Map<String, dynamic> category) {
    return Column(
      children: [
        // Category header
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF242424) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Günlük konuşma kalıpları',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Phrases
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: phrases.length,
            itemBuilder: (context, index) {
              final phrase = phrases[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242424) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phrase['english']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        phrase['turkish']!,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Pronunciation or text-to-speech could be added here
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 20,
                                  color: category['color'],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
