import '../../models/word_models.dart';

/// Represents a sentence with a missing word and multiple choice options
class SentenceQuestion {
  final String id;
  final String sentence;
  final String missingWord;
  final int missingWordIndex;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String difficulty;

  const SentenceQuestion({
    required this.id,
    required this.sentence,
    required this.missingWord,
    required this.missingWordIndex,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
  });

  /// Get the sentence with a blank space for the missing word
  String get sentenceWithBlank {
    final words = sentence.split(' ');
    words[missingWordIndex] = '____';
    return words.join(' ');
  }

  /// Get the complete sentence with the correct answer
  String get completeSentence {
    final words = sentence.split(' ');
    words[missingWordIndex] = correctAnswer;
    return words.join(' ');
  }

  /// Check if the given answer is correct
  bool isCorrectAnswer(String answer) {
    return answer.toLowerCase().trim() == correctAnswer.toLowerCase().trim();
  }
}

/// Represents an exercise containing multiple sentence questions
class SentenceExercise {
  final String id;
  final int orderInLevel;
  final List<SentenceQuestion> questions;
  final int timeLimit;
  final String difficulty;

  const SentenceExercise({
    required this.id,
    required this.orderInLevel,
    required this.questions,
    required this.timeLimit,
    required this.difficulty,
  });

  /// Get the number of questions in this exercise
  int get questionCount => questions.length;
}

/// Represents a level containing multiple exercises
class SentenceLevel {
  final int id;
  final String title;
  final String description;
  final List<SentenceExercise> exercises;
  final String difficulty;
  final bool isLocked;

  const SentenceLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
    required this.difficulty,
    required this.isLocked,
  });

  /// Get the number of exercises in this level
  int get exerciseCount => exercises.length;

  /// Get total number of questions in this level
  int get totalQuestions =>
      exercises.fold(0, (sum, exercise) => sum + exercise.questionCount);
}

/// Data provider for sentence completion game
class SentenceCompletionData {
  static const int _timeLimit = 90; // 90 seconds per exercise

  /// Get all available levels
  static List<SentenceLevel> getLevels() {
    return [
      _createLevel1(),
      _createLevel2(),
      _createLevel3(),
    ];
  }

