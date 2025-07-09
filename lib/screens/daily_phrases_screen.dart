import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:revenue_cat_integration/service/revenue_cat_integration_service.dart';

class DailyPhrasesScreen extends ConsumerStatefulWidget {
  const DailyPhrasesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DailyPhrasesScreen> createState() => _DailyPhrasesScreenState();
}

class _DailyPhrasesScreenState extends ConsumerState<DailyPhrasesScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Selamlaşma',
      'icon': Icons.waving_hand,
      'color': Color(0xFF4F6CFF),
      'phrases': [
        {'english': 'Hello!', 'turkish': 'Merhaba!'},
        {'english': 'Good morning!', 'turkish': 'Günaydın!'},
        {
          'english': 'Good afternoon!',
          'turkish': 'Tünaydın!',
          'phonetic': 'Good afta noon!'
        },
        {
          'english': 'Good evening!',
          'turkish': 'İyi akşamlar!',
          'phonetic': 'Good eevning!'
        },
        {'english': 'Good night!', 'turkish': 'İyi geceler!'},
        {
          'english': 'How are you?',
          'turkish': 'Nasılsın?',
          'phonetic': 'How ar you?'
        },
        {
          'english': 'I\'m fine, thank you.',
          'turkish': 'İyiyim, teşekkür ederim.',
          'phonetic': 'Aim fine, thank you.'
        },
        {
          'english': 'Nice to meet you!',
          'turkish': 'Tanıştığımıza memnun oldum!',
          'phonetic': 'Nice to meet you!'
        },
        {'english': 'See you later!', 'turkish': 'Sonra görüşürüz!'},
        {
          'english': 'See you tomorrow!',
          'turkish': 'Yarın görüşürüz!',
          'phonetic': 'See you tomorow!'
        },
        {'english': 'Have a nice day!', 'turkish': 'İyi günler!'},
        {
          'english': 'Have a good weekend!',
          'turkish': 'İyi hafta sonları!',
          'phonetic': 'Have a good weekend!'
        },
        {
          'english': 'Welcome!',
          'turkish': 'Hoş geldiniz!',
          'phonetic': 'Welkam!'
        },
        {
          'english': 'Goodbye!',
          'turkish': 'Hoşça kal!',
          'phonetic': 'Goodbai!'
        },
        {
          'english': 'Take care!',
          'turkish': 'Kendine iyi bak!',
          'phonetic': 'Take kehr!'
        },
        {
          'english': 'Long time no see!',
          'turkish': 'Uzun zamandır görüşemedik!',
          'phonetic': 'Long taim no see!'
        },
        {
          'english': 'How\'s it going?',
          'turkish': 'Nasıl gidiyor?',
          'phonetic': 'Hows it going?'
        },
        {
          'english': 'How have you been?',
          'turkish': 'Nasıl gidiyordu?',
          'phonetic': 'How have you bin?'
        },
        {
          'english': 'It\'s nice to see you again!',
          'turkish': 'Seni tekrar görmek güzel!',
          'phonetic': 'Its nice to see you agen!'
        },
        {'english': 'How was your day?', 'turkish': 'Günün nasıl geçti?'},
      ],
    },
    {
      'title': 'Seyahat',
      'icon': Icons.airplane_ticket,
      'color': Color(0xFFFF9500),
      'phrases': [
        {
          'english': 'Can you help me?',
          'turkish': 'Bana yardım edebilir misiniz?',
          'phonetic': 'Ken you help mee?'
        },
        {
          'english': 'Where is the bathroom?',
          'turkish': 'Tuvalet nerede?',
          'phonetic': 'Wair iz the bathroom?'
        },
        {
          'english': 'How much does it cost?',
          'turkish': 'Ne kadar?',
          'phonetic': 'How much duz it cost?'
        },
        {
          'english': 'I need a taxi.',
          'turkish': 'Bir taksiye ihtiyacım var.',
          'phonetic': 'I need a taxi.'
        },
        {
          'english': 'Is there a hotel nearby?',
          'turkish': 'Yakınlarda bir otel var mı?',
          'phonetic': 'Iz there a hotel nearbai?'
        },
        {
          'english': 'What time is the check-in?',
          'turkish': 'Giriş saati kaçta?',
          'phonetic': 'What taim iz the check in?'
        },
        {
          'english': 'I have a reservation.',
          'turkish': 'Rezervasyonum var.',
          'phonetic': 'I hev a rezurveyshun.'
        },
        {
          'english': 'Where is the train station?',
          'turkish': 'Tren istasyonu nerede?',
          'phonetic': 'Wair iz the train steyshun?'
        },
        {
          'english': 'When does the bus leave?',
          'turkish': 'Otobüs ne zaman kalkıyor?',
          'phonetic': 'Wen duz the bus leev?'
        },
        {
          'english': 'I\'d like a ticket to...',
          'turkish': '...\'e bir bilet istiyorum.',
          'phonetic': 'Aid laik a tikit to...'
        },
        {
          'english': 'Is this seat taken?',
          'turkish': 'Bu koltuk dolu mu?',
          'phonetic': 'Iz this seat teyken?'
        },
        {
          'english': 'Do you have a city map?',
          'turkish': 'Şehir haritanız var mı?',
          'phonetic': 'Do you hev a siti map?'
        },
        {
          'english': 'I\'m lost.',
          'turkish': 'Kayboldum.',
          'phonetic': 'Aim lost.'
        },
        {
          'english': 'How do I get to the airport?',
          'turkish': 'Havalimanına nasıl gidebilirim?',
          'phonetic': 'How do I get to the airpohrt?'
        },
        {
          'english': 'What\'s the check-out time?',
          'turkish': 'Çıkış saati ne zaman?',
          'phonetic': 'Wots the check out taim?'
        },
        {
          'english': 'I need to change money.',
          'turkish': 'Para bozdurmalıyım.',
          'phonetic': 'I need to cheynj mani.'
        },
        {
          'english': 'Where can I rent a car?',
          'turkish': 'Nereden araba kiralayabilirim?',
          'phonetic': 'Wair ken I rent a car?'
        },
        {
          'english': 'Is breakfast included?',
          'turkish': 'Kahvaltı dahil mi?',
          'phonetic': 'Iz brekfast inklooded?'
        },
        {
          'english': 'Do you have any rooms available?',
          'turkish': 'Boş odanız var mı?',
          'phonetic': 'Do you hev eni rooms aveylabl?'
        },
        {
          'english': 'Can I get a receipt?',
          'turkish': 'Fiş alabilir miyim?',
          'phonetic': 'Ken I get a reeseet?'
        },
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
        {
          'english': 'Do you have vegetarian options?',
          'turkish': 'Vejetaryen seçenekleriniz var mı?'
        },
        {'english': 'I am allergic to...', 'turkish': '...e alerjim var.'},
        {
          'english': 'Can I have some water?',
          'turkish': 'Biraz su alabilir miyim?'
        },
        {'english': 'Where is the restroom?', 'turkish': 'Tuvalet nerede?'},
        {
          'english': 'I\'d like to make a reservation.',
          'turkish': 'Rezervasyon yaptırmak istiyorum.'
        },
        {
          'english': 'What\'s the specialty of the house?',
          'turkish': 'Evin özelliği nedir?'
        },
        {'english': 'Is service included?', 'turkish': 'Servis dahil mi?'},
        {
          'english': 'Can I pay by credit card?',
          'turkish': 'Kredi kartıyla ödeyebilir miyim?'
        },
        {
          'english': 'This is not what I ordered.',
          'turkish': 'Bu sipariş ettiğim şey değil.'
        },
        {
          'english': 'Can I have another fork?',
          'turkish': 'Başka bir çatal alabilir miyim?'
        },
        {
          'english': 'Is there a local dish I should try?',
          'turkish': 'Denemem gereken yerel bir yemek var mı?'
        },
        {
          'english': 'Can we sit outside?',
          'turkish': 'Dışarıda oturabilir miyiz?'
        },
        {
          'english': 'Can you recommend a good wine?',
          'turkish': 'İyi bir şarap önerebilir misiniz?'
        },
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
        {
          'english': 'Where is the fitting room?',
          'turkish': 'Deneme odası nerede?'
        },
        {
          'english': 'Do you have this in my size?',
          'turkish': 'Bunun benim bedenimde var mı?'
        },
        {
          'english': 'Can you gift wrap this?',
          'turkish': 'Bunu hediye paketi yapabilir misiniz?'
        },
        {'english': 'Is there a discount?', 'turkish': 'İndirim var mı?'},
        {
          'english': 'Where can I find...?',
          'turkish': '...nerede bulabilirim?'
        },
        {'english': 'This is too expensive.', 'turkish': 'Bu çok pahalı.'},
        {
          'english': 'Do you have anything cheaper?',
          'turkish': 'Daha ucuz bir şeyiniz var mı?'
        },
        {'english': 'Is this on sale?', 'turkish': 'Bu indirimde mi?'},
        {
          'english': 'Can I return this if needed?',
          'turkish': 'Gerekirse bunu iade edebilir miyim?'
        },
        {
          'english': 'What\'s your return policy?',
          'turkish': 'İade politikanız nedir?'
        },
        {'english': 'Do you deliver?', 'turkish': 'Teslimat yapıyor musunuz?'},
        {
          'english': 'Do you have this in stock?',
          'turkish': 'Bunun stoğu var mı?'
        },
        {
          'english': 'Can I speak to the manager?',
          'turkish': 'Müdürle konuşabilir miyim?'
        },
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
        {'english': 'Call the police!', 'turkish': 'Polisi arayın!'},
        {'english': 'There\'s been an accident.', 'turkish': 'Bir kaza oldu.'},
        {'english': 'I need help!', 'turkish': 'Yardıma ihtiyacım var!'},
        {'english': 'Fire!', 'turkish': 'Yangın!'},
        {
          'english': 'Where is the nearest pharmacy?',
          'turkish': 'En yakın eczane nerede?'
        },
        {
          'english': 'I\'ve lost my passport.',
          'turkish': 'Pasaportumu kaybettim.'
        },
        {'english': 'I\'ve been robbed.', 'turkish': 'Soyuldum.'},
        {
          'english': 'I need medication for...',
          'turkish': '...için ilaca ihtiyacım var.'
        },
        {'english': 'My car broke down.', 'turkish': 'Arabam bozuldu.'},
        {
          'english': 'Is there a dentist nearby?',
          'turkish': 'Yakınlarda bir dişçi var mı?'
        },
        {'english': 'I have a fever.', 'turkish': 'Ateşim var.'},
        {'english': 'I\'m having chest pain.', 'turkish': 'Göğüs ağrım var.'},
        {
          'english': 'My friend is unconscious.',
          'turkish': 'Arkadaşım bilinçsiz.'
        },
      ],
    },
    {
      'title': 'İş Hayatı',
      'icon': Icons.business_center,
      'color': Color(0xFF6200EA),
      'phrases': [
        {'english': 'I have an appointment.', 'turkish': 'Randevum var.'},
        {
          'english': 'I\'d like to schedule a meeting.',
          'turkish': 'Bir toplantı planlamak istiyorum.'
        },
        {
          'english': 'Could you send me that report?',
          'turkish': 'Bana o raporu gönderebilir misin?'
        },
        {
          'english': 'Let\'s discuss this later.',
          'turkish': 'Bunu daha sonra tartışalım.'
        },
        {
          'english': 'I agree with your proposal.',
          'turkish': 'Teklifinize katılıyorum.'
        },
        {
          'english': 'Could you explain that again?',
          'turkish': 'Bunu tekrar açıklayabilir misiniz?'
        },
        {
          'english': 'I\'ll get back to you on that.',
          'turkish': 'Bu konuda size geri döneceğim.'
        },
        {
          'english': 'What\'s the deadline for this project?',
          'turkish': 'Bu projenin son teslim tarihi nedir?'
        },
        {
          'english': 'I\'d like to introduce my colleague.',
          'turkish': 'İş arkadaşımı tanıtmak istiyorum.'
        },
        {
          'english': 'We need to reschedule.',
          'turkish': 'Yeniden planlamak zorundayız.'
        },
        {
          'english': 'Can we move the meeting to another day?',
          'turkish': 'Toplantıyı başka bir güne alabiliriz mi?'
        },
        {
          'english': 'I\'ll prepare a presentation.',
          'turkish': 'Bir sunum hazırlayacağım.'
        },
        {
          'english': 'Let me check my calendar.',
          'turkish': 'Takvimimi kontrol edeyim.'
        },
        {
          'english': 'Please keep me in the loop.',
          'turkish': 'Lütfen beni haberdar et.'
        },
        {
          'english': 'I need to take a day off.',
          'turkish': 'Bir gün izin almam gerekiyor.'
        },
        {'english': 'What\'s on the agenda?', 'turkish': 'Gündemde ne var?'},
        {
          'english': 'Let\'s schedule a follow-up meeting.',
          'turkish': 'Bir takip toplantısı planlayalım.'
        },
        {
          'english': 'I\'m working on the project now.',
          'turkish': 'Şu anda proje üzerinde çalışıyorum.'
        },
        {
          'english': 'Can you share the meeting minutes?',
          'turkish': 'Toplantı tutanaklarını paylaşabilir misiniz?'
        },
        {
          'english': 'I have a question about the budget.',
          'turkish': 'Bütçe hakkında bir sorum var.'
        },
      ],
    },
    {
      'title': 'Günlük Konuşma',
      'icon': Icons.chat_bubble,
      'color': Color(0xFF00B0FF),
      'phrases': [
        {'english': 'What\'s your name?', 'turkish': 'Adınız nedir?'},
        {'english': 'Where are you from?', 'turkish': 'Nerelisiniz?'},
        {
          'english': 'Do you speak English?',
          'turkish': 'İngilizce biliyor musunuz?'
        },
        {'english': 'I don\'t understand.', 'turkish': 'Anlamıyorum.'},
        {
          'english': 'Could you speak more slowly?',
          'turkish': 'Daha yavaş konuşabilir misiniz?'
        },
        {'english': 'How was your day?', 'turkish': 'Günün nasıl geçti?'},
        {
          'english': 'What do you do for a living?',
          'turkish': 'Ne iş yapıyorsunuz?'
        },
        {'english': 'How old are you?', 'turkish': 'Kaç yaşındasın?'},
        {'english': 'I like your shirt.', 'turkish': 'Gömleğini beğendim.'},
        {'english': 'What time is it?', 'turkish': 'Saat kaç?'},
        {
          'english': 'What\'s the weather like today?',
          'turkish': 'Bugün hava nasıl?'
        },
        {
          'english': 'Can I take a picture?',
          'turkish': 'Fotoğraf çekebilir miyim?'
        },
        {
          'english': 'Do you have any brothers or sisters?',
          'turkish': 'Kardeşlerin var mı?'
        },
        {'english': 'What are your hobbies?', 'turkish': 'Hobilerin nelerdir?'},
        {'english': 'I\'m learning Turkish.', 'turkish': 'Türkçe öğreniyorum.'},
        {
          'english': 'How long have you been here?',
          'turkish': 'Ne zamandır buradasın?'
        },
        {
          'english': 'What\'s your favorite food?',
          'turkish': 'En sevdiğin yemek nedir?'
        },
        {
          'english': 'Do you have any pets?',
          'turkish': 'Evcil hayvanın var mı?'
        },
        {
          'english': 'What are you doing this weekend?',
          'turkish': 'Bu hafta sonu ne yapıyorsun?'
        },
        {
          'english': 'It was nice talking to you.',
          'turkish': 'Seninle konuşmak güzeldi.'
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(adServiceProvider).loadBannerAd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Günlük Konuşma Kalıpları',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhraseDetailScreen(
                          category: category,
                        ),
                      ),
                    );
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
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: category['color'].withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              category['icon'],
                              color: category['color'],
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            category['color'].withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${(category['phrases'] as List).length} ifade',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: category['color'],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'En çok kullanılan kalıplar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: category['color'].withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: category['color'],
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: RevenueCatIntegrationService.instance.isPremium.value
          ? null
          : Consumer(
              builder: (context, ref, child) {
                final adService = ref.watch(adServiceProvider);
                final bannerAd = adService.getBannerAdWidget();
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: 60,
                  child: bannerAd != null
                      ? Center(child: bannerAd)
                      : const SizedBox.shrink(),
                );
              },
            ),
    );
  }
}

class PhraseDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> category;

  const PhraseDetailScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  ConsumerState<PhraseDetailScreen> createState() => _PhraseDetailScreenState();
}

class _PhraseDetailScreenState extends ConsumerState<PhraseDetailScreen> {
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;
  bool _isScrolling = false;
  Timer? _scrollTimer;
  final FlutterTts _flutterTts = FlutterTts();
  String? _currentlyPlayingPhrase;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(adServiceProvider).loadBannerAd();
      }
    });
  }

  void _initTts() async {
    // Set language to US English
    await _flutterTts.setLanguage("en-US");

    // Set speech rate (much slower for clearer pronunciation)
    await _flutterTts.setSpeechRate(0.3);

    // Set volume to maximum
    await _flutterTts.setVolume(1.0);

    // Set pitch to natural level
    await _flutterTts.setPitch(1.0);

    // Platform-specific settings
    if (Platform.isIOS) {
      // Enable shared instance for better iOS performance
      await _flutterTts.setSharedInstance(true);

      // Configure iOS audio session to allow mixing with other audio
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    } else if (Platform.isAndroid) {
      // Try to get available voices and set a good quality voice if available
      try {
        var voices = await _flutterTts.getVoices;
        if (voices.isNotEmpty) {
          // Look for a high-quality English voice
          var englishVoices = voices
              .where((voice) =>
                  voice['locale']?.toString().startsWith('en') == true)
              .toList();

          if (englishVoices.isNotEmpty) {
            await _flutterTts.setVoice(englishVoices.first);
          }
        }
      } catch (e) {
        print("Failed to get voices: $e");
      }
    }

    // Set up completion handler to reset playing state
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _currentlyPlayingPhrase = null;
      });
    });

    // Set up error handler
    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      setState(() {
        _currentlyPlayingPhrase = null;
      });
    });
  }

  Future<void> _speakPhrase(
      String phrase, Map<String, String> phraseData) async {
    if (_currentlyPlayingPhrase == phrase) {
      await _flutterTts.stop();
      setState(() {
        _currentlyPlayingPhrase = null;
      });
    } else {
      if (_currentlyPlayingPhrase != null) {
        await _flutterTts.stop();
      }

      setState(() {
        _currentlyPlayingPhrase = phrase;
      });

      // Use phonetic pronunciation if available, otherwise use the original phrase
      String textToSpeak = phraseData['phonetic'] ?? phrase;

      // Use focus parameter on Android for better audio handling
      if (Platform.isAndroid) {
        await _flutterTts.speak(textToSpeak, focus: true);
      } else {
        await _flutterTts.speak(textToSpeak);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  void _onScroll() {
    // Track scrolling state
    setState(() {
      _isScrolling = true;
    });

    // Reset the timer each time scroll happens
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _isScrolling = false;
      });
    });

    // Handle AppBar visibility
    if (_scrollController.offset > 120 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 120 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final phrases = widget.category['phrases'] as List<Map<String, String>>;
    final Color categoryColor = widget.category['color'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showAppBarTitle
            ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
            : Colors.transparent,
        elevation: _showAppBarTitle ? 2 : 0,
        title: _showAppBarTitle
            ? Text(
                widget.category['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              )
            : null,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _showAppBarTitle
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: _showAppBarTitle
          ? null
          : AnimatedOpacity(
              opacity: _isScrolling ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: FloatingActionButton.small(
                  elevation: 4,
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header section with category title and info
          SliverToBoxAdapter(
            child: AnimatedOpacity(
              opacity: _showAppBarTitle ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.3),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                widget.category['icon'],
                                color: categoryColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.category['title'],
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${phrases.length} ifade',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: categoryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'En çok kullanılan kalıplar',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
          ),
          // Phrases list
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final phrase = phrases[index];
                  final bool isPlaying =
                      _currentlyPlayingPhrase == phrase['english'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF242424) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: categoryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // English phrase with speaker icon
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            phrase['english']!,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _speakPhrase(
                                              phrase['english']!, phrase),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isPlaying
                                                  ? categoryColor
                                                      .withOpacity(0.3)
                                                  : categoryColor
                                                      .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: isPlaying
                                                  ? Border.all(
                                                      color: categoryColor,
                                                      width: 1)
                                                  : null,
                                            ),
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: Icon(
                                                isPlaying
                                                    ? Icons.stop_rounded
                                                    : Icons.volume_up_rounded,
                                                color: categoryColor,
                                                size: 22,
                                                key: ValueKey<bool>(isPlaying),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Turkish translation with decorative element
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF323232)
                                            : const Color(0xFFF8F8F8),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.grey[800]!
                                              : Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: categoryColor
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              phrase['turkish']!,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.grey[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: phrases.length,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: RevenueCatIntegrationService.instance.isPremium.value
          ? null
          : Consumer(
              builder: (context, ref, child) {
                final adService = ref.watch(adServiceProvider);
                final bannerAd = adService.getBannerAdWidget();
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: 60,
                  child: bannerAd != null
                      ? Center(child: bannerAd)
                      : const SizedBox.shrink(),
                );
              },
            ),
    );
  }
}
