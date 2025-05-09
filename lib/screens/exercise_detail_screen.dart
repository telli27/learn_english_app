import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../core/providers/ad_provider.dart';
import 'dart:ui';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String level;
  final Color color;
  final List<Map<String, dynamic>> exercises;

  const ExerciseDetailScreen({
    Key? key,
    required this.title,
    required this.level,
    required this.color,
    required this.exercises,
  }) : super(key: key);

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  final TextEditingController _practiceController = TextEditingController();
  final Map<int, List<String>> _exerciseSentences = {};
  int _currentStep = 0;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    // Load ads when screen opens
    ref.read(adServiceProvider).loadInterstitialAd();
    ref.read(adServiceProvider).loadRewardedAd();

    // Her alıştırma için boş liste başlat
    for (int i = 0; i < widget.exercises.length; i++) {
      _exerciseSentences[i] = [];
    }
  }

  @override
  void dispose() {
    _practiceController.dispose();
    super.dispose();
  }

  // Show rewarded ad for hint
  void _showRewardedAdForHint() {
    ref.read(adServiceProvider).showRewardedAd(
      onRewarded: () {
        setState(() {
          _showHint = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'İpucu kazandınız! Doğru cevap gösteriliyor.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    // Check if interstitial ad limit has been reached
    final isInterstitialLimitReached =
        ref.watch(isInterstitialLimitReachedProvider);
    // Check if rewarded ad limit has been reached
    final isRewardedLimitReached = ref.watch(isRewardedLimitReachedProvider);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(isDark),
                SliverToBoxAdapter(
                  child: _buildLevelDetails(isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildStepIndicator(isDark),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child:
                        _buildCurrentExercise(isDark, isRewardedLimitReached),
                  ),
                ),
              ],
            ),
          ),
          // Banner reklamı kaldırdık
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
      floatingActionButton: !isInterstitialLimitReached && _currentStep > 2
          ? FloatingActionButton(
              onPressed: () {
                // Show interstitial ad after completing a few exercises
                ref.read(adServiceProvider).showInterstitialAd();
              },
              backgroundColor: widget.color,
              child:
                  const Icon(Icons.emoji_events_outlined, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCurrentExercise(bool isDark, bool isRewardedLimitReached) {
    if (widget.exercises.isEmpty || _currentStep >= widget.exercises.length) {
      return const Center(child: Text('Alıştırma bulunamadı'));
    }

    final exercise = widget.exercises[_currentStep];
    final questions = exercise['questions'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original content
        for (var question in questions)
          if (question['type'] == 'example_sentence')
            _buildQuestionContent(question, isDark),

        // Add hint button if appropriate and not shown yet
        if (!_showHint && !isRewardedLimitReached)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextButton.icon(
              onPressed: _showRewardedAdForHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text("İpucu için Reklam İzle"),
              style: TextButton.styleFrom(
                foregroundColor: widget.color,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: widget.color,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    widget.color,
                    widget.color.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Decorative patterns
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              left: 30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Level badge
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildLevelIcon(widget.level),
                    const SizedBox(width: 6),
                    Text(
                      widget.level,
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIcon(String level) {
    if (level.contains('Beginner')) {
      return const Icon(Icons.star_border, color: Colors.green, size: 16);
    } else if (level.contains('Intermediate')) {
      return const Icon(Icons.star_half, color: Colors.blue, size: 16);
    } else {
      return const Icon(Icons.star, color: Colors.purple, size: 16);
    }
  }

  Widget _buildStepIndicator(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İlerleme: ${_currentStep + 1}/${widget.exercises.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    children: [
                      const TextSpan(text: 'Tahmini Süre: '),
                      TextSpan(
                        text: '${5 + (widget.exercises.length * 3)} dk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.exercises.length,
              itemBuilder: (context, index) {
                final isCompleted = _currentStep > index;
                final isCurrent = _currentStep == index;

                return Container(
                  width: (MediaQuery.of(context).size.width - 40) /
                      widget.exercises.length,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? widget.color
                              : isCurrent
                                  ? widget.color.withOpacity(0.5)
                                  : (isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: widget.color.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      if (isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Adım ${index + 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isCompleted && !isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Icon(
                            Icons.check_circle,
                            color: widget.color,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelContent(bool isDark) {
    String levelDescription = '';
    List<String> expectedSkills = [];
    Color progressColor;
    double progressValue;
    List<String> levelTips = [];
    Map<String, String> levelMethodology = {};

    switch (widget.level) {
      case 'Beginner (A1-A2)':
        levelDescription =
            'Temel günlük konuşma dili ve basit dil yapıları ile dil öğrenmenin ilk adımları. Bu seviyede kendinizi tanıtabilir, temel ihtiyaçlarınızı ifade edebilir ve günlük durumlarla başa çıkabilirsiniz.';
        expectedSkills = [
          'Temel kelimeler ve ifadeleri anlama ve kullanma',
          'Basit sorular sorabilme ve yanıtlayabilme',
          'Kendini kısaca tanıtabilme ve kişisel bilgiler verebilme',
          'Günlük aktiviteleri anlatabilme ve rutinleri açıklayabilme',
          'Basit talimatları anlayabilme ve uygulayabilme',
          'Rakamları, tarihleri, saatleri ve fiyatları tanıyabilme',
          'Yön tariflerini anlayabilme ve basit yol tarifi verebilme',
          'Temel ihtiyaçlarını ifade edebilme ve günlük hayatta kullanabilme',
          'Basit metinleri okuyup anlayabilme',
          'Kısa ve basit mesajlar yazabilme'
        ];
        levelTips = [
          'Günlük pratik yaparak kelime dağarcığınızı genişletin (5 yeni kelime öğrenmek için her gün 15 dakika ayırın)',
          'Basit diyalogları tekrar ederek konuşma pratiği yapın ve bunları günlük hayata entegre edin',
          'Görsel hafıza kartları kullanarak kelimeleri daha etkili öğrenin',
          'Kısa çizgi filmler ve basit videolar izleyerek dinleme becerilerinizi geliştirin',
          'Kelimeleri öğrenirken resimlerle ve gerçek nesnelerle ilişkilendirerek kalıcılığı artırın',
          'Telaffuzu düzeltmek için sesli okuma yapın ve ses kayıtlarını dinleyin',
          'Basit cümle yapılarını tekrarlayarak hafızanıza yerleştirin ve sık kullanın',
          'Öğrendiğiniz kelimeleri kategorize ederek daha organize çalışın (ev eşyaları, yiyecekler, renkler vb.)',
          'Başlangıç seviyesi İngilizce metinler okuyun ve sesli okuma pratiği yapın'
        ];
        levelMethodology = {
          'Yöntem': 'İnteraktif Öğrenme ve Tekrar Modeli',
          'Yaklaşım':
              'Yapı odaklı, pratik temelli, görsel ve işitsel destekli öğrenme',
          'Süre': 'Günde 20-30 dakika düzenli pratik yapın',
          'Tekrar': 'Her kelime grubu için en az 5-7 tekrar uygulayın',
          'Odak': 'Temel kelime hazinesi ve günlük kullanım için dil yapıları',
          'Hedef': 'Temel iletişim becerileri kazanmak'
        };
        progressColor = Colors.green;
        progressValue = 0.25;
        break;
      case 'Intermediate (B1-B2)':
        levelDescription =
            'Günlük ve iş hayatında etkin iletişim kurabilme becerileri. Bu seviyede soyut konularda konuşabilir, görüşlerinizi detaylı açıklayabilir ve çeşitli bağlamlarda dilinizi uyarlayabilirsiniz.';
        expectedSkills = [
          'Farklı zaman dilimlerini doğru ve yerinde kullanabilme',
          'Detaylı ve akıcı konuşma yapabilme, fikirlerini sıralayabilme',
          'Görüşlerini açık ve tutarlı bir şekilde ifade edebilme',
          'Metinlerdeki ana fikri ve alt metinleri anlayabilme',
          'Tartışmalara aktif olarak katılabilme ve argüman geliştirebilme',
          'Mesleki konularda etkili iletişim kurabilme ve sunum yapabilme',
          'Resmi ve gayri resmi üslup farkını anlayabilme ve uygulayabilme',
          'Dolaylı anlatımları ve ima edilen anlamları kavrayabilme',
          'Birleşik cümleler kurabilme ve kompleks yapıları kullanabilme',
          'Kültürel referansları anlayabilme ve uygun tepkiler verebilme',
          'Pasif yapıları, dolaylı anlatımı ve şart cümlelerini kullanabilme',
          'Akademik ve sosyal ortamlarda kendini ifade edebilme'
        ];
        levelTips = [
          'Orta seviye İngilizce kitaplar okuyun ve notlar alarak kelime listeleri oluşturun',
          'Dizi ve filmleri önce altyazılı, sonra altyazısız izlemeyi deneyin',
          'Günlük tutarak yazma becerinizi geliştirin ve farklı konularda denemeler yazın',
          'Deyim ve kalıp ifadeleri günlük konuşmalarınıza dahil edin ve kullanım bağlamlarını öğrenin',
          'Gerçek hayat durumlarında İngilizce konuşma pratiği yapın ve dil değişim arkadaşları edinin',
          'Farklı temalar üzerine tartışmalara katılın ve görüşlerinizi İngilizce savunun',
          'Telaffuz ve tonlama üzerine çalışarak aksan geliştirin, vurgu noktalarına dikkat edin',
          'İş ve kariyer ile ilgili terimleri sektörünüze göre özelleştirerek öğrenin',
          'Podcastler dinleyerek farklı aksanları ve konuşma stillerini tanıyın',
          'Metinlerdeki gramer yapılarını analiz ederek kendi cümlelerinizde kullanın',
          'Anadili İngilizce olan kişilerin konuşmalarını dikkatle dinleyin ve önemli kalıpları not edin'
        ];
        levelMethodology = {
          'Yöntem': 'Bağlamsal Öğrenme ve Uygulama Metodu',
          'Yaklaşım':
              'İletişim odaklı, doğal dil kullanımı ve bağlam içinde öğrenme',
          'Süre': 'Günde 30-45 dakika yoğun ve düzenli pratik',
          'Tekrar':
              'Öğrendiklerinizi farklı bağlamlarda ve senaryolarda kullanın',
          'Odak': 'Akıcı konuşma, karmaşık yapıları anlama ve doğru kullanım',
          'Hedef': 'Profesyonel ve sosyal ortamlarda etkili iletişim'
        };
        progressColor = Colors.blue;
        progressValue = 0.65;
        break;
      case 'Advanced (C1-C2)':
        levelDescription =
            'Akıcı ve doğal iletişim, akademik ve profesyonel dil kullanımı ile anadili gibi İngilizce konuşabilme. Bu seviyede karmaşık metinleri anlayabilir, ince anlamları kavrayabilir ve dili yaratıcı şekilde kullanabilirsiniz.';
        expectedSkills = [
          'Karmaşık metinleri ve akademik içerikleri derinlemesine anlayabilme',
          'İnce detay, vurgu ve nüanslarla etkili konuşabilme',
          'Akademik ve teknik dili doğru bağlamda kullanabilme',
          'Deyimler, atasözleri ve özel ifadeleri yerinde kullanabilme',
          'Soyut konularda ve felsefi tartışmalarda rahatça fikir beyan edebilme',
          'Üslup ve tonlamayı duruma, muhataba ve bağlama göre ayarlayabilme',
          'Anadili İngilizce olanlar kadar akıcı, doğal ve etkileyici konuşabilme',
          'Edebiyat, kültür ve tarihsel referansları anlayıp kullanabilme',
          'Her türlü yazılı metni uygun üslup ve yapı ile oluşturabilme',
          'Kompleks argümanlar geliştirebilme ve ikna edici konuşmalar yapabilme',
          'Mizah, ironi ve imaları anlayabilme ve yerinde kullanabilme',
          'Farklı aksanları tanıyabilme ve global iletişim bağlamında dilinizi uyarlayabilme',
          'Retorik ve stilistik araçları etkili şekilde kullanabilme'
        ];
        levelTips = [
          'Akademik makaleler, gazete köşe yazıları ve edebi eserler okuyun',
          'Çeşitli konulardaki podcastleri takip edin ve detaylı notlar alın',
          'Yabancılarla düzenli ve derinlemesine konuşmalar yapın, tartışmalara katılın',
          'Farklı ülkelerden İngilizce konuşanların aksanlarını anlamaya ve ayırt etmeye çalışın',
          'Edebi eserler ve akademik çalışmalar okuyarak üst düzey kelime dağarcığı geliştirin',
          'Uluslararası tartışma gruplarına katılın ve karmaşık konularda görüşlerinizi savunun',
          'Uzmanlık alanınızda İngilizce sunumlar yapın ve makaleler yazın',
          'Konuşma ve yazma stilinizi geliştirmek için edebi teknikler ve retorik araçlar kullanın',
          'Simultane tercüme alıştırmaları yaparak hızlı düşünme ve diller arası geçiş yeteneğinizi geliştirin',
          'İngilizce film, dizi ve belgeselleri altyazısız izleyin ve kültürel referansları araştırın',
          'Edebi metinlerde ve şiirlerde metaforları ve mecazları analiz edin',
          'Farklı türden yazılar (deneme, makale, rapor, hikaye) yazarak yazım becerilerinizi geliştirin'
        ];
        levelMethodology = {
          'Yöntem': 'Üst Düzey Dil Modeli ve Entegrasyon Yaklaşımı',
          'Yaklaşım':
              'Analitik düşünme, detaylı kavrama ve bütünleştirici kullanım',
          'Süre':
              'Günde 45-60 dakika derin odaklanma ve konsantrasyon gerektiren pratikler',
          'Tekrar':
              'Öğrendiklerinizi profesyonel, akademik ve sosyal ortamlarda uygulayın',
          'Odak':
              'İnce ayrıntılar, kültürel referanslar, özgün ifade ve yaratıcı dil kullanımı',
          'Hedef':
              'Anadile yakın akıcılık ve global iletişimde üst düzey yetkinlik'
        };
        progressColor = Colors.purple;
        progressValue = 0.9;
        break;
      default:
        levelDescription = 'Dil öğrenme yolculuğunuz';
        expectedSkills = ['Temel iletişim becerileri'];
        levelTips = ['Düzenli pratik yapın'];
        levelMethodology = {
          'Yöntem': 'Kişiselleştirilmiş Öğrenme',
          'Yaklaşım': 'Çok yönlü dil gelişimi',
          'Süre': 'Günde 20-45 dakika pratik'
        };
        progressColor = Colors.orange;
        progressValue = 0.5;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2D2D3A), const Color(0xFF1D1D2B)]
              : [Colors.white, const Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: progressColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seviye Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  progressColor.withOpacity(0.7),
                  progressColor.withOpacity(0.5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                // Seviye İkonu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getLevelIconData(widget.level),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Seviye Bilgisi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.level,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        levelDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // İlerleme Durumu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seviye İlerlemeniz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(progressValue * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // İlerleme Çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        height: 12,
                        width: MediaQuery.of(context).size.width *
                            progressValue *
                            0.8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              progressColor,
                              progressColor.withOpacity(0.8)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Beceriler Başlığı
                Text(
                  'Bu Seviyede Kazanılacak Beceriler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Beceriler Listesi
                ...expectedSkills
                    .map((skill) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: progressColor,
                                size: 16,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  skill,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),

                const SizedBox(height: 20),

                // İpuçları
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.shade800.withOpacity(0.3)
                        : progressColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: progressColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: progressColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seviye İpuçları',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: progressColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...levelTips
                          .take(2)
                          .map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: progressColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(
      double progressValue, Color progressColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Seviye İlerlemeniz',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${(progressValue * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3A3A4A)
                      : const Color(0xFFEEF1F9),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutQuart,
                height: 10,
                width: MediaQuery.of(context).size.width * progressValue * 0.75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      progressColor,
                      progressColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // CEFR Levels
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLevelCircle(
                    'A1', 0.17, progressValue, progressColor, isDark),
                _buildLevelCircle(
                    'A2', 0.33, progressValue, progressColor, isDark),
                _buildLevelCircle(
                    'B1', 0.5, progressValue, progressColor, isDark),
                _buildLevelCircle(
                    'B2', 0.67, progressValue, progressColor, isDark),
                _buildLevelCircle(
                    'C1', 0.83, progressValue, progressColor, isDark),
                _buildLevelCircle(
                    'C2', 1.0, progressValue, progressColor, isDark),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMethodologyItem(
                  Icons.settings_suggest,
                  isDark,
                  'Yaklaşım:',
                  'İnteraktif',
                ),
                _buildMethodologyItem(
                  Icons.repeat,
                  isDark,
                  'Tekrar:',
                  'Düzenli',
                ),
                _buildMethodologyItem(
                  Icons.trending_up,
                  isDark,
                  'Hedef:',
                  'İlerleme',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodologyItem(
      IconData icon, bool isDark, String title, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252532) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsTab(
      List<String> expectedSkills, Color progressColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kazanacağınız Beceriler',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: expectedSkills.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: progressColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          expectedSkills[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab(List<String> levelTips, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Öğrenme İpuçları',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: levelTips.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252532) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          levelTips[index],
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelStat(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCircle(String label, double position, double progress,
      Color color, bool isDark) {
    final bool isReached = progress >= position;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isReached ? color : Colors.transparent,
            border: Border.all(
              color: isReached
                  ? color
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: isReached
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
            color: isReached
                ? color
                : (isDark ? Colors.grey.shade500 : Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  IconData _getLevelIconData(String level) {
    if (level.contains('Beginner')) {
      return Icons.star_border_rounded;
    } else if (level.contains('Intermediate')) {
      return Icons.star_half_rounded;
    } else {
      return Icons.star_rounded;
    }
  }

  Widget _buildQuestionContent(Map<String, dynamic> question, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Learning topic - simplified
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school,
                      color: widget.color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Öğrenilecek Konu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                question['explanation'],
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // Examples - Simplified
        if (question['examples'] != null &&
            question['examples'].isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: widget.color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Örnek Cümleler',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: question['examples'].length,
            itemBuilder: (context, index) {
              return _buildExampleItem(question['examples'][index], isDark);
            },
          ),
          const SizedBox(height: 24),
        ],

        // Practice - Simplified
        if (question['practice'] != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: widget.color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alıştırma',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showHint = !_showHint;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showHint ? Icons.visibility : Icons.visibility_off,
                          color: widget.color,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showHint ? 'İpucunu Gizle' : 'İpucu Göster',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Task container
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252532) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['practice'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.5,
                  ),
                ),

                // Hint
                if (_showHint) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getHint(question['title']),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // User sentences
          if (_exerciseSentences[_currentStep]!.isNotEmpty)
            _buildUserSentencesList(isDark),

          // Input field
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252532) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _practiceController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cümlenizi yazın...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () {
                      final text = _practiceController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          _exerciseSentences[_currentStep]!.add(text);
                          _practiceController.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExampleItem(Map<String, dynamic> example, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252532) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // English sentence
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.language,
                    color: widget.color,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    example['english'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 16),
                  color: widget.color,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ses özelliği yakında eklenecek!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Turkish translation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.translate,
                    color: Colors.red,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    example['turkish'],
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? Colors.white.withOpacity(0.85)
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Explanation (if any)
          if (example['explanation'] != null &&
              example['explanation'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.amber,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      example['explanation'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withOpacity(0.75)
                            : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserSentencesList(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252532) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: widget.color),
              const SizedBox(width: 8),
              Text(
                'Yazdığınız Cümleler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exerciseSentences[_currentStep]!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _exerciseSentences[_currentStep]![index],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _exerciseSentences[_currentStep]!.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show progress stats
            if (_currentStep > 0) ...[
              LinearProgressIndicator(
                value: (_currentStep + 1) / widget.exercises.length,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                color: widget.color,
                minHeight: 4,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Önceki'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.color,
                        side: BorderSide(color: widget.color),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_currentStep < widget.exercises.length - 1) {
                        setState(() {
                          _currentStep++;
                          _showHint = false;
                        });
                      } else {
                        // Completion animation
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Tebrikler!'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: 50,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                    'Bu alıştırmayı başarıyla tamamladınız!'),
                                const SizedBox(height: 8),
                                Text(
                                  'Dil beceriniz her geçen gün gelişiyor.',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Teşekkürler'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.color,
                                ),
                                child: const Text('Ana Sayfaya Dön'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: Icon(_currentStep < widget.exercises.length - 1
                        ? Icons.arrow_forward
                        : Icons.check_circle),
                    label: Text(
                      _currentStep < widget.exercises.length - 1
                          ? 'Sonraki'
                          : 'Tamamlandı',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: widget.color.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTopicIcon(String title) {
    if (title.contains('Temel') || title.contains('Basic')) {
      return Icons.menu_book;
    } else if (title.contains('Renkler') || title.contains('Colors')) {
      return Icons.palette;
    } else if (title.contains('Sayılar') || title.contains('Numbers')) {
      return Icons.tag;
    } else if (title.contains('Tanıtma') || title.contains('Introduction')) {
      return Icons.person;
    } else if (title.contains('Zaman') || title.contains('Time')) {
      return Icons.access_time;
    } else if (title.contains('Be') || title.contains('Olmak')) {
      return Icons.text_fields;
    } else if (title.contains('Past') || title.contains('Geçmiş')) {
      return Icons.history;
    } else if (title.contains('Akademik') || title.contains('Academic')) {
      return Icons.school;
    } else if (title.contains('Cümle') || title.contains('Sentence')) {
      return Icons.text_snippet;
    }
    return Icons.language;
  }

  String _getHint(String title) {
    if (title.contains('Temel') || title.contains('Basic')) {
      return 'Günlük hayatta kullanılan temel kelimeleri içeren cümleler kurmaya çalışın. "I, you, we" gibi zamirlerle başlayabilirsiniz.';
    } else if (title.contains('Renkler') || title.contains('Colors')) {
      return 'Renkleri tanımlarken "The sky is blue", "My shirt is red" gibi ifadeler kullanabilirsiniz.';
    } else if (title.contains('Sayılar') || title.contains('Numbers')) {
      return 'Miktar belirtirken "I have two brothers", "There are five books" gibi cümleler kurabilirsiniz.';
    } else if (title.contains('Tanıtma') || title.contains('Introduction')) {
      return 'Kendinizi tanıtırken yaş, meslek, ülke gibi bilgileri "I am ... years old", "I work as a ..." şeklinde kullanabilirsiniz.';
    } else if (title.contains('Be') || title.contains('Olmak')) {
      return '"am, is, are" yardımcı fiillerini kullanarak "She is a teacher", "I am happy", "They are at home" gibi cümleler kurabilirsiniz.';
    } else if (title.contains('Past') || title.contains('Geçmiş')) {
      return 'Geçmiş zaman için fiillerin -ed halini veya düzensiz fiillerin ikinci halini kullanın: "walked, went, saw" gibi.';
    } else if (title.contains('Akademik') || title.contains('Academic')) {
      return 'Akademik yazıda "furthermore, however, nevertheless" gibi bağlaçları ve resmi dil yapısını kullanabilirsiniz.';
    } else if (title.contains('Complex') || title.contains('Karmaşık')) {
      return 'Yan cümlecikler için "who, which, that, when, after, because" gibi bağlaçları kullanabilirsiniz.';
    }
    return 'Örnek cümlelere bakarak benzer yapıda kendi cümlelerinizi oluşturmaya çalışın.';
  }

  bool isDarkMode(BuildContext context) {
    return ref.read(isDarkModeProvider);
  }

  Widget _buildLevelDetails(bool isDark) {
    String levelDescription = '';
    List<String> expectedSkills = [];
    Color progressColor;
    double progressValue;
    List<String> tipList = [];
    Map<String, String> levelMethodology = {};

    switch (widget.level) {
      case 'Beginner (A1-A2)':
        levelDescription =
            'Temel günlük konuşma dili ve basit dil yapıları ile dil öğrenmenin ilk adımları. Bu seviyede kendinizi tanıtabilir, temel ihtiyaçlarınızı ifade edebilir ve günlük durumlarla başa çıkabilirsiniz.';
        expectedSkills = [
          'Temel kelimeler ve ifadeleri anlama ve kullanma',
          'Basit sorular sorabilme ve yanıtlayabilme',
          'Kendini kısaca tanıtabilme ve kişisel bilgiler verebilme',
          'Günlük aktiviteleri anlatabilme ve rutinleri açıklayabilme',
          'Basit talimatları anlayabilme ve uygulayabilme',
          'Rakamları, tarihleri, saatleri ve fiyatları tanıyabilme',
          'Yön tariflerini anlayabilme ve basit yol tarifi verebilme',
          'Temel ihtiyaçlarını ifade edebilme ve günlük hayatta kullanabilme',
          'Basit metinleri okuyup anlayabilme',
          'Kısa ve basit mesajlar yazabilme'
        ];
        tipList = [
          'Günlük pratik yaparak kelime dağarcığınızı genişletin (5 yeni kelime öğrenmek için her gün 15 dakika ayırın)',
          'Basit diyalogları tekrar ederek konuşma pratiği yapın ve bunları günlük hayata entegre edin',
          'Görsel hafıza kartları kullanarak kelimeleri daha etkili öğrenin',
          'Kısa çizgi filmler ve basit videolar izleyerek dinleme becerilerinizi geliştirin',
          'Kelimeleri öğrenirken resimlerle ve gerçek nesnelerle ilişkilendirerek kalıcılığı artırın',
          'Telaffuzu düzeltmek için sesli okuma yapın ve ses kayıtlarını dinleyin',
          'Basit cümle yapılarını tekrarlayarak hafızanıza yerleştirin ve sık kullanın',
          'Öğrendiğiniz kelimeleri kategorize ederek daha organize çalışın (ev eşyaları, yiyecekler, renkler vb.)',
          'Başlangıç seviyesi İngilizce metinler okuyun ve sesli okuma pratiği yapın'
        ];
        levelMethodology = {
          'Yöntem': 'İnteraktif Öğrenme ve Tekrar Modeli',
          'Yaklaşım':
              'Yapı odaklı, pratik temelli, görsel ve işitsel destekli öğrenme',
          'Süre': 'Günde 20-30 dakika düzenli pratik yapın',
          'Tekrar': 'Her kelime grubu için en az 5-7 tekrar uygulayın',
          'Odak': 'Temel kelime hazinesi ve günlük kullanım için dil yapıları',
          'Hedef': 'Temel iletişim becerileri kazanmak'
        };
        progressColor = Colors.green;
        progressValue = 0.25;
        break;
      case 'Intermediate (B1-B2)':
        levelDescription =
            'Günlük ve iş hayatında etkin iletişim kurabilme becerileri. Bu seviyede soyut konularda konuşabilir, görüşlerinizi detaylı açıklayabilir ve çeşitli bağlamlarda dilinizi uyarlayabilirsiniz.';
        expectedSkills = [
          'Farklı zaman dilimlerini doğru ve yerinde kullanabilme',
          'Detaylı ve akıcı konuşma yapabilme, fikirlerini sıralayabilme',
          'Görüşlerini açık ve tutarlı bir şekilde ifade edebilme',
          'Metinlerdeki ana fikri ve alt metinleri anlayabilme',
          'Tartışmalara aktif olarak katılabilme ve argüman geliştirebilme',
          'Mesleki konularda etkili iletişim kurabilme ve sunum yapabilme',
          'Resmi ve gayri resmi üslup farkını anlayabilme ve uygulayabilme',
          'Dolaylı anlatımları ve ima edilen anlamları kavrayabilme',
          'Birleşik cümleler kurabilme ve kompleks yapıları kullanabilme',
          'Kültürel referansları anlayabilme ve uygun tepkiler verebilme',
          'Pasif yapıları, dolaylı anlatımı ve şart cümlelerini kullanabilme',
          'Akademik ve sosyal ortamlarda kendini ifade edebilme'
        ];
        tipList = [
          'Orta seviye İngilizce kitaplar okuyun ve notlar alarak kelime listeleri oluşturun',
          'Dizi ve filmleri önce altyazılı, sonra altyazısız izlemeyi deneyin',
          'Günlük tutarak yazma becerinizi geliştirin ve farklı konularda denemeler yazın',
          'Deyim ve kalıp ifadeleri günlük konuşmalarınıza dahil edin ve kullanım bağlamlarını öğrenin',
          'Gerçek hayat durumlarında İngilizce konuşma pratiği yapın ve dil değişim arkadaşları edinin',
          'Farklı temalar üzerine tartışmalara katılın ve görüşlerinizi İngilizce savunun',
          'Telaffuz ve tonlama üzerine çalışarak aksan geliştirin, vurgu noktalarına dikkat edin',
          'İş ve kariyer ile ilgili terimleri sektörünüze göre özelleştirerek öğrenin',
          'Podcastler dinleyerek farklı aksanları ve konuşma stillerini tanıyın',
          'Metinlerdeki gramer yapılarını analiz ederek kendi cümlelerinizde kullanın',
          'Anadili İngilizce olan kişilerin konuşmalarını dikkatle dinleyin ve önemli kalıpları not edin'
        ];
        levelMethodology = {
          'Yöntem': 'Bağlamsal Öğrenme ve Uygulama Metodu',
          'Yaklaşım':
              'İletişim odaklı, doğal dil kullanımı ve bağlam içinde öğrenme',
          'Süre': 'Günde 30-45 dakika yoğun ve düzenli pratik',
          'Tekrar':
              'Öğrendiklerinizi farklı bağlamlarda ve senaryolarda kullanın',
          'Odak': 'Akıcı konuşma, karmaşık yapıları anlama ve doğru kullanım',
          'Hedef': 'Profesyonel ve sosyal ortamlarda etkili iletişim'
        };
        progressColor = Colors.blue;
        progressValue = 0.65;
        break;
      case 'Advanced (C1-C2)':
        levelDescription =
            'Akıcı ve doğal iletişim, akademik ve profesyonel dil kullanımı ile anadili gibi İngilizce konuşabilme. Bu seviyede karmaşık metinleri anlayabilir, ince anlamları kavrayabilir ve dili yaratıcı şekilde kullanabilirsiniz.';
        expectedSkills = [
          'Karmaşık metinleri ve akademik içerikleri derinlemesine anlayabilme',
          'İnce detay, vurgu ve nüanslarla etkili konuşabilme',
          'Akademik ve teknik dili doğru bağlamda kullanabilme',
          'Deyimler, atasözleri ve özel ifadeleri yerinde kullanabilme',
          'Soyut konularda ve felsefi tartışmalarda rahatça fikir beyan edebilme',
          'Üslup ve tonlamayı duruma, muhataba ve bağlama göre ayarlayabilme',
          'Anadili İngilizce olanlar kadar akıcı, doğal ve etkileyici konuşabilme',
          'Edebiyat, kültür ve tarihsel referansları anlayıp kullanabilme',
          'Her türlü yazılı metni uygun üslup ve yapı ile oluşturabilme',
          'Kompleks argümanlar geliştirebilme ve ikna edici konuşmalar yapabilme',
          'Mizah, ironi ve imaları anlayabilme ve yerinde kullanabilme',
          'Farklı aksanları tanıyabilme ve global iletişim bağlamında dilinizi uyarlayabilme',
          'Retorik ve stilistik araçları etkili şekilde kullanabilme'
        ];
        tipList = [
          'Akademik makaleler, gazete köşe yazıları ve edebi eserler okuyun',
          'Çeşitli konulardaki podcastleri takip edin ve detaylı notlar alın',
          'Yabancılarla düzenli ve derinlemesine konuşmalar yapın, tartışmalara katılın',
          'Farklı ülkelerden İngilizce konuşanların aksanlarını anlamaya ve ayırt etmeye çalışın',
          'Edebi eserler ve akademik çalışmalar okuyarak üst düzey kelime dağarcığı geliştirin',
          'Uluslararası tartışma gruplarına katılın ve karmaşık konularda görüşlerinizi savunun',
          'Uzmanlık alanınızda İngilizce sunumlar yapın ve makaleler yazın',
          'Konuşma ve yazma stilinizi geliştirmek için edebi teknikler ve retorik araçlar kullanın',
          'Simultane tercüme alıştırmaları yaparak hızlı düşünme ve diller arası geçiş yeteneğinizi geliştirin',
          'İngilizce film, dizi ve belgeselleri altyazısız izleyin ve kültürel referansları araştırın',
          'Edebi metinlerde ve şiirlerde metaforları ve mecazları analiz edin',
          'Farklı türden yazılar (deneme, makale, rapor, hikaye) yazarak yazım becerilerinizi geliştirin'
        ];
        levelMethodology = {
          'Yöntem': 'Üst Düzey Dil Modeli ve Entegrasyon Yaklaşımı',
          'Yaklaşım':
              'Analitik düşünme, detaylı kavrama ve bütünleştirici kullanım',
          'Süre':
              'Günde 45-60 dakika derin odaklanma ve konsantrasyon gerektiren pratikler',
          'Tekrar':
              'Öğrendiklerinizi profesyonel, akademik ve sosyal ortamlarda uygulayın',
          'Odak':
              'İnce ayrıntılar, kültürel referanslar, özgün ifade ve yaratıcı dil kullanımı',
          'Hedef':
              'Anadile yakın akıcılık ve global iletişimde üst düzey yetkinlik'
        };
        progressColor = Colors.purple;
        progressValue = 0.9;
        break;
      default:
        levelDescription = 'Dil öğrenme yolculuğunuz';
        expectedSkills = ['Temel iletişim becerileri'];
        tipList = ['Düzenli pratik yapın'];
        levelMethodology = {
          'Yöntem': 'Kişiselleştirilmiş Öğrenme',
          'Yaklaşım': 'Çok yönlü dil gelişimi',
          'Süre': 'Günde 20-45 dakika pratik'
        };
        progressColor = Colors.orange;
        progressValue = 0.5;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2D2D3A), const Color(0xFF1D1D2B)]
              : [Colors.white, const Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: progressColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seviye Başlığı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  progressColor.withOpacity(0.7),
                  progressColor.withOpacity(0.5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                // Seviye İkonu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getLevelIconData(widget.level),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Seviye Bilgisi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.level,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        levelDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // İlerleme Durumu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seviye İlerlemeniz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(progressValue * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // İlerleme Çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        height: 12,
                        width: MediaQuery.of(context).size.width *
                            progressValue *
                            0.8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              progressColor,
                              progressColor.withOpacity(0.8)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Beceriler Başlığı
                Text(
                  'Bu Seviyede Kazanılacak Beceriler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Beceriler Listesi
                ...expectedSkills
                    .map((skill) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: progressColor,
                                size: 16,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  skill,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),

                const SizedBox(height: 20),

                // İpuçları
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.shade800.withOpacity(0.3)
                        : progressColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: progressColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: progressColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seviye İpuçları',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: progressColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...tipList
                          .take(2)
                          .map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: progressColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLevelIcon(String level) {
    if (level.contains('Beginner')) {
      return Icons.star_border_rounded;
    } else if (level.contains('Intermediate')) {
      return Icons.star_half_rounded;
    } else {
      return Icons.star_rounded;
    }
  }
}