  /// Level 1: Basic sentence completion (Present tense, simple vocabulary)
  static SentenceLevel _createLevel1() {
    return SentenceLevel(
      id: 1,
      title: 'Temel Cümle Tamamlama',
      description: 'Basit kelimeler ve şimdiki zaman ile cümle tamamlama',
      difficulty: 'Başlangıç',
      isLocked: false,
      exercises: [
        // Exercise 1: Basic present tense
        SentenceExercise(
          id: '1_1',
          orderInLevel: 1,
          timeLimit: _timeLimit,
          difficulty: 'Başlangıç',
          questions: [
            SentenceQuestion(
              id: '1_1_1',
              sentence: 'I eat an apple every day',
              missingWord: 'eat',
              missingWordIndex: 1,
              options: ['eat', 'drink', 'buy', 'see'],
              correctAnswer: 'eat',
              explanation: 'Elma yenir, içilmez. "Eat" doğru seçenektir.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_1_2',
              sentence: 'She goes to school by bus',
              missingWord: 'goes',
              missingWordIndex: 1,
              options: ['go', 'goes', 'going', 'went'],
              correctAnswer: 'goes',
              explanation: 'Üçüncü tekil şahıs (she) ile "goes" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_1_3',
              sentence: 'The cat is sleeping on the sofa',
              missingWord: 'sleeping',
              missingWordIndex: 3,
              options: ['sleep', 'sleeping', 'sleeps', 'slept'],
              correctAnswer: 'sleeping',
              explanation:
                  'Present continuous tense için "is sleeping" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_1_4',
              sentence: 'We have a big house',
              missingWord: 'have',
              missingWordIndex: 1,
              options: ['have', 'has', 'had', 'having'],
              correctAnswer: 'have',
              explanation: 'Çoğul özne (we) ile "have" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_1_5',
              sentence: 'They are playing football in the park',
              missingWord: 'playing',
              missingWordIndex: 2,
              options: ['play', 'playing', 'plays', 'played'],
              correctAnswer: 'playing',
              explanation:
                  'Present continuous tense için "are playing" kullanılır.',
              difficulty: 'Başlangıç',
            ),
          ],
        ),

        // Exercise 2: Basic vocabulary
        SentenceExercise(
          id: '1_2',
          orderInLevel: 2,
          timeLimit: _timeLimit,
          difficulty: 'Başlangıç',
          questions: [
            SentenceQuestion(
              id: '1_2_1',
              sentence: 'The sun is shining brightly today',
              missingWord: 'sun',
              missingWordIndex: 1,
              options: ['moon', 'sun', 'star', 'cloud'],
              correctAnswer: 'sun',
              explanation:
                  'Parlak şekilde parlayanın güneş olması mantıklıdır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_2_2',
              sentence: 'I drink water when I am thirsty',
              missingWord: 'water',
              missingWordIndex: 2,
              options: ['food', 'water', 'coffee', 'juice'],
              correctAnswer: 'water',
              explanation: 'Susadığımızda su içeriz.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_2_3',
              sentence: 'My mother cooks delicious food',
              missingWord: 'cooks',
              missingWordIndex: 2,
              options: ['eats', 'cooks', 'buys', 'sells'],
              correctAnswer: 'cooks',
              explanation: 'Yemek pişirmek için "cook" fiili kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_2_4',
              sentence: 'The dog runs fast in the garden',
              missingWord: 'fast',
              missingWordIndex: 3,
              options: ['slow', 'fast', 'quiet', 'loud'],
              correctAnswer: 'fast',
              explanation: 'Köpeklerin hızlı koşması doğaldır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_2_5',
              sentence: 'Children love to play with toys',
              missingWord: 'toys',
              missingWordIndex: 6,
              options: ['books', 'toys', 'food', 'clothes'],
              correctAnswer: 'toys',
              explanation: 'Çocuklar oyuncaklarla oynamayı severler.',
              difficulty: 'Başlangıç',
            ),
          ],
        ),

        // Exercise 3: Simple past tense
        SentenceExercise(
          id: '1_3',
          orderInLevel: 3,
          timeLimit: _timeLimit,
          difficulty: 'Başlangıç',
          questions: [
            SentenceQuestion(
              id: '1_3_1',
              sentence: 'Yesterday I went to the market',
              missingWord: 'went',
              missingWordIndex: 2,
              options: ['go', 'goes', 'went', 'going'],
              correctAnswer: 'went',
              explanation: 'Geçmiş zaman için "went" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_3_2',
              sentence: 'She watched a movie last night',
              missingWord: 'watched',
              missingWordIndex: 1,
              options: ['watch', 'watches', 'watched', 'watching'],
              correctAnswer: 'watched',
              explanation: 'Geçmiş zaman için "watched" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_3_3',
              sentence: 'We played football yesterday afternoon',
              missingWord: 'played',
              missingWordIndex: 1,
              options: ['play', 'plays', 'played', 'playing'],
              correctAnswer: 'played',
              explanation: 'Geçmiş zaman için "played" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_3_4',
              sentence: 'The teacher explained the lesson clearly',
              missingWord: 'explained',
              missingWordIndex: 2,
              options: ['explain', 'explains', 'explained', 'explaining'],
              correctAnswer: 'explained',
              explanation: 'Geçmiş zaman için "explained" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_3_5',
              sentence: 'They visited their grandparents last weekend',
              missingWord: 'visited',
              missingWordIndex: 1,
              options: ['visit', 'visits', 'visited', 'visiting'],
              correctAnswer: 'visited',
              explanation: 'Geçmiş zaman için "visited" kullanılır.',
              difficulty: 'Başlangıç',
            ),
          ],
        ),

        // Exercise 4: Questions and negatives
        SentenceExercise(
          id: '1_4',
          orderInLevel: 4,
          timeLimit: _timeLimit,
          difficulty: 'Başlangıç',
          questions: [
            SentenceQuestion(
              id: '1_4_1',
              sentence: 'Do you like chocolate ice cream',
              missingWord: 'Do',
              missingWordIndex: 0,
              options: ['Do', 'Does', 'Did', 'Are'],
              correctAnswer: 'Do',
              explanation: 'İkinci şahıs (you) ile soru için "Do" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_4_2',
              sentence: 'She does not speak French fluently',
              missingWord: 'not',
              missingWordIndex: 2,
              options: ['no', 'not', 'never', 'nothing'],
              correctAnswer: 'not',
              explanation: 'Olumsuz cümle için "does not" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_4_3',
              sentence: 'Where did you go last summer',
              missingWord: 'did',
              missingWordIndex: 1,
              options: ['do', 'does', 'did', 'are'],
              correctAnswer: 'did',
              explanation: 'Geçmiş zaman sorusu için "did" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_4_4',
              sentence: 'I do not understand this question',
              missingWord: 'understand',
              missingWordIndex: 3,
              options: ['know', 'understand', 'remember', 'forget'],
              correctAnswer: 'understand',
              explanation: 'Soruyu anlamama için "understand" kullanılır.',
              difficulty: 'Başlangıç',
            ),
            SentenceQuestion(
              id: '1_4_5',
              sentence: 'Does he work in a bank',
              missingWord: 'Does',
              missingWordIndex: 0,
              options: ['Do', 'Does', 'Did', 'Is'],
              correctAnswer: 'Does',
              explanation:
                  'Üçüncü tekil şahıs (he) ile soru için "Does" kullanılır.',
              difficulty: 'Başlangıç',
            ),
          ],
        ),
      ],
    );
  }

