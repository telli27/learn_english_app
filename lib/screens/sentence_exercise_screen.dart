import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class SentenceExerciseScreen extends ConsumerStatefulWidget {
  final String topic;
  final Color color;

  const SentenceExerciseScreen({
    Key? key,
    required this.topic,
    required this.color,
  }) : super(key: key);

  @override
  ConsumerState<SentenceExerciseScreen> createState() =>
      _SentenceExerciseScreenState();
}

class _SentenceExerciseScreenState
    extends ConsumerState<SentenceExerciseScreen> {
  int _currentExerciseIndex = 0;
  List<String> _selectedWords = [];
  List<int> _selectedIndices = [];
  bool _showResult = false;
  bool _isCorrect = false;
  bool _showExplanation = true;

  // Topic grammar explanations
  final Map<String, String> _grammarExplanations = {
    'Present Simple':
        'Geniş zaman (Present Simple), düzenli olarak yaptığımız işleri, alışkanlıkları veya genel gerçekleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + Fiil (3. tekil şahısta -s eklenir)\n'
            '• Olumsuz cümle: Özne + do/does + not + Fiil\n'
            '• Soru cümlesi: Do/Does + Özne + Fiil',
    'Present Continuous':
        'Şimdiki zaman (Present Continuous), şu anda gerçekleşen veya yakın gelecekte planlanan eylemleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + am/is/are + Fiil-ing\n'
            '• Olumsuz cümle: Özne + am/is/are + not + Fiil-ing\n'
            '• Soru cümlesi: Am/Is/Are + Özne + Fiil-ing',
    'Past Simple':
        'Geçmiş zaman (Past Simple), geçmişte belirli bir zamanda tamamlanmış eylemleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + Fiil-ed/2. hali\n'
            '• Olumsuz cümle: Özne + did + not + Fiil\n'
            '• Soru cümlesi: Did + Özne + Fiil',
    'Past Continuous':
        'Geçmişte belirli bir anda devam etmekte olan eylemleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + was/were + Fiil-ing\n'
            '• Olumsuz cümle: Özne + was/were + not + Fiil-ing\n'
            '• Soru cümlesi: Was/Were + Özne + Fiil-ing',
    'Present Perfect':
        'Geçmişte başlayan ve şu anda etkisi devam eden veya henüz tamamlanmış eylemleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + have/has + Fiil (3. hali)\n'
            '• Olumsuz cümle: Özne + have/has + not + Fiil (3. hali)\n'
            '• Soru cümlesi: Have/Has + Özne + Fiil (3. hali)',
    'Present Perfect Continuous':
        'Geçmişte başlayan ve şu ana kadar devam eden eylemlerin süresini vurgulamak için kullanılır.\n\n'
            '• Olumlu cümle: Özne + have/has + been + Fiil-ing\n'
            '• Olumsuz cümle: Özne + have/has + not + been + Fiil-ing\n'
            '• Soru cümlesi: Have/Has + Özne + been + Fiil-ing',
    'Future Tense':
        'Gelecek zaman (Future Tense), gelecekte gerçekleşecek planları veya tahminleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + will/be going to + Fiil\n'
            '• Olumsuz cümle: Özne + will/be going to + not + Fiil\n'
            '• Soru cümlesi: Will/Be going to + Özne + Fiil',
    'Past Perfect':
        'Geçmişte, başka bir eylemden önce tamamlanmış eylemleri ifade etmek için kullanılır.\n\n'
            '• Olumlu cümle: Özne + had + Fiil (3. hali)\n'
            '• Olumsuz cümle: Özne + had + not + Fiil (3. hali)\n'
            '• Soru cümlesi: Had + Özne + Fiil (3. hali)',
  };

  // Exercise data for each topic
  final Map<String, List<Map<String, dynamic>>> _exercises = {
    'Present Simple': [
      {
        'words': ['she', 'coffee', 'drinks', 'every', 'morning'],
        'correctSentence': 'she drinks coffee every morning',
        'type': 'Olumlu Cümle',
        'meaning': 'O her sabah kahve içer.',
      },
      {
        'words': ['do', 'like', 'you', 'pizza'],
        'correctSentence': 'do you like pizza',
        'type': 'Soru Cümlesi',
        'meaning': 'Pizza sever misin?',
      },
      {
        'words': ['they', 'to', 'school', 'walk', 'usually'],
        'correctSentence': 'they usually walk to school',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar genellikle okula yürüyerek giderler.',
      },
      {
        'words': ['he', 'does', 'not', 'meat', 'eat'],
        'correctSentence': 'he does not eat meat',
        'type': 'Olumsuz Cümle',
        'meaning': 'O et yemez.',
      },
      {
        'words': ['English', 'speak', 'fluently', 'I'],
        'correctSentence': 'I speak English fluently',
        'type': 'Olumlu Cümle',
        'meaning': 'İngilizceyi akıcı konuşurum.',
      },
      {
        'words': ['your', 'where', 'does', 'live', 'brother'],
        'correctSentence': 'where does your brother live',
        'type': 'Soru Cümlesi',
        'meaning': 'Kardeşin nerede yaşıyor?',
      },
      {
        'words': ['always', 'on', 'breakfast', 'time', 'we', 'have'],
        'correctSentence': 'we always have breakfast on time',
        'type': 'Olumlu Cümle',
        'meaning': 'Her zaman kahvaltımızı zamanında yaparız.',
      },
      {
        'words': ['they', 'do', 'not', 'understand', 'the', 'problem'],
        'correctSentence': 'they do not understand the problem',
        'type': 'Olumsuz Cümle',
        'meaning': 'Onlar problemi anlamazlar.',
      },
      {
        'words': ['does', 'he', 'play', 'football', 'every', 'weekend'],
        'correctSentence': 'does he play football every weekend',
        'type': 'Soru Cümlesi',
        'meaning': 'O her hafta sonu futbol oynar mı?',
      },
      {
        'words': ['my', 'parents', 'travel', 'abroad', 'every', 'summer'],
        'correctSentence': 'my parents travel abroad every summer',
        'type': 'Olumlu Cümle',
        'meaning': 'Ailem her yaz yurtdışına seyahat eder.',
      },
    ],
    'Present Continuous': [
      {
        'words': ['is', 'now', 'raining', 'it'],
        'correctSentence': 'it is raining now',
        'type': 'Olumlu Cümle',
        'meaning': 'Şu anda yağmur yağıyor.',
      },
      {
        'words': ['are', 'what', 'doing', 'you'],
        'correctSentence': 'what are you doing',
        'type': 'Soru Cümlesi',
        'meaning': 'Ne yapıyorsun?',
      },
      {
        'words': ['she', 'is', 'for', 'studying', 'exam', 'the'],
        'correctSentence': 'she is studying for the exam',
        'type': 'Olumlu Cümle',
        'meaning': 'O, sınav için çalışıyor.',
      },
      {
        'words': ['we', 'are', 'not', 'today', 'working'],
        'correctSentence': 'we are not working today',
        'type': 'Olumsuz Cümle',
        'meaning': 'Bugün çalışmıyoruz.',
      },
      {
        'words': ['they', 'are', 'dinner', 'having', 'now'],
        'correctSentence': 'they are having dinner now',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar şu anda akşam yemeği yiyorlar.',
      },
      {
        'words': ['is', 'the', 'baby', 'crying', 'why'],
        'correctSentence': 'why is the baby crying',
        'type': 'Soru Cümlesi',
        'meaning': 'Bebek neden ağlıyor?',
      },
      {
        'words': ['are', 'you', 'listening', 'to', 'me'],
        'correctSentence': 'are you listening to me',
        'type': 'Soru Cümlesi',
        'meaning': 'Beni dinliyor musun?',
      },
      {
        'words': ['is', 'not', 'she', 'feeling', 'well', 'today'],
        'correctSentence': 'she is not feeling well today',
        'type': 'Olumsuz Cümle',
        'meaning': 'O bugün kendini iyi hissetmiyor.',
      },
      {
        'words': ['I', 'am', 'currently', 'reading', 'a', 'good', 'book'],
        'correctSentence': 'I am currently reading a good book',
        'type': 'Olumlu Cümle',
        'meaning': 'Şu anda iyi bir kitap okuyorum.',
      },
      {
        'words': ['they', 'are', 'planning', 'a', 'vacation', 'next', 'month'],
        'correctSentence': 'they are planning a vacation next month',
        'type': 'Olumlu Cümle',
        'meaning': 'Gelecek ay bir tatil planlıyorlar.',
      },
    ],
    'Past Simple': [
      {
        'words': ['visited', 'museum', 'they', 'the', 'yesterday'],
        'correctSentence': 'they visited the museum yesterday',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar dün müzeyi ziyaret ettiler.',
      },
      {
        'words': ['did', 'last', 'weekend', 'what', 'you', 'do'],
        'correctSentence': 'what did you do last weekend',
        'type': 'Soru Cümlesi',
        'meaning': 'Geçen hafta sonu ne yaptın?',
      },
      {
        'words': ['not', 'did', 'the', 'I', 'finish', 'book'],
        'correctSentence': 'I did not finish the book',
        'type': 'Olumsuz Cümle',
        'meaning': 'Kitabı bitirmedim.',
      },
      {
        'words': ['she', 'bought', 'a', 'new', 'car', 'last', 'month'],
        'correctSentence': 'she bought a new car last month',
        'type': 'Olumlu Cümle',
        'meaning': 'O geçen ay yeni bir araba satın aldı.',
      },
      {
        'words': ['did', 'where', 'you', 'go', 'to', 'school'],
        'correctSentence': 'where did you go to school',
        'type': 'Soru Cümlesi',
        'meaning': 'Nerede okula gittin?',
      },
      {
        'words': ['they', 'did', 'not', 'call', 'me', 'yesterday'],
        'correctSentence': 'they did not call me yesterday',
        'type': 'Olumsuz Cümle',
        'meaning': 'Dün beni aramadılar.',
      },
      {
        'words': ['we', 'watched', 'a', 'movie', 'last', 'night'],
        'correctSentence': 'we watched a movie last night',
        'type': 'Olumlu Cümle',
        'meaning': 'Dün gece bir film izledik.',
      },
      {
        'words': ['did', 'he', 'enjoy', 'the', 'party'],
        'correctSentence': 'did he enjoy the party',
        'type': 'Soru Cümlesi',
        'meaning': 'Partiden keyif aldı mı?',
      },
      {
        'words': ['I', 'did', 'not', 'hear', 'the', 'doorbell'],
        'correctSentence': 'I did not hear the doorbell',
        'type': 'Olumsuz Cümle',
        'meaning': 'Kapı zilini duymadım.',
      },
      {
        'words': ['she', 'wrote', 'a', 'letter', 'to', 'her', 'friend'],
        'correctSentence': 'she wrote a letter to her friend',
        'type': 'Olumlu Cümle',
        'meaning': 'Arkadaşına bir mektup yazdı.',
      },
    ],
    'Past Continuous': [
      {
        'words': ['was', 'watching', 'TV', 'I', 'when', 'you', 'called'],
        'correctSentence': 'I was watching TV when you called',
        'type': 'Olumlu Cümle',
        'meaning': 'Sen aradığında TV izliyordum.',
      },
      {
        'words': ['were', 'doing', 'what', 'you', 'at', '8', 'yesterday'],
        'correctSentence': 'what were you doing at 8 yesterday',
        'type': 'Soru Cümlesi',
        'meaning': 'Dün saat 8\'de ne yapıyordun?',
      },
      {
        'words': ['she', 'was', 'not', 'listening', 'to', 'the', 'teacher'],
        'correctSentence': 'she was not listening to the teacher',
        'type': 'Olumsuz Cümle',
        'meaning': 'O öğretmeni dinlemiyordu.',
      },
      {
        'words': ['they', 'were', 'playing', 'football', 'all', 'afternoon'],
        'correctSentence': 'they were playing football all afternoon',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar bütün öğleden sonra futbol oynuyorlardı.',
      },
      {
        'words': ['was', 'it', 'raining', 'when', 'you', 'left'],
        'correctSentence': 'was it raining when you left',
        'type': 'Soru Cümlesi',
        'meaning': 'Sen ayrıldığında yağmur yağıyor muydu?',
      },
      {
        'words': ['we', 'were', 'not', 'expecting', 'any', 'visitors'],
        'correctSentence': 'we were not expecting any visitors',
        'type': 'Olumsuz Cümle',
        'meaning': 'Hiç ziyaretçi beklemiyorduk.',
      },
      {
        'words': ['he', 'was', 'studying', 'while', 'I', 'was', 'cooking'],
        'correctSentence': 'he was studying while I was cooking',
        'type': 'Olumlu Cümle',
        'meaning': 'Ben yemek pişirirken o ders çalışıyordu.',
      },
      {
        'words': ['were', 'they', 'waiting', 'for', 'the', 'bus'],
        'correctSentence': 'were they waiting for the bus',
        'type': 'Soru Cümlesi',
        'meaning': 'Onlar otobüs için bekliyor muydu?',
      },
      {
        'words': ['she', 'was', 'not', 'feeling', 'well', 'yesterday'],
        'correctSentence': 'she was not feeling well yesterday',
        'type': 'Olumsuz Cümle',
        'meaning': 'O dün kendini iyi hissetmiyordu.',
      },
      {
        'words': [
          'I',
          'was',
          'reading',
          'a',
          'book',
          'at',
          'this',
          'time',
          'yesterday'
        ],
        'correctSentence': 'I was reading a book at this time yesterday',
        'type': 'Olumlu Cümle',
        'meaning': 'Dün bu saatte kitap okuyordum.',
      },
    ],
    'Present Perfect': [
      {
        'words': ['I', 'have', 'never', 'been', 'to', 'Paris'],
        'correctSentence': 'I have never been to Paris',
        'type': 'Olumlu Cümle',
        'meaning': 'Hiç Paris\'e gitmedim.',
      },
      {
        'words': ['have', 'you', 'finished', 'your', 'homework', 'yet'],
        'correctSentence': 'have you finished your homework yet',
        'type': 'Soru Cümlesi',
        'meaning': 'Ödevinizi bitirdiniz mi?',
      },
      {
        'words': ['she', 'has', 'not', 'seen', 'the', 'movie'],
        'correctSentence': 'she has not seen the movie',
        'type': 'Olumsuz Cümle',
        'meaning': 'O filmi görmedi.',
      },
      {
        'words': ['they', 'have', 'lived', 'here', 'for', 'ten', 'years'],
        'correctSentence': 'they have lived here for ten years',
        'type': 'Olumlu Cümle',
        'meaning': 'On yıldır burada yaşıyorlar.',
      },
      {
        'words': ['has', 'he', 'ever', 'visited', 'London'],
        'correctSentence': 'has he ever visited London',
        'type': 'Soru Cümlesi',
        'meaning': 'Hiç Londra\'yı ziyaret etti mi?',
      },
      {
        'words': ['we', 'have', 'not', 'received', 'any', 'news'],
        'correctSentence': 'we have not received any news',
        'type': 'Olumsuz Cümle',
        'meaning': 'Hiç haber almadık.',
      },
      {
        'words': ['I', 'have', 'already', 'eaten', 'lunch'],
        'correctSentence': 'I have already eaten lunch',
        'type': 'Olumlu Cümle',
        'meaning': 'Çoktan öğle yemeğini yedim.',
      },
      {
        'words': ['have', 'they', 'arrived', 'yet'],
        'correctSentence': 'have they arrived yet',
        'type': 'Soru Cümlesi',
        'meaning': 'Onlar vardı mı?',
      },
      {
        'words': ['she', 'has', 'just', 'left', 'the', 'office'],
        'correctSentence': 'she has just left the office',
        'type': 'Olumlu Cümle',
        'meaning': 'O az önce ofisten ayrıldı.',
      },
      {
        'words': ['we', 'have', 'not', 'met', 'before'],
        'correctSentence': 'we have not met before',
        'type': 'Olumsuz Cümle',
        'meaning': 'Daha önce tanışmadık.',
      },
    ],
    'Present Perfect Continuous': [
      {
        'words': ['I', 'have', 'been', 'waiting', 'for', 'two', 'hours'],
        'correctSentence': 'I have been waiting for two hours',
        'type': 'Olumlu Cümle',
        'meaning': 'İki saattir bekliyorum.',
      },
      {
        'words': ['have', 'you', 'been', 'feeling', 'okay'],
        'correctSentence': 'have you been feeling okay',
        'type': 'Soru Cümlesi',
        'meaning': 'İyi hissediyor musun?',
      },
      {
        'words': ['she', 'has', 'not', 'been', 'studying', 'enough'],
        'correctSentence': 'she has not been studying enough',
        'type': 'Olumsuz Cümle',
        'meaning': 'O yeterince ders çalışmıyor.',
      },
      {
        'words': ['they', 'have', 'been', 'working', 'since', 'morning'],
        'correctSentence': 'they have been working since morning',
        'type': 'Olumlu Cümle',
        'meaning': 'Sabahtan beri çalışıyorlar.',
      },
      {
        'words': ['how', 'long', 'have', 'you', 'been', 'learning', 'English'],
        'correctSentence': 'how long have you been learning English',
        'type': 'Soru Cümlesi',
        'meaning': 'Ne zamandır İngilizce öğreniyorsun?',
      },
      {
        'words': ['he', 'has', 'not', 'been', 'sleeping', 'well', 'lately'],
        'correctSentence': 'he has not been sleeping well lately',
        'type': 'Olumsuz Cümle',
        'meaning': 'Son zamanlarda iyi uyumuyor.',
      },
      {
        'words': [
          'we',
          'have',
          'been',
          'living',
          'here',
          'for',
          'five',
          'years'
        ],
        'correctSentence': 'we have been living here for five years',
        'type': 'Olumlu Cümle',
        'meaning': 'Beş yıldır burada yaşıyoruz.',
      },
      {
        'words': ['has', 'it', 'been', 'raining', 'all', 'day'],
        'correctSentence': 'has it been raining all day',
        'type': 'Soru Cümlesi',
        'meaning': 'Bütün gün yağmur mu yağıyor?',
      },
      {
        'words': ['she', 'has', 'been', 'cooking', 'since', 'early', 'morning'],
        'correctSentence': 'she has been cooking since early morning',
        'type': 'Olumlu Cümle',
        'meaning': 'Sabahın erken saatlerinden beri yemek pişiriyor.',
      },
      {
        'words': [
          'they',
          'have',
          'not',
          'been',
          'talking',
          'to',
          'each',
          'other'
        ],
        'correctSentence': 'they have not been talking to each other',
        'type': 'Olumsuz Cümle',
        'meaning': 'Birbiriyle konuşmuyorlar.',
      },
    ],
    'Future Tense': [
      {
        'words': ['will', 'tomorrow', 'rain', 'it'],
        'correctSentence': 'it will rain tomorrow',
        'type': 'Olumlu Cümle',
        'meaning': 'Yarın yağmur yağacak.',
      },
      {
        'words': ['going', 'are', 'to', 'university', 'you', 'attend'],
        'correctSentence': 'are you going to attend university',
        'type': 'Soru Cümlesi',
        'meaning': 'Üniversiteye gitmeyi düşünüyor musun?',
      },
      {
        'words': ['will', 'dinner', 'cook', 'she', 'tonight'],
        'correctSentence': 'she will cook dinner tonight',
        'type': 'Olumlu Cümle',
        'meaning': 'O bu akşam yemek pişirecek.',
      },
      {
        'words': ['I', 'am', 'going', 'to', 'buy', 'a', 'new', 'phone'],
        'correctSentence': 'I am going to buy a new phone',
        'type': 'Olumlu Cümle',
        'meaning': 'Yeni bir telefon satın alacağım.',
      },
      {
        'words': ['will', 'not', 'be', 'we', 'late', 'for', 'the', 'meeting'],
        'correctSentence': 'we will not be late for the meeting',
        'type': 'Olumsuz Cümle',
        'meaning': 'Toplantıya geç kalmayacağız.',
      },
      {
        'words': ['when', 'will', 'you', 'return', 'from', 'vacation'],
        'correctSentence': 'when will you return from vacation',
        'type': 'Soru Cümlesi',
        'meaning': 'Tatilden ne zaman döneceksiniz?',
      },
      {
        'words': ['they', 'are', 'going', 'to', 'move', 'next', 'year'],
        'correctSentence': 'they are going to move next year',
        'type': 'Olumlu Cümle',
        'meaning': 'Gelecek yıl taşınacaklar.',
      },
      {
        'words': ['will', 'the', 'train', 'arrive', 'on', 'time'],
        'correctSentence': 'will the train arrive on time',
        'type': 'Soru Cümlesi',
        'meaning': 'Tren zamanında gelecek mi?',
      },
      {
        'words': ['I', 'will', 'not', 'forget', 'your', 'birthday'],
        'correctSentence': 'I will not forget your birthday',
        'type': 'Olumsuz Cümle',
        'meaning': 'Doğum gününü unutmayacağım.',
      },
      {
        'words': ['she', 'is', 'going', 'to', 'start', 'a', 'new', 'job'],
        'correctSentence': 'she is going to start a new job',
        'type': 'Olumlu Cümle',
        'meaning': 'Yeni bir işe başlayacak.',
      },
    ],
    'Past Perfect': [
      {
        'words': ['I', 'had', 'already', 'left', 'when', 'you', 'called'],
        'correctSentence': 'I had already left when you called',
        'type': 'Olumlu Cümle',
        'meaning': 'Sen aradığında çoktan ayrılmıştım.',
      },
      {
        'words': ['had', 'you', 'ever', 'visited', 'Italy', 'before'],
        'correctSentence': 'had you ever visited Italy before',
        'type': 'Soru Cümlesi',
        'meaning': 'Daha önce hiç İtalya\'yı ziyaret etmiş miydin?',
      },
      {
        'words': ['she', 'had', 'not', 'finished', 'her', 'work', 'by', 'then'],
        'correctSentence': 'she had not finished her work by then',
        'type': 'Olumsuz Cümle',
        'meaning': 'O zamana kadar işini bitirmemişti.',
      },
      {
        'words': [
          'they',
          'had',
          'never',
          'seen',
          'such',
          'a',
          'beautiful',
          'sunset'
        ],
        'correctSentence': 'they had never seen such a beautiful sunset',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar daha önce böyle güzel bir gün batımı görmemişlerdi.',
      },
      {
        'words': ['had', 'he', 'finished', 'dinner', 'before', 'the', 'movie'],
        'correctSentence': 'had he finished dinner before the movie',
        'type': 'Soru Cümlesi',
        'meaning': 'Filmden önce akşam yemeğini bitirmiş miydi?',
      },
      {
        'words': [
          'we',
          'had',
          'not',
          'heard',
          'the',
          'news',
          'until',
          'yesterday'
        ],
        'correctSentence': 'we had not heard the news until yesterday',
        'type': 'Olumsuz Cümle',
        'meaning': 'Dün sabaha kadar haberi duymamıştık.',
      },
      {
        'words': [
          'she',
          'had',
          'studied',
          'English',
          'before',
          'moving',
          'abroad'
        ],
        'correctSentence': 'she had studied English before moving abroad',
        'type': 'Olumlu Cümle',
        'meaning': 'Yurtdışına taşınmadan önce İngilizce çalışmıştı.',
      },
      {
        'words': [
          'had',
          'everyone',
          'arrived',
          'before',
          'the',
          'meeting',
          'started'
        ],
        'correctSentence': 'had everyone arrived before the meeting started',
        'type': 'Soru Cümlesi',
        'meaning': 'Toplantı başlamadan önce herkes gelmis miydi?',
      },
      {
        'words': ['I', 'had', 'not', 'expected', 'such', 'a', 'surprise'],
        'correctSentence': 'I had not expected such a surprise',
        'type': 'Olumsuz Cümle',
        'meaning': 'Böyle bir sürpriz beklememiştim.',
      },
      {
        'words': [
          'they',
          'had',
          'prepared',
          'everything',
          'for',
          'the',
          'party'
        ],
        'correctSentence': 'they had prepared everything for the party',
        'type': 'Olumlu Cümle',
        'meaning': 'Parti için her şeyi hazırlamışlardı.',
      },
    ],
  };

  void _selectWord(int index, String word) {
    setState(() {
      if (!_selectedIndices.contains(index)) {
        _selectedWords.add(word);
        _selectedIndices.add(index);
      }
    });
  }

  void _removeWord(int index) {
    setState(() {
      _selectedWords.removeAt(index);
      _selectedIndices.removeAt(index);
    });
  }

  void _checkAnswer() {
    final currentExercise = _exercises[widget.topic]![_currentExerciseIndex];
    final correctSentence = currentExercise['correctSentence'];
    final userSentence = _selectedWords.join(' ');

    setState(() {
      _showResult = true;
      _isCorrect = userSentence == correctSentence;
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _exercises[widget.topic]!.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _resetExercise();
      });
    } else {
      // All exercises completed
      Navigator.pop(context);
    }
  }

  void _resetExercise() {
    setState(() {
      _selectedWords = [];
      _selectedIndices = [];
      _showResult = false;
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final currentExercise = _exercises[widget.topic]![_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topic,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Grammar explanation card (collapsible)
                      if (_showExplanation)
                        Card(
                          margin: const EdgeInsets.all(16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color:
                              isDark ? const Color(0xFF242424) : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gramer Bilgisi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: widget.color,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _showExplanation = false;
                                        });
                                      },
                                      color: isDark
                                          ? Colors.grey
                                          : Colors.grey.shade700,
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _grammarExplanations[widget.topic] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Exercise info (sentence type)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${currentExercise['type']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: widget.color,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Alıştırma ${_currentExerciseIndex + 1}/${_exercises[widget.topic]!.length}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            if (!_showExplanation)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showExplanation = true;
                                  });
                                },
                                icon: const Icon(Icons.info_outline, size: 16),
                                label: const Text('Gramer',
                                    style: TextStyle(fontSize: 13)),
                                style: TextButton.styleFrom(
                                  foregroundColor: widget.color,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Selected words area
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showResult
                                ? (_isCorrect ? Colors.green : Colors.red)
                                : isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        constraints: const BoxConstraints(minHeight: 80),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cümleniz:',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDark ? Colors.grey : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  List.generate(_selectedWords.length, (index) {
                                return InkWell(
                                  onTap: () => _removeWord(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: widget.color.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _selectedWords[index],
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.close,
                                          size: 14,
                                          color: isDark
                                              ? Colors.grey
                                              : Colors.grey.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_showResult)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _isCorrect
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: _isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isCorrect
                                              ? 'Doğru! Harika iş.'
                                              : 'Yanlış. Tekrar deneyin.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_isCorrect)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Anlam:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${currentExercise['meaning']}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (!_isCorrect)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Doğru cümle:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${currentExercise['correctSentence']}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Anlam:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${currentExercise['meaning']}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.black87,
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
                      ),

                      // Words to select
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: !_showResult
                            ? Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: isDark
                                    ? const Color(0xFF242424)
                                    : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Kelimeleri seçerek cümle oluşturun:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color:
                                                  widget.color.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: widget.color
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '${currentExercise['type']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: widget.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: List.generate(
                                          currentExercise['words'].length,
                                          (index) {
                                            final word =
                                                currentExercise['words'][index];
                                            final isSelected = _selectedIndices
                                                .contains(index);

                                            return InkWell(
                                              onTap: isSelected
                                                  ? null
                                                  : () =>
                                                      _selectWord(index, word),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.grey
                                                          .withOpacity(0.5)
                                                      : widget.color
                                                          .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.grey
                                                            .withOpacity(0.7)
                                                        : widget.color
                                                            .withOpacity(0.5),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  word,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: isSelected
                                                        ? FontWeight.normal
                                                        : FontWeight.bold,
                                                    color: isSelected
                                                        ? (isDark
                                                            ? Colors.grey[350]
                                                            : Colors.grey[700])
                                                        : isDark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Add bottom padding for scrolling
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // Bottom buttons - keep outside scrollview
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _showResult
                            ? ElevatedButton.icon(
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text(
                                  'Devam Et',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: _nextExercise,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _selectedWords.isEmpty
                                    ? null
                                    : _checkAnswer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.color,
                                  disabledBackgroundColor:
                                      widget.color.withOpacity(0.3),
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Kontrol Et',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
