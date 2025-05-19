import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../auth/providers/auth_provider.dart';
import 'dart:math' as math;

class SentenceExerciseScreen extends ConsumerStatefulWidget {
  final String topic;
  final Color color;
  final String topicId;
  final String subtopicId;

  const SentenceExerciseScreen({
    Key? key,
    required this.topic,
    required this.color,
    required this.topicId,
    required this.subtopicId,
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
  List<Map<String, dynamic>> _filteredExercises = [];
  bool _isLoading = true;
  bool _allExercisesCompleted = false;

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
        'id': 'ps_1',
        'words': ['she', 'coffee', 'drinks', 'every', 'morning'],
        'correctSentence': 'she drinks coffee every morning',
        'type': 'Olumlu Cümle',
        'meaning': 'O her sabah kahve içer.',
      },
      {
        'id': 'ps_2',
        'words': ['do', 'like', 'you', 'pizza'],
        'correctSentence': 'do you like pizza',
        'type': 'Soru Cümlesi',
        'meaning': 'Pizza sever misin?',
      },
      {
        'id': 'ps_3',
        'words': ['they', 'to', 'school', 'walk', 'usually'],
        'correctSentence': 'they usually walk to school',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar genellikle okula yürüyerek giderler.',
      },
      {
        'id': 'ps_4',
        'words': ['he', 'does', 'not', 'meat', 'eat'],
        'correctSentence': 'he does not eat meat',
        'type': 'Olumsuz Cümle',
        'meaning': 'O et yemez.',
      },
      {
        'id': 'ps_5',
        'words': ['English', 'speak', 'fluently', 'I'],
        'correctSentence': 'I speak English fluently',
        'type': 'Olumlu Cümle',
        'meaning': 'İngilizceyi akıcı konuşurum.',
      },
      {
        'id': 'ps_6',
        'words': ['your', 'where', 'does', 'live', 'brother'],
        'correctSentence': 'where does your brother live',
        'type': 'Soru Cümlesi',
        'meaning': 'Kardeşin nerede yaşıyor?',
      },
      {
        'id': 'ps_7',
        'words': ['always', 'on', 'breakfast', 'time', 'we', 'have'],
        'correctSentence': 'we always have breakfast on time',
        'type': 'Olumlu Cümle',
        'meaning': 'Her zaman kahvaltımızı zamanında yaparız.',
      },
      {
        'id': 'ps_8',
        'words': ['they', 'do', 'not', 'understand', 'the', 'problem'],
        'correctSentence': 'they do not understand the problem',
        'type': 'Olumsuz Cümle',
        'meaning': 'Onlar problemi anlamazlar.',
      },
      {
        'id': 'ps_9',
        'words': ['does', 'he', 'play', 'football', 'every', 'weekend'],
        'correctSentence': 'does he play football every weekend',
        'type': 'Soru Cümlesi',
        'meaning': 'O her hafta sonu futbol oynar mı?',
      },
      {
        'id': 'ps_10',
        'words': ['my', 'parents', 'travel', 'abroad', 'every', 'summer'],
        'correctSentence': 'my parents travel abroad every summer',
        'type': 'Olumlu Cümle',
        'meaning': 'Ailem her yaz yurtdışına seyahat eder.',
      },
      {
        'id': 'ps_11',
        'words': ['I', 'usually', 'read', 'books', 'before', 'sleeping'],
        'correctSentence': 'I usually read books before sleeping',
        'type': 'Olumlu Cümle',
        'meaning': 'Genellikle uyumadan önce kitap okurum.',
      },
      {
        'id': 'ps_12',
        'words': ['do', 'you', 'know', 'his', 'phone', 'number'],
        'correctSentence': 'do you know his phone number',
        'type': 'Soru Cümlesi',
        'meaning': 'Onun telefon numarasını biliyor musun?',
      },
      {
        'id': 'ps_13',
        'words': ['she', 'does', 'not', 'drive', 'to', 'work'],
        'correctSentence': 'she does not drive to work',
        'type': 'Olumsuz Cümle',
        'meaning': 'O işe araba kullanarak gitmez.',
      },
      {
        'id': 'ps_14',
        'words': ['children', 'the', 'play', 'in', 'park', 'every', 'day'],
        'correctSentence': 'the children play in park every day',
        'type': 'Olumlu Cümle',
        'meaning': 'Çocuklar her gün parkta oynarlar.',
      },
      {
        'id': 'ps_15',
        'words': ['what', 'time', 'does', 'the', 'bank', 'open'],
        'correctSentence': 'what time does the bank open',
        'type': 'Soru Cümlesi',
        'meaning': 'Banka saat kaçta açılır?',
      },
      {
        'id': 'ps_16',
        'words': ['we', 'do', 'not', 'work', 'on', 'Sundays'],
        'correctSentence': 'we do not work on Sundays',
        'type': 'Olumsuz Cümle',
        'meaning': 'Pazar günleri çalışmayız.',
      },
      {
        'id': 'ps_17',
        'words': ['she', 'always', 'helps', 'her', 'friends'],
        'correctSentence': 'she always helps her friends',
        'type': 'Olumlu Cümle',
        'meaning': 'O her zaman arkadaşlarına yardım eder.',
      },
      {
        'id': 'ps_18',
        'words': ['does', 'it', 'often', 'rain', 'in', 'your', 'city'],
        'correctSentence': 'does it often rain in your city',
        'type': 'Soru Cümlesi',
        'meaning': 'Şehrinde sık sık yağmur yağar mı?',
      },
      {
        'id': 'ps_19',
        'words': ['I', 'do', 'not', 'agree', 'with', 'your', 'opinion'],
        'correctSentence': 'I do not agree with your opinion',
        'type': 'Olumsuz Cümle',
        'meaning': 'Fikrine katılmıyorum.',
      },
      {
        'id': 'ps_20',
        'words': ['most', 'people', 'want', 'to', 'be', 'happy'],
        'correctSentence': 'most people want to be happy',
        'type': 'Olumlu Cümle',
        'meaning': 'Çoğu insan mutlu olmak ister.',
      },
    ],
    'Present Continuous': [
      {
        'id': 'pc_1',
        'words': ['is', 'now', 'raining', 'it'],
        'correctSentence': 'it is raining now',
        'type': 'Olumlu Cümle',
        'meaning': 'Şu anda yağmur yağıyor.',
      },
      {
        'id': 'pc_2',
        'words': ['are', 'what', 'doing', 'you'],
        'correctSentence': 'what are you doing',
        'type': 'Soru Cümlesi',
        'meaning': 'Ne yapıyorsun?',
      },
      {
        'id': 'pc_3',
        'words': ['she', 'is', 'for', 'studying', 'exam', 'the'],
        'correctSentence': 'she is studying for the exam',
        'type': 'Olumlu Cümle',
        'meaning': 'O, sınav için çalışıyor.',
      },
      {
        'id': 'pc_4',
        'words': ['we', 'are', 'not', 'today', 'working'],
        'correctSentence': 'we are not working today',
        'type': 'Olumsuz Cümle',
        'meaning': 'Bugün çalışmıyoruz.',
      },
      {
        'id': 'pc_5',
        'words': ['they', 'are', 'dinner', 'having', 'now'],
        'correctSentence': 'they are having dinner now',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar şu anda akşam yemeği yiyorlar.',
      },
      {
        'id': 'pc_6',
        'words': ['is', 'the', 'baby', 'crying', 'why'],
        'correctSentence': 'why is the baby crying',
        'type': 'Soru Cümlesi',
        'meaning': 'Bebek neden ağlıyor?',
      },
      {
        'id': 'pc_7',
        'words': ['are', 'you', 'listening', 'to', 'me'],
        'correctSentence': 'are you listening to me',
        'type': 'Soru Cümlesi',
        'meaning': 'Beni dinliyor musun?',
      },
      {
        'id': 'pc_8',
        'words': ['is', 'not', 'she', 'feeling', 'well', 'today'],
        'correctSentence': 'she is not feeling well today',
        'type': 'Olumsuz Cümle',
        'meaning': 'O bugün kendini iyi hissetmiyor.',
      },
      {
        'id': 'pc_9',
        'words': ['I', 'am', 'currently', 'reading', 'a', 'good', 'book'],
        'correctSentence': 'I am currently reading a good book',
        'type': 'Olumlu Cümle',
        'meaning': 'Şu anda iyi bir kitap okuyorum.',
      },
      {
        'id': 'pc_10',
        'words': ['they', 'are', 'planning', 'a', 'vacation', 'next', 'month'],
        'correctSentence': 'they are planning a vacation next month',
        'type': 'Olumlu Cümle',
        'meaning': 'Gelecek ay bir tatil planlıyorlar.',
      },
      {
        'id': 'pc_11',
        'words': ['he', 'is', 'cooking', 'dinner', 'in', 'the', 'kitchen'],
        'correctSentence': 'he is cooking dinner in the kitchen',
        'type': 'Olumlu Cümle',
        'meaning': 'O mutfakta akşam yemeği pişiriyor.',
      },
      {
        'id': 'pc_12',
        'words': ['are', 'you', 'waiting', 'for', 'someone'],
        'correctSentence': 'are you waiting for someone',
        'type': 'Soru Cümlesi',
        'meaning': 'Birini mi bekliyorsun?',
      },
      {
        'id': 'pc_13',
        'words': ['the', 'children', 'are', 'not', 'sleeping', 'yet'],
        'correctSentence': 'the children are not sleeping yet',
        'type': 'Olumsuz Cümle',
        'meaning': 'Çocuklar henüz uyumuyor.',
      },
      {
        'id': 'pc_14',
        'words': ['we', 'are', 'learning', 'English', 'at', 'the', 'moment'],
        'correctSentence': 'we are learning English at the moment',
        'type': 'Olumlu Cümle',
        'meaning': 'Şu anda İngilizce öğreniyoruz.',
      },
      {
        'id': 'pc_15',
        'words': ['why', 'are', 'you', 'looking', 'at', 'me', 'like', 'that'],
        'correctSentence': 'why are you looking at me like that',
        'type': 'Soru Cümlesi',
        'meaning': 'Neden bana öyle bakıyorsun?',
      },
      {
        'id': 'pc_16',
        'words': ['she', 'is', 'not', 'wearing', 'her', 'glasses', 'today'],
        'correctSentence': 'she is not wearing her glasses today',
        'type': 'Olumsuz Cümle',
        'meaning': 'O bugün gözlüklerini takmıyor.',
      },
      {
        'id': 'pc_17',
        'words': ['I', 'am', 'working', 'on', 'a', 'new', 'project'],
        'correctSentence': 'I am working on a new project',
        'type': 'Olumlu Cümle',
        'meaning': 'Yeni bir proje üzerinde çalışıyorum.',
      },
      {
        'id': 'pc_18',
        'words': ['are', 'they', 'building', 'a', 'new', 'house'],
        'correctSentence': 'are they building a new house',
        'type': 'Soru Cümlesi',
        'meaning': 'Yeni bir ev mi inşa ediyorlar?',
      },
      {
        'id': 'pc_19',
        'words': ['the', 'sun', 'is', 'shining', 'brightly', 'today'],
        'correctSentence': 'the sun is shining brightly today',
        'type': 'Olumlu Cümle',
        'meaning': 'Güneş bugün parlak bir şekilde parlıyor.',
      },
      {
        'id': 'pc_20',
        'words': ['he', 'is', 'not', 'telling', 'the', 'truth'],
        'correctSentence': 'he is not telling the truth',
        'type': 'Olumsuz Cümle',
        'meaning': 'O doğruyu söylemiyor.',
      },
    ],
    'Past Simple': [
      {
        'id': 'pas_1',
        'words': ['visited', 'museum', 'they', 'the', 'yesterday'],
        'correctSentence': 'they visited the museum yesterday',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar dün müzeyi ziyaret ettiler.',
      },
      {
        'id': 'pas_2',
        'words': ['did', 'last', 'weekend', 'what', 'you', 'do'],
        'correctSentence': 'what did you do last weekend',
        'type': 'Soru Cümlesi',
        'meaning': 'Geçen hafta sonu ne yaptın?',
      },
      {
        'id': 'pas_3',
        'words': ['not', 'did', 'the', 'I', 'finish', 'book'],
        'correctSentence': 'I did not finish the book',
        'type': 'Olumsuz Cümle',
        'meaning': 'Kitabı bitirmedim.',
      },
      {
        'id': 'pas_4',
        'words': ['she', 'bought', 'a', 'new', 'car', 'last', 'month'],
        'correctSentence': 'she bought a new car last month',
        'type': 'Olumlu Cümle',
        'meaning': 'O geçen ay yeni bir araba satın aldı.',
      },
      {
        'id': 'pas_5',
        'words': ['did', 'where', 'you', 'go', 'to', 'school'],
        'correctSentence': 'where did you go to school',
        'type': 'Soru Cümlesi',
        'meaning': 'Nerede okula gittin?',
      },
      {
        'id': 'pas_6',
        'words': ['they', 'did', 'not', 'call', 'me', 'yesterday'],
        'correctSentence': 'they did not call me yesterday',
        'type': 'Olumsuz Cümle',
        'meaning': 'Dün beni aramadılar.',
      },
      {
        'id': 'pas_7',
        'words': ['we', 'watched', 'a', 'movie', 'last', 'night'],
        'correctSentence': 'we watched a movie last night',
        'type': 'Olumlu Cümle',
        'meaning': 'Dün gece bir film izledik.',
      },
      {
        'id': 'pas_8',
        'words': ['did', 'he', 'enjoy', 'the', 'party'],
        'correctSentence': 'did he enjoy the party',
        'type': 'Soru Cümlesi',
        'meaning': 'Partiden keyif aldı mı?',
      },
      {
        'id': 'pas_9',
        'words': ['I', 'did', 'not', 'hear', 'the', 'doorbell'],
        'correctSentence': 'I did not hear the doorbell',
        'type': 'Olumsuz Cümle',
        'meaning': 'Kapı zilini duymadım.',
      },
      {
        'id': 'pas_10',
        'words': ['she', 'wrote', 'a', 'letter', 'to', 'her', 'friend'],
        'correctSentence': 'she wrote a letter to her friend',
        'type': 'Olumlu Cümle',
        'meaning': 'Arkadaşına bir mektup yazdı.',
      },
      {
        'id': 'pas_11',
        'words': ['I', 'walked', 'to', 'work', 'yesterday', 'morning'],
        'correctSentence': 'I walked to work yesterday morning',
        'type': 'Olumlu Cümle',
        'meaning': 'Dün sabah işe yürüyerek gittim.',
      },
      {
        'id': 'pas_12',
        'words': ['did', 'when', 'you', 'arrive', 'home', 'last', 'night'],
        'correctSentence': 'when did you arrive home last night',
        'type': 'Soru Cümlesi',
        'meaning': 'Dün gece eve ne zaman vardın?',
      },
      {
        'id': 'pas_13',
        'words': ['he', 'did', 'not', 'study', 'for', 'the', 'exam'],
        'correctSentence': 'he did not study for the exam',
        'type': 'Olumsuz Cümle',
        'meaning': 'Sınav için çalışmadı.',
      },
      {
        'id': 'pas_14',
        'words': ['we', 'went', 'to', 'the', 'beach', 'last', 'summer'],
        'correctSentence': 'we went to the beach last summer',
        'type': 'Olumlu Cümle',
        'meaning': 'Geçen yaz plaja gittik.',
      },
      {
        'id': 'pas_15',
        'words': [
          'did',
          'they',
          'visit',
          'their',
          'grandparents',
          'last',
          'week'
        ],
        'correctSentence': 'did they visit their grandparents last week',
        'type': 'Soru Cümlesi',
        'meaning':
            'Geçen hafta büyükanne ve büyükbabalarını ziyaret ettiler mi?',
      },
      {
        'id': 'pas_16',
        'words': ['she', 'did', 'not', 'like', 'the', 'movie', 'we', 'saw'],
        'correctSentence': 'she did not like the movie we saw',
        'type': 'Olumsuz Cümle',
        'meaning': 'İzlediğimiz filmi beğenmedi.',
      },
      {
        'id': 'pas_17',
        'words': ['I', 'lost', 'my', 'keys', 'this', 'morning'],
        'correctSentence': 'I lost my keys this morning',
        'type': 'Olumlu Cümle',
        'meaning': 'Bu sabah anahtarlarımı kaybettim.',
      },
      {
        'id': 'pas_18',
        'words': ['did', 'why', 'you', 'leave', 'the', 'party', 'early'],
        'correctSentence': 'why did you leave the party early',
        'type': 'Soru Cümlesi',
        'meaning': 'Neden partiden erken ayrıldın?',
      },
      {
        'id': 'pas_19',
        'words': [
          'the',
          'teacher',
          'explained',
          'the',
          'lesson',
          'very',
          'well'
        ],
        'correctSentence': 'the teacher explained the lesson very well',
        'type': 'Olumlu Cümle',
        'meaning': 'Öğretmen dersi çok iyi anlattı.',
      },
      {
        'id': 'pas_20',
        'words': ['she', 'did', 'not', 'answer', 'my', 'question'],
        'correctSentence': 'she did not answer my question',
        'type': 'Olumsuz Cümle',
        'meaning': 'Sorumu yanıtlamadı.',
      },
    ],
    'Past Continuous': [
      {
        'id': 'pac_1',
        'words': ['was', 'watching', 'TV', 'I', 'when', 'you', 'called'],
        'correctSentence': 'I was watching TV when you called',
        'type': 'Olumlu Cümle',
        'meaning': 'Sen aradığında TV izliyordum.',
      },
      {
        'id': 'pac_2',
        'words': ['were', 'doing', 'what', 'you', 'at', '8', 'yesterday'],
        'correctSentence': 'what were you doing at 8 yesterday',
        'type': 'Soru Cümlesi',
        'meaning': 'Dün saat 8\'de ne yapıyordun?',
      },
      {
        'id': 'pac_3',
        'words': ['she', 'was', 'not', 'listening', 'to', 'the', 'teacher'],
        'correctSentence': 'she was not listening to the teacher',
        'type': 'Olumsuz Cümle',
        'meaning': 'O öğretmeni dinlemiyordu.',
      },
      {
        'id': 'pac_4',
        'words': ['they', 'were', 'playing', 'football', 'all', 'afternoon'],
        'correctSentence': 'they were playing football all afternoon',
        'type': 'Olumlu Cümle',
        'meaning': 'Onlar bütün öğleden sonra futbol oynuyorlardı.',
      },
      {
        'id': 'pac_5',
        'words': ['was', 'it', 'raining', 'when', 'you', 'left'],
        'correctSentence': 'was it raining when you left',
        'type': 'Soru Cümlesi',
        'meaning': 'Sen ayrıldığında yağmur yağıyor muydu?',
      },
      {
        'id': 'pac_6',
        'words': ['we', 'were', 'not', 'expecting', 'any', 'visitors'],
        'correctSentence': 'we were not expecting any visitors',
        'type': 'Olumsuz Cümle',
        'meaning': 'Hiç ziyaretçi beklemiyorduk.',
      },
      {
        'id': 'pac_7',
        'words': ['he', 'was', 'studying', 'while', 'I', 'was', 'cooking'],
        'correctSentence': 'he was studying while I was cooking',
        'type': 'Olumlu Cümle',
        'meaning': 'Ben yemek pişirirken o ders çalışıyordu.',
      },
      {
        'id': 'pac_8',
        'words': ['were', 'they', 'waiting', 'for', 'the', 'bus'],
        'correctSentence': 'were they waiting for the bus',
        'type': 'Soru Cümlesi',
        'meaning': 'Onlar otobüs için bekliyor muydu?',
      },
      {
        'id': 'pac_9',
        'words': ['she', 'was', 'not', 'feeling', 'well', 'yesterday'],
        'correctSentence': 'she was not feeling well yesterday',
        'type': 'Olumsuz Cümle',
        'meaning': 'O dün kendini iyi hissetmiyordu.',
      },
      {
        'id': 'pac_10',
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
        'id': 'pp_1',
        'words': ['I', 'have', 'never', 'been', 'to', 'Paris'],
        'correctSentence': 'I have never been to Paris',
        'type': 'Olumlu Cümle',
        'meaning': 'Hiç Paris\'e gitmedim.',
      },
      {
        'id': 'pp_2',
        'words': ['have', 'you', 'finished', 'your', 'homework', 'yet'],
        'correctSentence': 'have you finished your homework yet',
        'type': 'Soru Cümlesi',
        'meaning': 'Ödevinizi bitirdiniz mi?',
      },
      {
        'id': 'pp_3',
        'words': ['she', 'has', 'not', 'seen', 'the', 'movie'],
        'correctSentence': 'she has not seen the movie',
        'type': 'Olumsuz Cümle',
        'meaning': 'O filmi görmedi.',
      },
      {
        'id': 'pp_4',
        'words': ['they', 'have', 'lived', 'here', 'for', 'ten', 'years'],
        'correctSentence': 'they have lived here for ten years',
        'type': 'Olumlu Cümle',
        'meaning': 'On yıldır burada yaşıyorlar.',
      },
      {
        'id': 'pp_5',
        'words': ['has', 'he', 'ever', 'visited', 'London'],
        'correctSentence': 'has he ever visited London',
        'type': 'Soru Cümlesi',
        'meaning': 'Hiç Londra\'yı ziyaret etti mi?',
      },
      {
        'id': 'pp_6',
        'words': ['we', 'have', 'not', 'received', 'any', 'news'],
        'correctSentence': 'we have not received any news',
        'type': 'Olumsuz Cümle',
        'meaning': 'Hiç haber almadık.',
      },
      {
        'id': 'pp_7',
        'words': ['I', 'have', 'already', 'eaten', 'lunch'],
        'correctSentence': 'I have already eaten lunch',
        'type': 'Olumlu Cümle',
        'meaning': 'Çoktan öğle yemeğini yedim.',
      },
      {
        'id': 'pp_8',
        'words': ['have', 'they', 'arrived', 'yet'],
        'correctSentence': 'have they arrived yet',
        'type': 'Soru Cümlesi',
        'meaning': 'Onlar vardı mı?',
      },
      {
        'id': 'pp_9',
        'words': ['she', 'has', 'just', 'left', 'the', 'office'],
        'correctSentence': 'she has just left the office',
        'type': 'Olumlu Cümle',
        'meaning': 'O az önce ofisten ayrıldı.',
      },
      {
        'id': 'pp_10',
        'words': ['we', 'have', 'not', 'met', 'before'],
        'correctSentence': 'we have not met before',
        'type': 'Olumsuz Cümle',
        'meaning': 'Daha önce tanışmadık.',
      },
      {
        'id': 'pp_11',
        'words': ['has', 'your', 'brother', 'graduated', 'from', 'university'],
        'correctSentence': 'has your brother graduated from university',
        'type': 'Soru Cümlesi',
        'meaning': 'Kardeşin üniversiteden mezun oldu mu?',
      },
      {
        'id': 'pp_12',
        'words': ['they', 'have', 'improved', 'their', 'English', 'a', 'lot'],
        'correctSentence': 'they have improved their English a lot',
        'type': 'Olumlu Cümle',
        'meaning': 'İngilizcelerini çok geliştirdiler.',
      },
      {
        'id': 'pp_13',
        'words': ['I', 'have', 'not', 'spoken', 'to', 'her', 'since', 'Monday'],
        'correctSentence': 'I have not spoken to her since Monday',
        'type': 'Olumsuz Cümle',
        'meaning': 'Pazartesiden beri onunla konuşmadım.',
      },
      {
        'id': 'pp_14',
        'words': ['have', 'you', 'ever', 'tried', 'Turkish', 'coffee'],
        'correctSentence': 'have you ever tried Turkish coffee',
        'type': 'Soru Cümlesi',
        'meaning': 'Hiç Türk kahvesi denedin mi?',
      },
      {
        'id': 'pp_15',
        'words': ['she', 'has', 'written', 'three', 'books', 'so', 'far'],
        'correctSentence': 'she has written three books so far',
        'type': 'Olumlu Cümle',
        'meaning': 'Şimdiye kadar üç kitap yazdı.',
      },
      {
        'id': 'pp_16',
        'words': [
          'our',
          'team',
          'has',
          'won',
          'five',
          'games',
          'this',
          'season'
        ],
        'correctSentence': 'our team has won five games this season',
        'type': 'Olumlu Cümle',
        'meaning': 'Takımımız bu sezon beş maç kazandı.',
      },
      {
        'id': 'pp_17',
        'words': ['has', 'anyone', 'seen', 'my', 'keys'],
        'correctSentence': 'has anyone seen my keys',
        'type': 'Soru Cümlesi',
        'meaning': 'Anahtarlarımı gören oldu mu?',
      },
      {
        'id': 'pp_18',
        'words': ['they', 'have', 'not', 'decided', 'yet', 'what', 'to', 'do'],
        'correctSentence': 'they have not decided yet what to do',
        'type': 'Olumsuz Cümle',
        'meaning': 'Henüz ne yapacaklarına karar vermediler.',
      },
      {
        'id': 'pp_19',
        'words': ['he', 'has', 'forgotten', 'his', 'password', 'again'],
        'correctSentence': 'he has forgotten his password again',
        'type': 'Olumlu Cümle',
        'meaning': 'Şifresini yine unuttu.',
      },
      {
        'id': 'pp_20',
        'words': ['have', 'you', 'seen', 'the', 'new', 'shopping', 'mall'],
        'correctSentence': 'have you seen the new shopping mall',
        'type': 'Soru Cümlesi',
        'meaning': 'Yeni alışveriş merkezini gördün mü?',
      },
    ],
    'Present Perfect Continuous': [
      {
        'id': 'ppc_1',
        'words': ['I', 'have', 'been', 'waiting', 'for', 'two', 'hours'],
        'correctSentence': 'I have been waiting for two hours',
        'type': 'Olumlu Cümle',
        'meaning': 'İki saattir bekliyorum.',
      },
      {
        'id': 'ppc_2',
        'words': ['have', 'you', 'been', 'feeling', 'okay'],
        'correctSentence': 'have you been feeling okay',
        'type': 'Soru Cümlesi',
        'meaning': 'İyi hissediyor musun?',
      },
      {
        'id': 'ppc_3',
        'words': ['she', 'has', 'not', 'been', 'studying', 'enough'],
        'correctSentence': 'she has not been studying enough',
        'type': 'Olumsuz Cümle',
        'meaning': 'O yeterince ders çalışmıyor.',
      },
      {
        'id': 'ppc_4',
        'words': ['they', 'have', 'been', 'working', 'since', 'morning'],
        'correctSentence': 'they have been working since morning',
        'type': 'Olumlu Cümle',
        'meaning': 'Sabahtan beri çalışıyorlar.',
      },
      {
        'id': 'ppc_5',
        'words': ['how', 'long', 'have', 'you', 'been', 'learning', 'English'],
        'correctSentence': 'how long have you been learning English',
        'type': 'Soru Cümlesi',
        'meaning': 'Ne zamandır İngilizce öğreniyorsun?',
      },
      {
        'id': 'ppc_6',
        'words': ['he', 'has', 'not', 'been', 'sleeping', 'well', 'lately'],
        'correctSentence': 'he has not been sleeping well lately',
        'type': 'Olumsuz Cümle',
        'meaning': 'Son zamanlarda iyi uyumuyor.',
      },
      {
        'id': 'ppc_7',
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
        'id': 'ppc_8',
        'words': ['has', 'it', 'been', 'raining', 'all', 'day'],
        'correctSentence': 'has it been raining all day',
        'type': 'Soru Cümlesi',
        'meaning': 'Bütün gün yağmur mu yağıyor?',
      },
      {
        'id': 'ppc_9',
        'words': ['she', 'has', 'been', 'cooking', 'since', 'early', 'morning'],
        'correctSentence': 'she has been cooking since early morning',
        'type': 'Olumlu Cümle',
        'meaning': 'Sabahın erken saatlerinden beri yemek pişiriyor.',
      },
      {
        'id': 'ppc_10',
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
        'id': 'ft_1',
        'words': ['will', 'tomorrow', 'rain', 'it'],
        'correctSentence': 'it will rain tomorrow',
        'type': 'Olumlu Cümle',
        'meaning': 'Yarın yağmur yağacak.',
      },
      {
        'id': 'ft_2',
        'words': ['going', 'are', 'to', 'university', 'you', 'attend'],
        'correctSentence': 'are you going to attend university',
        'type': 'Soru Cümlesi',
        'meaning': 'Üniversiteye gitmeyi düşünüyor musun?',
      },
      {
        'id': 'ft_3',
        'words': ['will', 'dinner', 'cook', 'she', 'tonight'],
        'correctSentence': 'she will cook dinner tonight',
        'type': 'Olumlu Cümle',
        'meaning': 'O bu akşam yemek pişirecek.',
      },
      {
        'id': 'ft_4',
        'words': ['I', 'am', 'going', 'to', 'buy', 'a', 'new', 'phone'],
        'correctSentence': 'I am going to buy a new phone',
        'type': 'Olumlu Cümle',
        'meaning': 'Yeni bir telefon satın alacağım.',
      },
      {
        'id': 'ft_5',
        'words': ['will', 'not', 'be', 'we', 'late', 'for', 'the', 'meeting'],
        'correctSentence': 'we will not be late for the meeting',
        'type': 'Olumsuz Cümle',
        'meaning': 'Toplantıya geç kalmayacağız.',
      },
      {
        'id': 'ft_6',
        'words': ['when', 'will', 'you', 'return', 'from', 'vacation'],
        'correctSentence': 'when will you return from vacation',
        'type': 'Soru Cümlesi',
        'meaning': 'Tatilden ne zaman döneceksiniz?',
      },
      {
        'id': 'ft_7',
        'words': ['they', 'are', 'going', 'to', 'move', 'next', 'year'],
        'correctSentence': 'they are going to move next year',
        'type': 'Olumlu Cümle',
        'meaning': 'Gelecek yıl taşınacaklar.',
      },
      {
        'id': 'ft_8',
        'words': ['will', 'the', 'train', 'arrive', 'on', 'time'],
        'correctSentence': 'will the train arrive on time',
        'type': 'Soru Cümlesi',
        'meaning': 'Tren zamanında gelecek mi?',
      },
      {
        'id': 'ft_9',
        'words': ['I', 'will', 'not', 'forget', 'your', 'birthday'],
        'correctSentence': 'I will not forget your birthday',
        'type': 'Olumsuz Cümle',
        'meaning': 'Doğum gününü unutmayacağım.',
      },
      {
        'id': 'ft_10',
        'words': ['she', 'is', 'going', 'to', 'start', 'a', 'new', 'job'],
        'correctSentence': 'she is going to start a new job',
        'type': 'Olumlu Cümle',
        'meaning': 'Yeni bir işe başlayacak.',
      },
    ],
    'Past Perfect': [
      {
        'id': 'pap_1',
        'words': ['I', 'had', 'already', 'left', 'when', 'you', 'called'],
        'correctSentence': 'I had already left when you called',
        'type': 'Olumlu Cümle',
        'meaning': 'Sen aradığında çoktan ayrılmıştım.',
      },
      {
        'id': 'pap_2',
        'words': ['had', 'you', 'ever', 'visited', 'Italy', 'before'],
        'correctSentence': 'had you ever visited Italy before',
        'type': 'Soru Cümlesi',
        'meaning': 'Daha önce hiç İtalya\'yı ziyaret etmiş miydin?',
      },
      {
        'id': 'pap_3',
        'words': ['she', 'had', 'not', 'finished', 'her', 'work', 'by', 'then'],
        'correctSentence': 'she had not finished her work by then',
        'type': 'Olumsuz Cümle',
        'meaning': 'O zamana kadar işini bitirmemişti.',
      },
      {
        'id': 'pap_4',
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
        'id': 'pap_5',
        'words': ['had', 'he', 'finished', 'dinner', 'before', 'the', 'movie'],
        'correctSentence': 'had he finished dinner before the movie',
        'type': 'Soru Cümlesi',
        'meaning': 'Filmden önce akşam yemeğini bitirmiş miydi?',
      },
      {
        'id': 'pap_6',
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
        'id': 'pap_7',
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
        'id': 'pap_8',
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
        'id': 'pap_9',
        'words': ['I', 'had', 'not', 'expected', 'such', 'a', 'surprise'],
        'correctSentence': 'I had not expected such a surprise',
        'type': 'Olumsuz Cümle',
        'meaning': 'Böyle bir sürpriz beklememiştim.',
      },
      {
        'id': 'pap_10',
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

  @override
  void initState() {
    super.initState();

    // Widget ağacı oluşturulduktan sonra alıştırmaları yükle
    Future.microtask(() {
      if (mounted) {
        _loadAndFilterExercises();
      }
    });
    final adService = ref.read(adServiceProvider);
    if (!ref.read(isInterstitialLimitReachedProvider)) {
      adService.loadInterstitialAd().then((_) {
        if (mounted) {
          adService.showInterstitialAd();
        }
      });
    }
  }

  // Alıştırmaları yükle ve kullanıcının doğru yaptıklarını filtrele
  Future<void> _loadAndFilterExercises() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    // Kullanıcının oturum durumunu kontrol et
    final authState = ref.read(authProvider);

    // Kullanıcının giriş yapmadığı durumda tüm alıştırmaları göster
    if (!authState.isLoggedIn) {
      if (!mounted) return;

      setState(() {
        _filteredExercises = List.from(_exercises[widget.topic] ?? []);
        _isLoading = false;
      });

      // Oturum açılmaması durumunda uyarı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'İlerleme kaydetmek için lütfen giriş yapın',
              style: TextStyle(color: Colors.white),
            ),
            action: SnackBarAction(
              label: 'Giriş Yap',
              onPressed: () {
                // Login sayfasına yönlendir
                Navigator.pushNamed(context, '/login');
              },
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    try {
      // Exercise-answer provider'dan notifier'a erişim
      final exerciseAnswerNotifier = ref.read(exerciseAnswerProvider.notifier);

      // Kullanıcının doğru yaptığı alıştırmaları getir
      await exerciseAnswerNotifier
          .loadUserCorrectExerciseIds(authState.userId!);

      if (!mounted) return;

      // Provider'dan doğru yapılmış alıştırma ID'lerini al
      final exerciseAnswerState = ref.read(exerciseAnswerProvider);
      final correctExerciseIds = exerciseAnswerState.correctExerciseIds;

      // Tüm alıştırmaları al
      final allExercises = _exercises[widget.topic] ?? [];

      // Doğru yapılmamış alıştırmaları filtrele
      final uncompleteExercises = allExercises.where((exercise) {
        return !correctExerciseIds.contains(exercise['id']);
      }).toList();

      if (!mounted) return;

      // Tüm alıştırmalar tamamlandıysa
      if (uncompleteExercises.isEmpty && allExercises.isNotEmpty) {
        setState(() {
          _allExercisesCompleted = true;
          _isLoading = false;
          _filteredExercises = [];
        });
        return;
      }

      // Rastgele karıştır - isteğe bağlı
      uncompleteExercises.shuffle();

      setState(() {
        _filteredExercises = uncompleteExercises;
        _isLoading = false;
      });
    } catch (e) {
      // Hata durumunda tüm alıştırmaları göster
      if (!mounted) return;

      setState(() {
        _filteredExercises = List.from(_exercises[widget.topic] ?? []);
        _isLoading = false;
      });

      // Hata mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Alıştırmalar yüklenirken bir hata oluştu: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

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
    if (_filteredExercises.isEmpty ||
        _currentExerciseIndex >= _filteredExercises.length) {
      return;
    }

    final currentExercise = _filteredExercises[_currentExerciseIndex];
    final correctSentence = currentExercise['correctSentence'] as String;
    final userSentence = _selectedWords.join(' ');

    final isCorrect = userSentence.trim().toLowerCase() ==
        correctSentence.trim().toLowerCase();

    // Save the answer if user is logged in
    final authState = ref.read(authProvider);
    if (authState.isLoggedIn) {
      // Firebase'e cevabı kaydet - Future kullanarak widget ağacı oluşturulduktan sonra işlem yap
      Future.microtask(() {
        ref.read(exerciseAnswerProvider.notifier).saveExerciseAnswer(
              userId: authState.userId!,
              topicId: widget.topicId,
              subtopicId: widget.subtopicId,
              exerciseId: currentExercise['id'] as String,
              isCorrect: isCorrect,
            );
      });

      // Eğer cevap doğruysa ve bu son alıştırma ise
      if (isCorrect && _filteredExercises.length == 1) {
        // Yüklenen alıştırma sayısını güncelle ve ekranı göster
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _allExercisesCompleted = true;
            });
          }
        });
      }
    } else {
      // Kullanıcı oturum açmamışsa ancak doğru cevap verdiyse bilgilendir
      if (isCorrect) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'İlerlemenizi kaydetmek için giriş yapabilirsiniz',
                  style: TextStyle(color: Colors.white),
                ),
                action: SnackBarAction(
                  label: 'Giriş Yap',
                  onPressed: () {
                    // Login sayfasına yönlendir
                    Navigator.pushNamed(context, '/login');
                  },
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        });
      }
    }

    setState(() {
      _showResult = true;
      _isCorrect = isCorrect;
    });
  }

  void _nextExercise() {
    setState(() {
      _showResult = false;
      _selectedWords = [];
      _selectedIndices = [];

      // If the answer was correct, remove this exercise from _filteredExercises
      if (_isCorrect) {
        _filteredExercises.removeAt(_currentExerciseIndex);

        // Check if there are any exercises left
        if (_filteredExercises.isEmpty) {
          // Tüm alıştırmalar tamamlandı, _allExercisesCompleted flag'ini aktif et
          // Dialog göstermek yerine tebrikler ekranını göstereceğiz
          _allExercisesCompleted = true;
          return;
        }
      } else {
        // If the answer was wrong, move to the next exercise or cycle back to the beginning
        _currentExerciseIndex =
            (_currentExerciseIndex + 1) % _filteredExercises.length;
      }
    });
  }

  // Show a dialog when all exercises are completed
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Tebrikler!'),
        content: Text(
            'Bu oturumdaki alıştırmaları tamamladınız. Doğru cevapladığınız alıştırmalar artık karşınıza çıkmayacak ve ilerleyişiniz kaydedildi.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.topic,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: widget.color,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Tüm alıştırmalar tamamlandıysa tebrik ekranını göster
    if (_allExercisesCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.topic,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: widget.color,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tebrikler ikonu
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              // Tebrikler mesajı
              Text(
                'Tebrikler!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Bu oturumdaki alıştırmaları tamamladınız.\nDoğru cevapladığınız alıştırmalar artık karşınıza çıkmayacak ve ilerlemeniz kaydedildi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Tamam butonu
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Tamam',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Alıştırma içeriği yoksa
    if (_filteredExercises.isEmpty) {
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tebrikler!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu oturumdaki alıştırmaları tamamladınız. Doğru cevapladığınız alıştırmalar artık karşınıza çıkmayacak ve ilerleyişiniz kaydedildi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Tamam'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentExercise = _filteredExercises[_currentExerciseIndex];

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
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            color:
                                isDark ? const Color(0xFF242424) : Colors.white,
                          ),
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
                                const SizedBox(height: 12),
                                Text(
                                  _grammarExplanations[widget.topic] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.black87,
                                    height: 1.6,
                                  ),
                                ),
                                // Past Perfect için örnek ekleyelim
                                if (widget.topic == 'Past Perfect')
                                  Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: widget.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: widget.color.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Örnek:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: widget.color,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.5,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'When I arrived, ',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.grey[300]
                                                      : Colors.black87,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'she had already left',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: widget.color,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '.',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.grey[300]
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ben vardığımda, o çoktan ayrılmıştı.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[800],
                                          ),
                                        ),
                                      ],
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
                              'Alıştırma ${_currentExerciseIndex + 1}/${_filteredExercises.length}',
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
                            width: _showResult ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(minHeight: 100),
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
                            const SizedBox(height: 12),
                            _selectedWords.isEmpty
                                ? Center(
                                    child: Text(
                                      'Aşağıdan kelime seçerek cümle oluşturun',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : Wrap(
                                    spacing: 8,
                                    runSpacing: 10,
                                    children: List.generate(
                                        _selectedWords.length, (index) {
                                      return InkWell(
                                        onTap: () => _removeWord(index),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                widget.color.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color:
                                                  widget.color.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _selectedWords[index],
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(
                                                Icons.close,
                                                size: 16,
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
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

                      // Words selection area
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelimeleri seçerek cümle oluşturun:',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 12,
                              children: List.generate(
                                _filteredExercises[_currentExerciseIndex]
                                        ['words']
                                    .length,
                                (index) {
                                  final word =
                                      _filteredExercises[_currentExerciseIndex]
                                          ['words'][index] as String;
                                  final isSelected =
                                      _selectedIndices.contains(index);
                                  return AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: isSelected ? 0.0 : 1.0,
                                    child: isSelected
                                        ? const SizedBox.shrink()
                                        : Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () =>
                                                  _selectWord(index, word),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? const Color(0xFF3B3B3B)
                                                      : const Color(0xFFF0F0FF),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 3,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  word,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black87,
                                                  ),
                                                ),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 56,
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                                    elevation: _selectedWords.isEmpty ? 0 : 2,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