  /// Level 2: Intermediate sentence completion (Past/Future tenses, complex vocabulary)
  static SentenceLevel _createLevel2() {
    return SentenceLevel(
      id: 2,
      title: 'Orta Seviye Cümle Tamamlama',
      description: 'Geçmiş ve gelecek zamanlar, daha karmaşık kelimeler',
      difficulty: 'Orta',
      isLocked: false,
      exercises: [
        // Exercise 1: Future tense
        SentenceExercise(
          id: '2_1',
          orderInLevel: 1,
          timeLimit: _timeLimit,
          difficulty: 'Orta',
          questions: [
            SentenceQuestion(
              id: '2_1_1',
              sentence: 'I will travel to Paris next month',
              missingWord: 'will',
              missingWordIndex: 1,
              options: ['will', 'would', 'shall', 'should'],
              correctAnswer: 'will',
              explanation: 'Gelecek zaman için "will" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_1_2',
              sentence: 'She is going to study medicine at university',
              missingWord: 'going',
              missingWordIndex: 2,
              options: ['going', 'coming', 'trying', 'planning'],
              correctAnswer: 'going',
              explanation: 'Gelecek planı için "is going to" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_1_3',
              sentence: 'They will probably arrive late tonight',
              missingWord: 'probably',
              missingWordIndex: 2,
              options: ['definitely', 'probably', 'certainly', 'possibly'],
              correctAnswer: 'probably',
              explanation: 'Olasılık belirtmek için "probably" uygun.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_1_4',
              sentence: 'The weather forecast says it will rain tomorrow',
              missingWord: 'rain',
              missingWordIndex: 7,
              options: ['snow', 'rain', 'shine', 'storm'],
              correctAnswer: 'rain',
              explanation: 'Hava tahmini yağmur olacağını söylüyor.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_1_5',
              sentence: 'We are planning to move to a bigger house',
              missingWord: 'planning',
              missingWordIndex: 2,
              options: ['trying', 'planning', 'hoping', 'wanting'],
              correctAnswer: 'planning',
              explanation: 'Plan yapmak için "planning" kullanılır.',
              difficulty: 'Orta',
            ),
          ],
        ),

        // Exercise 2: Present perfect tense
        SentenceExercise(
          id: '2_2',
          orderInLevel: 2,
          timeLimit: _timeLimit,
          difficulty: 'Orta',
          questions: [
            SentenceQuestion(
              id: '2_2_1',
              sentence: 'I have lived in this city for five years',
              missingWord: 'have',
              missingWordIndex: 1,
              options: ['have', 'has', 'had', 'having'],
              correctAnswer: 'have',
              explanation: 'Present perfect için "have lived" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_2_2',
              sentence: 'She has already finished her homework',
              missingWord: 'already',
              missingWordIndex: 3,
              options: ['already', 'yet', 'still', 'just'],
              correctAnswer: 'already',
              explanation: 'Tamamlanmış eylem için "already" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_2_3',
              sentence: 'Have you ever been to London',
              missingWord: 'ever',
              missingWordIndex: 2,
              options: ['ever', 'never', 'always', 'sometimes'],
              correctAnswer: 'ever',
              explanation: 'Deneyim sorusu için "ever" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_2_4',
              sentence: 'They have not seen each other since graduation',
              missingWord: 'since',
              missingWordIndex: 7,
              options: ['for', 'since', 'during', 'while'],
              correctAnswer: 'since',
              explanation:
                  'Belirli bir zaman noktasından beri için "since" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_2_5',
              sentence: 'He has just returned from his vacation',
              missingWord: 'just',
              missingWordIndex: 2,
              options: ['just', 'already', 'yet', 'still'],
              correctAnswer: 'just',
              explanation: 'Yeni tamamlanan eylem için "just" kullanılır.',
              difficulty: 'Orta',
            ),
          ],
        ),

        // Exercise 3: Conditional sentences
        SentenceExercise(
          id: '2_3',
          orderInLevel: 3,
          timeLimit: _timeLimit,
          difficulty: 'Orta',
          questions: [
            SentenceQuestion(
              id: '2_3_1',
              sentence: 'If it rains tomorrow we will stay at home',
              missingWord: 'If',
              missingWordIndex: 0,
              options: ['If', 'When', 'While', 'Because'],
              correctAnswer: 'If',
              explanation: 'Koşul cümlesi için "If" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_3_2',
              sentence: 'I would help you if I had time',
              missingWord: 'would',
              missingWordIndex: 1,
              options: ['will', 'would', 'could', 'should'],
              correctAnswer: 'would',
              explanation: 'İkinci tip koşul cümlesi için "would" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_3_3',
              sentence: 'Unless you study hard you will fail the exam',
              missingWord: 'Unless',
              missingWordIndex: 0,
              options: ['If', 'Unless', 'When', 'Although'],
              correctAnswer: 'Unless',
              explanation: 'Olumsuz koşul için "Unless" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_3_4',
              sentence: 'She could speak French if she practiced more',
              missingWord: 'could',
              missingWordIndex: 1,
              options: ['can', 'could', 'will', 'would'],
              correctAnswer: 'could',
              explanation: 'Varsayımsal durum için "could" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_3_5',
              sentence: 'What would you do if you won the lottery',
              missingWord: 'won',
              missingWordIndex: 6,
              options: ['win', 'won', 'will win', 'have won'],
              correctAnswer: 'won',
              explanation:
                  'İkinci tip koşul cümlesinde geçmiş zaman kullanılır.',
              difficulty: 'Orta',
            ),
          ],
        ),

        // Exercise 4: Passive voice
        SentenceExercise(
          id: '2_4',
          orderInLevel: 4,
          timeLimit: _timeLimit,
          difficulty: 'Orta',
          questions: [
            SentenceQuestion(
              id: '2_4_1',
              sentence: 'The book was written by a famous author',
              missingWord: 'written',
              missingWordIndex: 3,
              options: ['wrote', 'written', 'writing', 'write'],
              correctAnswer: 'written',
              explanation:
                  'Passive voice için past participle "written" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_4_2',
              sentence: 'English is spoken in many countries',
              missingWord: 'spoken',
              missingWordIndex: 2,
              options: ['speak', 'spoke', 'spoken', 'speaking'],
              correctAnswer: 'spoken',
              explanation:
                  'Passive voice için past participle "spoken" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_4_3',
              sentence: 'The house will be built next year',
              missingWord: 'built',
              missingWordIndex: 4,
              options: ['build', 'built', 'building', 'builds'],
              correctAnswer: 'built',
              explanation:
                  'Future passive için past participle "built" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_4_4',
              sentence: 'The problem has been solved successfully',
              missingWord: 'solved',
              missingWordIndex: 4,
              options: ['solve', 'solved', 'solving', 'solves'],
              correctAnswer: 'solved',
              explanation:
                  'Present perfect passive için past participle "solved" kullanılır.',
              difficulty: 'Orta',
            ),
            SentenceQuestion(
              id: '2_4_5',
              sentence: 'The car is being repaired at the garage',
              missingWord: 'repaired',
              missingWordIndex: 4,
              options: ['repair', 'repaired', 'repairing', 'repairs'],
              correctAnswer: 'repaired',
              explanation:
                  'Present continuous passive için past participle "repaired" kullanılır.',
              difficulty: 'Orta',
            ),
          ],
        ),
      ],
    );
  }

