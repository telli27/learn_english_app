import '../game_enums.dart';
import 'sentence_building_models.dart';

/// Professional sentence building game data repository
class SentenceBuildingDataRepository {
  static const List<SentenceBuildingLevel> _levels = [
    // Level 1: Beginner - Basic Sentence Structures
    SentenceBuildingLevel(
      id: 'level_1',
      title: 'Temel Cümle Yapıları',
      description: 'Basit cümle kurma ve kelime sırası',
      difficulty: DifficultyLevel.beginner,
      isUnlocked: true,
      grammarTopics: [
        GrammarFocus.presentSimple,
        GrammarFocus.wordOrder,
        GrammarFocus.articles,
      ],
      exercises: [
        // Exercise 1: Present Simple - Positive
        SentenceBuildingExercise(
          id: 'ex_1_1',
          levelId: 'level_1',
          order: 1,
          title: 'Şimdiki Zaman - Olumlu',
          description: 'Basit şimdiki zaman cümleleri kurun',
          targetSentence: 'I eat breakfast every morning',
          turkishTranslation: 'Her sabah kahvaltı yaparım',
          words: ['I', 'eat', 'breakfast', 'every', 'morning'],
          distractorWords: ['lunch', 'dinner', 'afternoon', 'evening'],
          grammarFocus: GrammarFocus.presentSimple,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Present Simple tense ile günlük alışkanlıkları ifade ederiz. Özne + fiil + nesne + zaman belirteci sırası kullanılır.',
          grammarRule: 'Present Simple: Subject + Verb + Object + Time',
          hints: [
            'Cümle "I" ile başlar',
            'Fiil "eat" ikinci sırada gelir',
            'Zaman belirteci sonda yer alır'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_2',
          levelId: 'level_1',
          order: 2,
          title: 'Şimdiki Zaman - Üçüncü Şahıs',
          description: 'He/She/It ile cümle kurun',
          targetSentence: 'She goes to school by bus',
          turkishTranslation: 'O okula otobüsle gider',
          words: ['She', 'goes', 'to', 'school', 'by', 'bus'],
          distractorWords: ['He', 'walks', 'car', 'train', 'home'],
          grammarFocus: GrammarFocus.presentSimple,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Üçüncü şahıs tekil (he, she, it) ile fiillere -s eki gelir. "Go" fiili "goes" olur.',
          grammarRule: 'Third Person Singular: He/She/It + Verb+s',
          hints: [
            'Üçüncü şahıs "She" ile başlar',
            'Fiil "goes" (-s eki ile)',
            'Ulaşım şekli "by bus" ile belirtilir'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_3',
          levelId: 'level_1',
          order: 3,
          title: 'Soru Cümlesi',
          description: 'Do/Does ile soru cümlesi kurun',
          targetSentence: 'Do you like chocolate ice cream',
          turkishTranslation: 'Çikolatalı dondurmayı sever misin?',
          words: ['Do', 'you', 'like', 'chocolate', 'ice', 'cream'],
          distractorWords: ['Does', 'love', 'vanilla', 'cake', 'cookies'],
          grammarFocus: GrammarFocus.questionFormation,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Present Simple sorularda "Do" (I, you, we, they) veya "Does" (he, she, it) kullanılır.',
          grammarRule: 'Questions: Do/Does + Subject + Verb + Object?',
          hints: [
            'Soru "Do" ile başlar',
            'Özne "you" ikinci sırada',
            'Fiil "like" kök halinde'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_4',
          levelId: 'level_1',
          order: 4,
          title: 'Olumsuz Cümle',
          description: 'Don\'t/Doesn\'t ile olumsuz cümle kurun',
          targetSentence: 'I don\'t watch TV at night',
          turkishTranslation: 'Geceleri televizyon izlemem',
          words: ['I', 'don\'t', 'watch', 'TV', 'at', 'night'],
          distractorWords: [
            'doesn\'t',
            'listen',
            'radio',
            'morning',
            'afternoon'
          ],
          grammarFocus: GrammarFocus.negativeFormation,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Present Simple olumsuz cümlelerde "don\'t" (I, you, we, they) veya "doesn\'t" (he, she, it) kullanılır.',
          grammarRule: 'Negative: Subject + don\'t/doesn\'t + Verb',
          hints: [
            'Özne "I" ile başlar',
            'Olumsuzluk "don\'t" ile',
            'Zaman "at night" ile belirtilir'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_5',
          levelId: 'level_1',
          order: 5,
          title: 'Be Fiili - Olumlu',
          description: 'Am/Is/Are ile cümle kurun',
          targetSentence: 'They are very happy today',
          turkishTranslation: 'Onlar bugün çok mutlular',
          words: ['They', 'are', 'very', 'happy', 'today'],
          distractorWords: ['is', 'am', 'sad', 'angry', 'yesterday'],
          grammarFocus: GrammarFocus.presentSimple,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Be fiili: I am, You are, He/She/It is, We/You/They are şeklinde kullanılır.',
          grammarRule: 'Be Verb: Subject + am/is/are + Adjective/Noun',
          hints: [
            'Çoğul özne "They" ile başlar',
            'Be fiili "are" kullanılır',
            'Sıfat "happy" durum belirtir'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_6',
          levelId: 'level_1',
          order: 6,
          title: 'Sıklık Zarfları',
          description: 'Always, usually, sometimes ile cümle kurun',
          targetSentence: 'We usually play football on Sundays',
          turkishTranslation: 'Pazar günleri genellikle futbol oynarız',
          words: ['We', 'usually', 'play', 'football', 'on', 'Sundays'],
          distractorWords: [
            'always',
            'never',
            'basketball',
            'Mondays',
            'sometimes'
          ],
          grammarFocus: GrammarFocus.adverbs,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Sıklık zarfları (always, usually, sometimes, never) özne ile ana fiil arasında yer alır.',
          grammarRule: 'Frequency Adverbs: Subject + Adverb + Verb + Object',
          hints: [
            'Özne "We" ile başlar',
            'Sıklık zarfı "usually" ikinci sırada',
            'Gün belirteci "on Sundays"'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_7',
          levelId: 'level_1',
          order: 7,
          title: 'There is/There are',
          description: 'Var/yok ifadeleri ile cümle kurun',
          targetSentence: 'There are many books in the library',
          turkishTranslation: 'Kütüphanede çok kitap var',
          words: ['There', 'are', 'many', 'books', 'in', 'the', 'library'],
          distractorWords: ['is', 'few', 'students', 'classroom', 'some'],
          grammarFocus: GrammarFocus.articles,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'There is (tekil) ve There are (çoğul) varlık belirtmek için kullanılır. Çoğul isimlerle "are" kullanılır.',
          grammarRule: 'Existence: There is/are + Object + Place',
          hints: [
            'Varlık ifadesi "There are" ile başlar',
            'Çoğul isim "books" kullanılır',
            'Yer belirteci "in the library"'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_8',
          levelId: 'level_1',
          order: 8,
          title: 'Can/Can\'t - Yetenek',
          description: 'Yetenek ifadeleri ile cümle kurun',
          targetSentence: 'My sister can speak three languages',
          turkishTranslation: 'Kız kardeşim üç dil konuşabilir',
          words: ['My', 'sister', 'can', 'speak', 'three', 'languages'],
          distractorWords: ['can\'t', 'brother', 'write', 'two', 'books'],
          grammarFocus: GrammarFocus.modalVerbs,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Can yetenek, beceri ve izin ifade eder. Can\'t ise yetersizlik ve yasak belirtir.',
          grammarRule: 'Ability: Subject + can/can\'t + Verb + Object',
          hints: [
            'Sahiplik "My sister" ile başlar',
            'Yetenek "can" ile ifade edilir',
            'Fiil "speak" kök halinde'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_9',
          levelId: 'level_1',
          order: 9,
          title: 'Prepositions - Yer Edatları',
          description: 'In, on, at edatları ile cümle kurun',
          targetSentence: 'The cat is sleeping under the table',
          turkishTranslation: 'Kedi masanın altında uyuyor',
          words: ['The', 'cat', 'is', 'sleeping', 'under', 'the', 'table'],
          distractorWords: ['on', 'above', 'dog', 'running', 'chair'],
          grammarFocus: GrammarFocus.prepositions,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Yer edatları (under, on, in, at) nesnelerin konumunu belirtir. Under = altında.',
          grammarRule:
              'Position: Subject + be + Verb+ing + Preposition + Object',
          hints: [
            'Belirli tanımlık "The cat" ile başlar',
            'Şimdiki zaman "is sleeping"',
            'Yer edatı "under the table"'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_10',
          levelId: 'level_1',
          order: 10,
          title: 'Have/Has - Sahiplik',
          description: 'Sahiplik ifadeleri ile cümle kurun',
          targetSentence: 'He has a beautiful red car',
          turkishTranslation: 'Onun güzel kırmızı bir arabası var',
          words: ['He', 'has', 'a', 'beautiful', 'red', 'car'],
          distractorWords: ['have', 'ugly', 'blue', 'bike', 'house'],
          grammarFocus: GrammarFocus.presentSimple,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Have (I, you, we, they) ve Has (he, she, it) sahiplik belirtir. Sıfatlar isimden önce gelir.',
          grammarRule:
              'Possession: Subject + have/has + Article + Adjective + Noun',
          hints: [
            'Üçüncü şahıs "He" ile başlar',
            'Sahiplik "has" ile ifade edilir',
            'Sıfatlar "beautiful red" sırasıyla'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_11',
          levelId: 'level_1',
          order: 11,
          title: 'Wh- Questions',
          description: 'What, Where, When ile soru cümlesi kurun',
          targetSentence: 'Where do you live in the city',
          turkishTranslation: 'Şehirde nerede yaşıyorsun?',
          words: ['Where', 'do', 'you', 'live', 'in', 'the', 'city'],
          distractorWords: ['What', 'When', 'does', 'work', 'country'],
          grammarFocus: GrammarFocus.questionFormation,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Wh- soruları bilgi almak için kullanılır. Where = nerede, What = ne, When = ne zaman.',
          grammarRule:
              'Wh-Questions: Wh-word + do/does + Subject + Verb + Object?',
          hints: [
            'Soru kelimesi "Where" ile başlar',
            'Yardımcı fiil "do" ikinci sırada',
            'Yer belirteci "in the city"'
          ],
          timeLimit: 45,
        ),

        SentenceBuildingExercise(
          id: 'ex_1_12',
          levelId: 'level_1',
          order: 12,
          title: 'Imperatives - Emir Cümleleri',
          description: 'Emir ve rica cümleleri kurun',
          targetSentence: 'Please close the door quietly',
          turkishTranslation: 'Lütfen kapıyı sessizce kapatın',
          words: ['Please', 'close', 'the', 'door', 'quietly'],
          distractorWords: ['open', 'window', 'loudly', 'slowly', 'quickly'],
          grammarFocus: GrammarFocus.wordOrder,
          difficulty: DifficultyLevel.beginner,
          explanation:
              'Emir cümleleri fiil ile başlar. Please nezaket ifadesi ekler. Zarf fiili niteler.',
          grammarRule: 'Imperatives: (Please) + Verb + Object + Adverb',
          hints: [
            'Nezaket "Please" ile başlar',
            'Emir fiili "close" ikinci sırada',
            'Zarf "quietly" sonda yer alır'
          ],
          timeLimit: 45,
        ),
      ],
    ),

    // Level 2: Intermediate - Complex Structures
    SentenceBuildingLevel(
      id: 'level_2',
      title: 'Karmaşık Yapılar',
      description: 'Geçmiş zaman ve gelecek zaman cümleleri',
      difficulty: DifficultyLevel.intermediate,
      isUnlocked: false,
      isPremium: true,
      grammarTopics: [
        GrammarFocus.pastSimple,
        GrammarFocus.futureSimple,
        GrammarFocus.presentContinuous,
      ],
      exercises: [
        SentenceBuildingExercise(
          id: 'ex_2_1',
          levelId: 'level_2',
          order: 1,
          title: 'Geçmiş Zaman - Düzenli Fiiller',
          description: 'Past Simple ile cümle kurun',
          targetSentence: 'She visited her grandmother last weekend',
          turkishTranslation: 'Geçen hafta sonu büyükannesini ziyaret etti',
          words: ['She', 'visited', 'her', 'grandmother', 'last', 'weekend'],
          distractorWords: ['visits', 'mother', 'next', 'week', 'yesterday'],
          grammarFocus: GrammarFocus.pastSimple,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Past Simple\'da düzenli fiillere -ed eki eklenir. "Visit" fiili "visited" olur.',
          grammarRule: 'Past Simple: Subject + Verb+ed + Object + Time',
          hints: [
            'Özne "She" ile başlar',
            'Geçmiş zaman fiili "visited"',
            'Zaman belirteci "last weekend"'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_2',
          levelId: 'level_2',
          order: 2,
          title: 'Gelecek Zaman - Will',
          description: 'Will ile gelecek zaman cümlesi kurun',
          targetSentence: 'I will travel to Paris next month',
          turkishTranslation: 'Gelecek ay Paris\'e seyahat edeceğim',
          words: ['I', 'will', 'travel', 'to', 'Paris', 'next', 'month'],
          distractorWords: ['would', 'go', 'London', 'last', 'year'],
          grammarFocus: GrammarFocus.futureSimple,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Gelecek zaman için "will + fiil kök" yapısı kullanılır. Will ile spontan kararlar ve tahminler ifade edilir.',
          grammarRule: 'Future Simple: Subject + will + Verb + Object',
          hints: [
            'Özne "I" ile başlar',
            'Gelecek zaman "will" ile',
            'Fiil "travel" kök halinde'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_3',
          levelId: 'level_2',
          order: 3,
          title: 'Şimdiki Zaman Sürekli',
          description: 'Present Continuous ile cümle kurun',
          targetSentence: 'We are studying English grammar now',
          turkishTranslation: 'Şu anda İngilizce gramer çalışıyoruz',
          words: ['We', 'are', 'studying', 'English', 'grammar', 'now'],
          distractorWords: ['is', 'study', 'Turkish', 'vocabulary', 'later'],
          grammarFocus: GrammarFocus.presentContinuous,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Present Continuous şu anda devam eden eylemleri ifade eder. Yapı: am/is/are + fiil-ing',
          grammarRule: 'Present Continuous: Subject + am/is/are + Verb+ing',
          hints: [
            'Çoğul özne "We" ile başlar',
            'Be fiili "are" kullanılır',
            'Fiil "studying" (-ing eki ile)'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_4',
          levelId: 'level_2',
          order: 4,
          title: 'Geçmiş Zaman - Düzensiz Fiiller',
          description: 'Irregular verbs ile cümle kurun',
          targetSentence: 'They went to the cinema yesterday evening',
          turkishTranslation: 'Dün akşam sinemaya gittiler',
          words: [
            'They',
            'went',
            'to',
            'the',
            'cinema',
            'yesterday',
            'evening'
          ],
          distractorWords: ['go', 'theater', 'tomorrow', 'morning', 'came'],
          grammarFocus: GrammarFocus.pastSimple,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Düzensiz fiillerin geçmiş zaman halleri ezberlenmelidir. Go-went, come-came, see-saw gibi.',
          grammarRule:
              'Past Simple Irregular: Subject + Irregular Verb + Object',
          hints: [
            'Çoğul özne "They" ile başlar',
            'Düzensiz fiil "went" (go\'nun geçmişi)',
            'Zaman "yesterday evening"'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_5',
          levelId: 'level_2',
          order: 5,
          title: 'Going to - Planlar',
          description: 'Be going to ile gelecek planları ifade edin',
          targetSentence: 'She is going to buy a new laptop',
          turkishTranslation: 'Yeni bir laptop satın alacak',
          words: ['She', 'is', 'going', 'to', 'buy', 'a', 'new', 'laptop'],
          distractorWords: ['will', 'sell', 'old', 'computer', 'phone'],
          grammarFocus: GrammarFocus.futureSimple,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Be going to önceden planlanmış eylemler için kullanılır. Will\'den daha kesin planları ifade eder.',
          grammarRule: 'Future Plans: Subject + be + going to + Verb + Object',
          hints: [
            'Üçüncü şahıs "She" ile başlar',
            'Plan ifadesi "is going to"',
            'Fiil "buy" kök halinde'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_6',
          levelId: 'level_2',
          order: 6,
          title: 'Past Continuous',
          description: 'Geçmişte sürekli eylemler',
          targetSentence: 'I was reading a book when you called',
          turkishTranslation: 'Sen aradığında kitap okuyordum',
          words: ['I', 'was', 'reading', 'a', 'book', 'when', 'you', 'called'],
          distractorWords: ['were', 'writing', 'magazine', 'while', 'texted'],
          grammarFocus: GrammarFocus.pastContinuous,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Past Continuous geçmişte belirli bir anda devam eden eylemleri ifade eder. Was/were + fiil-ing',
          grammarRule:
              'Past Continuous: Subject + was/were + Verb+ing + when/while',
          hints: [
            'Tekil özne "I" ile başlar',
            'Geçmiş sürekli "was reading"',
            'Zaman bağlacı "when" kullanılır'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_7',
          levelId: 'level_2',
          order: 7,
          title: 'Comparative - Karşılaştırma',
          description: 'Sıfatların karşılaştırma derecesi',
          targetSentence: 'This book is more interesting than that one',
          turkishTranslation: 'Bu kitap şundan daha ilginç',
          words: [
            'This',
            'book',
            'is',
            'more',
            'interesting',
            'than',
            'that',
            'one'
          ],
          distractorWords: ['most', 'boring', 'less', 'these', 'those'],
          grammarFocus: GrammarFocus.comparatives,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Uzun sıfatlarda more + sıfat + than yapısı kullanılır. Kısa sıfatlarda -er eki eklenir.',
          grammarRule:
              'Comparative: Subject + be + more + Adjective + than + Object',
          hints: [
            'İşaret sıfatı "This book" ile başlar',
            'Karşılaştırma "more interesting"',
            'Karşılaştırma bağlacı "than"'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_8',
          levelId: 'level_2',
          order: 8,
          title: 'Present Perfect',
          description: 'Have/Has + Past Participle',
          targetSentence: 'We have lived here for five years',
          turkishTranslation: 'Beş yıldır burada yaşıyoruz',
          words: ['We', 'have', 'lived', 'here', 'for', 'five', 'years'],
          distractorWords: ['has', 'worked', 'there', 'since', 'months'],
          grammarFocus: GrammarFocus.presentPerfect,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Present Perfect geçmişte başlayıp şimdiye kadar devam eden eylemleri ifade eder. For = süre, since = başlangıç.',
          grammarRule:
              'Present Perfect: Subject + have/has + Past Participle + for/since',
          hints: [
            'Çoğul özne "We" ile başlar',
            'Present Perfect "have lived"',
            'Süre belirteci "for five years"'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_9',
          levelId: 'level_2',
          order: 9,
          title: 'Modal Verbs - Should',
          description: 'Tavsiye ve öneri cümleleri',
          targetSentence: 'You should eat more vegetables and fruits',
          turkishTranslation: 'Daha fazla sebze ve meyve yemelisin',
          words: [
            'You',
            'should',
            'eat',
            'more',
            'vegetables',
            'and',
            'fruits'
          ],
          distractorWords: ['must', 'drink', 'less', 'meat', 'or'],
          grammarFocus: GrammarFocus.modalVerbs,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Should tavsiye ve öneri ifade eder. Must zorunluluk, can yetenek, may izin/olasılık belirtir.',
          grammarRule: 'Advice: Subject + should + Verb + Object',
          hints: [
            'Özne "You" ile başlar',
            'Tavsiye "should" ile verilir',
            'Bağlaç "and" ile iki isim bağlanır'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_10',
          levelId: 'level_2',
          order: 10,
          title: 'Passive Voice - Edilgen',
          description: 'Edilgen çatı cümleleri',
          targetSentence: 'The house was built by my grandfather',
          turkishTranslation: 'Ev dedem tarafından inşa edildi',
          words: ['The', 'house', 'was', 'built', 'by', 'my', 'grandfather'],
          distractorWords: ['is', 'destroyed', 'with', 'father', 'uncle'],
          grammarFocus: GrammarFocus.passiveVoice,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Edilgen çatıda nesne özne konumuna geçer. Be + Past Participle + by + fail yapısı kullanılır.',
          grammarRule: 'Passive: Subject + be + Past Participle + by + Agent',
          hints: [
            'Edilgen özne "The house" ile başlar',
            'Edilgen fiil "was built"',
            'Fail "by my grandfather" ile belirtilir'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_11',
          levelId: 'level_2',
          order: 11,
          title: 'Conditional - If Clauses',
          description: 'Şartlı cümleler (Type 1)',
          targetSentence: 'If it rains tomorrow we will stay home',
          turkishTranslation: 'Yarın yağmur yağarsa evde kalacağız',
          words: [
            'If',
            'it',
            'rains',
            'tomorrow',
            'we',
            'will',
            'stay',
            'home'
          ],
          distractorWords: ['When', 'snows', 'today', 'go', 'outside'],
          grammarFocus: GrammarFocus.conditionals,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'Type 1 conditionals gerçek durumlar için kullanılır. If + Present Simple, will + fiil kök.',
          grammarRule:
              'First Conditional: If + Present Simple, Subject + will + Verb',
          hints: [
            'Şart "If it rains" ile başlar',
            'Zaman "tomorrow" şart cümlesinde',
            'Sonuç "we will stay home"'
          ],
          timeLimit: 60,
        ),
        SentenceBuildingExercise(
          id: 'ex_2_12',
          levelId: 'level_2',
          order: 12,
          title: 'Relative Clauses',
          description: 'İlgi zamirleri ile cümle bağlama',
          targetSentence: 'The man who lives next door is a doctor',
          turkishTranslation: 'Yan evde yaşayan adam doktor',
          words: [
            'The',
            'man',
            'who',
            'lives',
            'next',
            'door',
            'is',
            'a',
            'doctor'
          ],
          distractorWords: ['woman', 'which', 'works', 'upstairs', 'teacher'],
          grammarFocus: GrammarFocus.relativeClauses,
          difficulty: DifficultyLevel.intermediate,
          explanation:
              'İlgi zamirleri (who, which, that) cümleleri birleştirir. Who kişiler için, which nesneler için kullanılır.',
          grammarRule:
              'Relative Clauses: Noun + who/which/that + Verb + be + Complement',
          hints: [
            'Ana isim "The man" ile başlar',
            'İlgi zamiri "who" kişi için',
            'Ana fiil "is a doctor"'
          ],
          timeLimit: 60,
        ),
      ],
    ),

    // Level 3: Advanced - Complex Grammar
    SentenceBuildingLevel(
      id: 'level_3',
      title: 'İleri Seviye Gramer',
      description: 'Karmaşık zaman yapıları ve koşul cümleleri',
      difficulty: DifficultyLevel.advanced,
      isUnlocked: false,
      isPremium: true,
      grammarTopics: [
        GrammarFocus.presentPerfect,
        GrammarFocus.conditionals,
        GrammarFocus.passiveVoice,
      ],
      exercises: [
        SentenceBuildingExercise(
          id: 'ex_3_1',
          levelId: 'level_3',
          order: 1,
          title: 'Present Perfect',
          description: 'Have/Has + Past Participle ile cümle kurun',
          targetSentence: 'I have lived in this city for five years',
          turkishTranslation: 'Bu şehirde beş yıldır yaşıyorum',
          words: [
            'I',
            'have',
            'lived',
            'in',
            'this',
            'city',
            'for',
            'five',
            'years'
          ],
          distractorWords: ['has', 'live', 'since', 'three', 'months'],
          grammarFocus: GrammarFocus.presentPerfect,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Present Perfect geçmişte başlayıp şu ana kadar devam eden eylemleri ifade eder. Yapı: have/has + past participle',
          grammarRule: 'Present Perfect: Subject + have/has + Past Participle',
          hints: [
            'Özne "I" ile başlar',
            'Perfect yapısı "have lived"',
            'Süre "for five years" ile belirtilir'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_2',
          levelId: 'level_3',
          order: 2,
          title: 'İkinci Tip Koşul',
          description: 'If + Past Simple, would + Verb ile cümle kurun',
          targetSentence: 'If I were rich I would travel the world',
          turkishTranslation: 'Zengin olsaydım dünyayı gezer dolaşırdım',
          words: [
            'If',
            'I',
            'were',
            'rich',
            'I',
            'would',
            'travel',
            'the',
            'world'
          ],
          distractorWords: ['was', 'am', 'will', 'visit', 'country'],
          grammarFocus: GrammarFocus.conditionals,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'İkinci tip koşul cümleleri hayali durumları ifade eder. If + Past Simple, would + fiil kök yapısı kullanılır.',
          grammarRule:
              'Second Conditional: If + Past Simple, Subject + would + Verb',
          hints: [
            'Hayali koşul "If I were rich"',
            'Sonuç "I would travel"',
            'Nesne "the world" ile tamamlanır'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_3',
          levelId: 'level_3',
          order: 3,
          title: 'Past Perfect',
          description: 'Had + Past Participle ile geçmiş mükemmel zaman',
          targetSentence: 'She had finished her homework before dinner',
          turkishTranslation: 'Akşam yemeğinden önce ödevini bitirmişti',
          words: [
            'She',
            'had',
            'finished',
            'her',
            'homework',
            'before',
            'dinner'
          ],
          distractorWords: ['has', 'completed', 'after', 'lunch', 'breakfast'],
          grammarFocus: GrammarFocus.pastPerfect,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Past Perfect geçmişte bir olaydan daha önce tamamlanan eylemleri ifade eder. Had + Past Participle yapısı kullanılır.',
          grammarRule:
              'Past Perfect: Subject + had + Past Participle + before/after',
          hints: [
            'Özne "She" ile başlar',
            'Past Perfect "had finished"',
            'Zaman bağlacı "before dinner"'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_4',
          levelId: 'level_3',
          order: 4,
          title: 'Future Perfect',
          description: 'Will have + Past Participle ile gelecek mükemmel',
          targetSentence: 'By next year I will have graduated from university',
          turkishTranslation:
              'Gelecek yıla kadar üniversiteden mezun olmuş olacağım',
          words: [
            'By',
            'next',
            'year',
            'I',
            'will',
            'have',
            'graduated',
            'from',
            'university'
          ],
          distractorWords: ['In', 'this', 'month', 'graduate', 'college'],
          grammarFocus: GrammarFocus.futurePerfect,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Future Perfect gelecekte belirli bir zamana kadar tamamlanacak eylemleri ifade eder. Will have + Past Participle.',
          grammarRule:
              'Future Perfect: By + Time, Subject + will have + Past Participle',
          hints: [
            'Zaman "By next year" ile başlar',
            'Future Perfect "will have graduated"',
            'Yer "from university" ile belirtilir'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_5',
          levelId: 'level_3',
          order: 5,
          title: 'Reported Speech',
          description: 'Dolaylı anlatım cümleleri',
          targetSentence: 'He said that he was studying English literature',
          turkishTranslation: 'İngiliz edebiyatı çalıştığını söyledi',
          words: [
            'He',
            'said',
            'that',
            'he',
            'was',
            'studying',
            'English',
            'literature'
          ],
          distractorWords: ['told', 'is', 'learning', 'French', 'history'],
          grammarFocus: GrammarFocus.reportedSpeech,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Dolaylı anlatımda zaman bir derece geriye kayar. Present → Past, Past → Past Perfect gibi.',
          grammarRule:
              'Reported Speech: Subject + said + that + Subject + Past Tense',
          hints: [
            'Rapor eden "He said" ile başlar',
            'Bağlaç "that" kullanılır',
            'Zaman geriye kayar "was studying"'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_6',
          levelId: 'level_3',
          order: 6,
          title: 'Subjunctive Mood',
          description: 'Dilek kipi ve öneriler',
          targetSentence: 'I suggest that she study harder for the exam',
          turkishTranslation: 'Sınav için daha çok çalışmasını öneriyorum',
          words: [
            'I',
            'suggest',
            'that',
            'she',
            'study',
            'harder',
            'for',
            'the',
            'exam'
          ],
          distractorWords: ['recommend', 'studies', 'easier', 'test', 'quiz'],
          grammarFocus: GrammarFocus.subjunctive,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Suggest, recommend, insist gibi fiillerden sonra that + özne + fiil kök yapısı kullanılır.',
          grammarRule:
              'Subjunctive: Subject + suggest/recommend + that + Subject + Base Verb',
          hints: [
            'Öneri "I suggest" ile başlar',
            'Bağlaç "that she" kullanılır',
            'Fiil "study" kök halinde'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_7',
          levelId: 'level_3',
          order: 7,
          title: 'Mixed Conditionals',
          description: 'Karışık koşul cümleleri',
          targetSentence: 'If I had studied medicine I would be a doctor now',
          turkishTranslation: 'Tıp okusaydım şimdi doktor olurdum',
          words: [
            'If',
            'I',
            'had',
            'studied',
            'medicine',
            'I',
            'would',
            'be',
            'a',
            'doctor',
            'now'
          ],
          distractorWords: ['have', 'law', 'will', 'lawyer', 'then'],
          grammarFocus: GrammarFocus.conditionals,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Karışık koşullarda geçmiş koşul ile şimdiki sonuç birleşir. If + Past Perfect, would + be/have.',
          grammarRule:
              'Mixed Conditional: If + Past Perfect, Subject + would + be/have + now',
          hints: [
            'Geçmiş koşul "If I had studied"',
            'Şimdiki sonuç "would be"',
            'Zaman "now" ile vurgulanır'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_8',
          levelId: 'level_3',
          order: 8,
          title: 'Causative Verbs',
          description: 'Have/Get something done yapısı',
          targetSentence: 'I had my car repaired at the garage yesterday',
          turkishTranslation: 'Dün arabamı garajda tamir ettirdim',
          words: [
            'I',
            'had',
            'my',
            'car',
            'repaired',
            'at',
            'the',
            'garage',
            'yesterday'
          ],
          distractorWords: ['got', 'fixed', 'in', 'workshop', 'today'],
          grammarFocus: GrammarFocus.causative,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Causative yapıda başkasına yaptırılan işler ifade edilir. Have/Get + nesne + Past Participle.',
          grammarRule:
              'Causative: Subject + had/got + Object + Past Participle + Place',
          hints: [
            'Özne "I" ile başlar',
            'Causative "had my car repaired"',
            'Yer ve zaman "at the garage yesterday"'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_9',
          levelId: 'level_3',
          order: 9,
          title: 'Inversion',
          description: 'Devrik cümle yapıları',
          targetSentence: 'Never have I seen such a beautiful sunset',
          turkishTranslation: 'Hiç bu kadar güzel bir gün batımı görmemiştim',
          words: [
            'Never',
            'have',
            'I',
            'seen',
            'such',
            'a',
            'beautiful',
            'sunset'
          ],
          distractorWords: ['Always', 'had', 'watched', 'ugly', 'sunrise'],
          grammarFocus: GrammarFocus.inversion,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Olumsuz zarflarla başlayan cümlelerde devrik yapı kullanılır. Never, rarely, seldom + yardımcı fiil + özne.',
          grammarRule:
              'Inversion: Negative Adverb + Auxiliary + Subject + Main Verb',
          hints: [
            'Olumsuz zarf "Never" ile başlar',
            'Devrik yapı "have I seen"',
            'Güçlendirme "such a beautiful"'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_10',
          levelId: 'level_3',
          order: 10,
          title: 'Cleft Sentences',
          description: 'Vurgulu cümle yapıları',
          targetSentence: 'It was John who broke the window yesterday',
          turkishTranslation: 'Dün camı kıran John\'du',
          words: [
            'It',
            'was',
            'John',
            'who',
            'broke',
            'the',
            'window',
            'yesterday'
          ],
          distractorWords: ['That', 'is', 'Mary', 'which', 'fixed', 'door'],
          grammarFocus: GrammarFocus.cleftSentences,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Cleft sentences belirli bir ögeyi vurgulamak için kullanılır. It + be + vurgulanan + who/that/which.',
          grammarRule:
              'Cleft: It + was/is + Focus + who/that/which + Rest of Sentence',
          hints: [
            'Vurgu yapısı "It was" ile başlar',
            'Vurgulanan kişi "John"',
            'İlgi zamiri "who" kişi için'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_11',
          levelId: 'level_3',
          order: 11,
          title: 'Participle Clauses',
          description: 'Ortaç cümleleri',
          targetSentence: 'Having finished the project he went home early',
          turkishTranslation: 'Projeyi bitirdikten sonra eve erken gitti',
          words: [
            'Having',
            'finished',
            'the',
            'project',
            'he',
            'went',
            'home',
            'early'
          ],
          distractorWords: [
            'After',
            'completing',
            'assignment',
            'came',
            'late'
          ],
          grammarFocus: GrammarFocus.participialClauses,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Perfect participle (having + past participle) önce tamamlanan eylemleri ifade eder.',
          grammarRule:
              'Perfect Participle: Having + Past Participle, Subject + Main Verb',
          hints: [
            'Perfect participle "Having finished"',
            'Ana cümle "he went home"',
            'Zarf "early" ile nitelenir'
          ],
          timeLimit: 75,
        ),
        SentenceBuildingExercise(
          id: 'ex_3_12',
          levelId: 'level_3',
          order: 12,
          title: 'Advanced Passive',
          description: 'Karmaşık edilgen yapılar',
          targetSentence:
              'The building is said to have been designed by a famous architect',
          turkishTranslation:
              'Binanın ünlü bir mimar tarafından tasarlandığı söyleniyor',
          words: [
            'The',
            'building',
            'is',
            'said',
            'to',
            'have',
            'been',
            'designed',
            'by',
            'a',
            'famous',
            'architect'
          ],
          distractorWords: [
            'house',
            'believed',
            'built',
            'unknown',
            'engineer'
          ],
          grammarFocus: GrammarFocus.passiveVoice,
          difficulty: DifficultyLevel.advanced,
          explanation:
              'Karmaşık edilgen yapılarda "is said to have been + past participle" kullanılır. Geçmiş eylemler için.',
          grammarRule:
              'Complex Passive: Subject + is said/believed + to have been + Past Participle',
          hints: [
            'Edilgen özne "The building"',
            'Rivayet "is said to have been"',
            'Fail "by a famous architect"'
          ],
          timeLimit: 75,
        ),
      ],
    ),
  ];

  /// Get all levels
  static List<SentenceBuildingLevel> getAllLevels() {
    return List.from(_levels);
  }

  /// Get levels by difficulty
  static List<SentenceBuildingLevel> getLevelsByDifficulty(
      DifficultyLevel difficulty) {
    return _levels.where((level) => level.difficulty == difficulty).toList();
  }

  /// Get level by ID
  static SentenceBuildingLevel? getLevelById(String id) {
    try {
      return _levels.firstWhere((level) => level.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get exercise by ID
  static SentenceBuildingExercise? getExerciseById(String exerciseId) {
    for (final level in _levels) {
      try {
        return level.exercises.firstWhere((ex) => ex.id == exerciseId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Get next level
  static SentenceBuildingLevel? getNextLevel(String currentLevelId) {
    final currentIndex =
        _levels.indexWhere((level) => level.id == currentLevelId);
    if (currentIndex == -1 || currentIndex >= _levels.length - 1) {
      return null;
    }
    return _levels[currentIndex + 1];
  }

  /// Get previous level
  static SentenceBuildingLevel? getPreviousLevel(String currentLevelId) {
    final currentIndex =
        _levels.indexWhere((level) => level.id == currentLevelId);
    if (currentIndex <= 0) {
      return null;
    }
    return _levels[currentIndex - 1];
  }

  /// Check if level is unlocked
  static bool isLevelUnlocked(String levelId, List<String> completedLevels) {
    final level = getLevelById(levelId);
    if (level == null) return false;

    // First level is always unlocked
    if (levelId == _levels.first.id) return true;

    // Check if previous level is completed
    final currentIndex = _levels.indexWhere((l) => l.id == levelId);
    if (currentIndex > 0) {
      final previousLevel = _levels[currentIndex - 1];
      return completedLevels.contains(previousLevel.id);
    }

    return false;
  }

  /// Get total exercises count
  static int getTotalExercisesCount() {
    return _levels.fold(0, (sum, level) => sum + level.exercises.length);
  }

  /// Get exercises by grammar focus
  static List<SentenceBuildingExercise> getExercisesByGrammarFocus(
      GrammarFocus focus) {
    final exercises = <SentenceBuildingExercise>[];
    for (final level in _levels) {
      exercises.addAll(level.exercises.where((ex) => ex.grammarFocus == focus));
    }
    return exercises;
  }
}