  /// Level 3: Advanced sentence completion (Complex grammar, academic vocabulary)
  static SentenceLevel _createLevel3() {
    return SentenceLevel(
      id: 3,
      title: 'İleri Seviye Cümle Tamamlama',
      description: 'Karmaşık gramer yapıları ve akademik kelimeler',
      difficulty: 'İleri',
      isLocked: false,
      exercises: [
        // Exercise 1: Complex grammar structures
        SentenceExercise(
          id: '3_1',
          orderInLevel: 1,
          timeLimit: _timeLimit,
          difficulty: 'İleri',
          questions: [
            SentenceQuestion(
              id: '3_1_1',
              sentence: 'Having completed the project he felt relieved',
              missingWord: 'Having',
              missingWordIndex: 0,
              options: ['Having', 'After', 'When', 'Since'],
              correctAnswer: 'Having',
              explanation: 'Perfect participle için "Having" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_1_2',
              sentence: 'The more you practice the better you become',
              missingWord: 'better',
              missingWordIndex: 6,
              options: ['good', 'better', 'best', 'well'],
              correctAnswer: 'better',
              explanation: 'Comparative yapısında "the better" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_1_3',
              sentence:
                  'Not only did he pass the exam but he also got the highest score',
              missingWord: 'did',
              missingWordIndex: 2,
              options: ['he', 'did', 'was', 'has'],
              correctAnswer: 'did',
              explanation: 'Inversion yapısında "did" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_1_4',
              sentence:
                  'Were I to win the competition I would donate the prize',
              missingWord: 'Were',
              missingWordIndex: 0,
              options: ['If', 'Were', 'Should', 'Would'],
              correctAnswer: 'Were',
              explanation: 'Subjunctive mood için "Were" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_1_5',
              sentence: 'Scarcely had he arrived when the meeting started',
              missingWord: 'had',
              missingWordIndex: 1,
              options: ['he', 'had', 'was', 'did'],
              correctAnswer: 'had',
              explanation: 'Inversion yapısında "had" kullanılır.',
              difficulty: 'İleri',
            ),
          ],
        ),

        // Exercise 2: Academic vocabulary
        SentenceExercise(
          id: '3_2',
          orderInLevel: 2,
          timeLimit: _timeLimit,
          difficulty: 'İleri',
          questions: [
            SentenceQuestion(
              id: '3_2_1',
              sentence:
                  'The research methodology was thoroughly scrutinized by experts',
              missingWord: 'scrutinized',
              missingWordIndex: 5,
              options: ['examined', 'scrutinized', 'observed', 'watched'],
              correctAnswer: 'scrutinized',
              explanation:
                  'Akademik bağlamda detaylı inceleme için "scrutinized" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_2_2',
              sentence:
                  'The hypothesis was substantiated by empirical evidence',
              missingWord: 'substantiated',
              missingWordIndex: 3,
              options: ['proved', 'substantiated', 'shown', 'demonstrated'],
              correctAnswer: 'substantiated',
              explanation:
                  'Akademik yazımda kanıtlama için "substantiated" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_2_3',
              sentence:
                  'The phenomenon requires comprehensive analysis and interpretation',
              missingWord: 'comprehensive',
              missingWordIndex: 3,
              options: ['complete', 'comprehensive', 'full', 'total'],
              correctAnswer: 'comprehensive',
              explanation:
                  'Akademik bağlamda kapsamlı analiz için "comprehensive" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_2_4',
              sentence:
                  'The implications of this discovery are far-reaching and significant',
              missingWord: 'implications',
              missingWordIndex: 1,
              options: ['results', 'implications', 'effects', 'consequences'],
              correctAnswer: 'implications',
              explanation:
                  'Akademik yazımda sonuçlar için "implications" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_2_5',
              sentence:
                  'The correlation between variables was statistically significant',
              missingWord: 'correlation',
              missingWordIndex: 1,
              options: ['relation', 'correlation', 'connection', 'link'],
              correctAnswer: 'correlation',
              explanation:
                  'İstatistiksel ilişki için "correlation" kullanılır.',
              difficulty: 'İleri',
            ),
          ],
        ),

        // Exercise 3: Complex sentence structures
        SentenceExercise(
          id: '3_3',
          orderInLevel: 3,
          timeLimit: _timeLimit,
          difficulty: 'İleri',
          questions: [
            SentenceQuestion(
              id: '3_3_1',
              sentence:
                  'Notwithstanding the challenges we persevered and succeeded',
              missingWord: 'Notwithstanding',
              missingWordIndex: 0,
              options: ['Despite', 'Notwithstanding', 'Although', 'However'],
              correctAnswer: 'Notwithstanding',
              explanation: 'Formal yazımda "Notwithstanding" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_3_2',
              sentence:
                  'The committee deliberated extensively before reaching a consensus',
              missingWord: 'deliberated',
              missingWordIndex: 2,
              options: ['discussed', 'deliberated', 'talked', 'debated'],
              correctAnswer: 'deliberated',
              explanation: 'Formal müzakere için "deliberated" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_3_3',
              sentence: 'The proposal was deemed inappropriate by the board',
              missingWord: 'deemed',
              missingWordIndex: 3,
              options: ['considered', 'deemed', 'thought', 'believed'],
              correctAnswer: 'deemed',
              explanation: 'Formal değerlendirme için "deemed" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_3_4',
              sentence:
                  'The legislation encompasses various aspects of environmental protection',
              missingWord: 'encompasses',
              missingWordIndex: 2,
              options: ['includes', 'encompasses', 'contains', 'covers'],
              correctAnswer: 'encompasses',
              explanation: 'Kapsamlı içerme için "encompasses" kullanılır.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_3_5',
              sentence:
                  'The paradigm shift necessitated a complete restructuring of the system',
              missingWord: 'necessitated',
              missingWordIndex: 3,
              options: ['required', 'necessitated', 'needed', 'demanded'],
              correctAnswer: 'necessitated',
              explanation: 'Formal gereklilik için "necessitated" kullanılır.',
              difficulty: 'İleri',
            ),
          ],
        ),

        // Exercise 4: Idiomatic expressions
        SentenceExercise(
          id: '3_4',
          orderInLevel: 4,
          timeLimit: _timeLimit,
          difficulty: 'İleri',
          questions: [
            SentenceQuestion(
              id: '3_4_1',
              sentence:
                  'He decided to bite the bullet and face the consequences',
              missingWord: 'bullet',
              missingWordIndex: 5,
              options: ['bullet', 'dust', 'apple', 'cherry'],
              correctAnswer: 'bullet',
              explanation:
                  '"Bite the bullet" cesaretle karşılamak anlamında bir deyimdir.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_4_2',
              sentence:
                  'The project was a blessing in disguise for the company',
              missingWord: 'disguise',
              missingWordIndex: 6,
              options: ['disguise', 'surprise', 'shock', 'wonder'],
              correctAnswer: 'disguise',
              explanation:
                  '"Blessing in disguise" gizli nimet anlamında bir deyimdir.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_4_3',
              sentence: 'She broke the ice by telling a funny joke',
              missingWord: 'ice',
              missingWordIndex: 3,
              options: ['ice', 'silence', 'tension', 'barrier'],
              correctAnswer: 'ice',
              explanation:
                  '"Break the ice" buzları eritmek anlamında bir deyimdir.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_4_4',
              sentence: 'The news hit him like a bolt from the blue',
              missingWord: 'blue',
              missingWordIndex: 9,
              options: ['sky', 'blue', 'heaven', 'air'],
              correctAnswer: 'blue',
              explanation:
                  '"Bolt from the blue" beklenmedik haber anlamında bir deyimdir.',
              difficulty: 'İleri',
            ),
            SentenceQuestion(
              id: '3_4_5',
              sentence: 'He spilled the beans about the surprise party',
              missingWord: 'beans',
              missingWordIndex: 3,
              options: ['beans', 'secret', 'truth', 'news'],
              correctAnswer: 'beans',
              explanation:
                  '"Spill the beans" sırrı açığa vurmak anlamında bir deyimdir.',
              difficulty: 'İleri',
            ),
          ],
        ),
      ],
    );
  }
}
