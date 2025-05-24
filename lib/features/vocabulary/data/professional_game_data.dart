import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/game_enums.dart';
import '../models/game_models.dart';

/// Provider for the professional game data repository
final professionalGameDataProvider = Provider<ProfessionalGameDataRepository>(
  (ref) => ProfessionalGameDataRepository(),
);

/// Professional game data repository for managing vocabulary data
class ProfessionalGameDataRepository {
  /// Get levels for a specific difficulty
  Future<List<GameLevel>> getLevelsForDifficulty(
      DifficultyLevel difficulty) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    switch (difficulty) {
      case DifficultyLevel.beginner:
        return _createBeginnerLevels();
      case DifficultyLevel.intermediate:
        return _createIntermediateLevels();
      case DifficultyLevel.advanced:
        return _createAdvancedLevels();
      case DifficultyLevel.expert:
        return _createExpertLevels();
    }
  }

  /// Create beginner level data
  List<GameLevel> _createBeginnerLevels() {
    return [
      GameLevel(
        id: 'beginner_1',
        title: 'Temel Kelimeler',
        description: 'Günlük hayatın temel kelimeleri',
        difficulty: DifficultyLevel.beginner,
        isUnlocked: true,
        exercises: [
          GameExercise(
            id: 'beg_ex_1',
            levelId: 'beginner_1',
            order: 1,
            title: 'Renkler',
            description: 'Temel renk isimleri',
            difficulty: DifficultyLevel.beginner,
            studyTimeSeconds: 20,
            recallTimeSeconds: 40,
            words: [
              VocabularyWord(
                id: 'color_1',
                english: 'red',
                turkish: 'kırmızı',
                phonetic: '/red/',
                category: 'colors',
                difficulty: DifficultyLevel.beginner,
                hint: 'Kan ve gül rengi',
                example: 'The apple is red.',
              ),
              VocabularyWord(
                id: 'color_2',
                english: 'blue',
                turkish: 'mavi',
                phonetic: '/bluː/',
                category: 'colors',
                difficulty: DifficultyLevel.beginner,
                hint: 'Gökyüzü rengi',
                example: 'The sky is blue.',
              ),
              VocabularyWord(
                id: 'color_3',
                english: 'green',
                turkish: 'yeşil',
                phonetic: '/ɡriːn/',
                category: 'colors',
                difficulty: DifficultyLevel.beginner,
                hint: 'Ağaçların yaprak rengi',
                example: 'Grass is green.',
              ),
              VocabularyWord(
                id: 'color_4',
                english: 'yellow',
                turkish: 'sarı',
                phonetic: '/ˈjɛloʊ/',
                category: 'colors',
                difficulty: DifficultyLevel.beginner,
                hint: 'Güneş rengi',
                example: 'The sun is yellow.',
              ),
              VocabularyWord(
                id: 'color_5',
                english: 'black',
                turkish: 'siyah',
                phonetic: '/blæk/',
                category: 'colors',
                difficulty: DifficultyLevel.beginner,
                hint: 'Gecenin rengi',
                example: 'The cat is black.',
              ),
            ],
          ),
          GameExercise(
            id: 'beg_ex_2',
            levelId: 'beginner_1',
            order: 2,
            title: 'Aile',
            description: 'Aile üyeleri',
            difficulty: DifficultyLevel.beginner,
            studyTimeSeconds: 25,
            recallTimeSeconds: 45,
            words: [
              VocabularyWord(
                id: 'family_1',
                english: 'mother',
                turkish: 'anne',
                phonetic: '/ˈmʌðər/',
                category: 'family',
                difficulty: DifficultyLevel.beginner,
                hint: 'Kadın ebeveyn',
                example: 'My mother is kind.',
              ),
              VocabularyWord(
                id: 'family_2',
                english: 'father',
                turkish: 'baba',
                phonetic: '/ˈfɑːðər/',
                category: 'family',
                difficulty: DifficultyLevel.beginner,
                hint: 'Erkek ebeveyn',
                example: 'My father works hard.',
              ),
              VocabularyWord(
                id: 'family_3',
                english: 'brother',
                turkish: 'kardeş',
                phonetic: '/ˈbrʌðər/',
                category: 'family',
                difficulty: DifficultyLevel.beginner,
                hint: 'Erkek kardeş',
                example: 'I have one brother.',
              ),
              VocabularyWord(
                id: 'family_4',
                english: 'sister',
                turkish: 'kız kardeş',
                phonetic: '/ˈsɪstər/',
                category: 'family',
                difficulty: DifficultyLevel.beginner,
                hint: 'Kız kardeş',
                example: 'My sister is tall.',
              ),
              VocabularyWord(
                id: 'family_5',
                english: 'child',
                turkish: 'çocuk',
                phonetic: '/tʃaɪld/',
                category: 'family',
                difficulty: DifficultyLevel.beginner,
                hint: 'Küçük insan',
                example: 'The child is playing.',
              ),
            ],
          ),
          GameExercise(
            id: 'beg_ex_3',
            levelId: 'beginner_1',
            order: 3,
            title: 'Hayvanlar',
            description: 'Temel hayvan isimleri',
            difficulty: DifficultyLevel.beginner,
            studyTimeSeconds: 20,
            recallTimeSeconds: 40,
            words: [
              VocabularyWord(
                id: 'animal_1',
                english: 'cat',
                turkish: 'kedi',
                phonetic: '/kæt/',
                category: 'animals',
                difficulty: DifficultyLevel.beginner,
                hint: 'Miyavlayan ev hayvanı',
                example: 'The cat is sleeping.',
              ),
              VocabularyWord(
                id: 'animal_2',
                english: 'dog',
                turkish: 'köpek',
                phonetic: '/dɔːɡ/',
                category: 'animals',
                difficulty: DifficultyLevel.beginner,
                hint: 'Havlayan ev hayvanı',
                example: 'The dog is running.',
              ),
              VocabularyWord(
                id: 'animal_3',
                english: 'bird',
                turkish: 'kuş',
                phonetic: '/bɜːrd/',
                category: 'animals',
                difficulty: DifficultyLevel.beginner,
                hint: 'Uçan hayvan',
                example: 'The bird is singing.',
              ),
              VocabularyWord(
                id: 'animal_4',
                english: 'fish',
                turkish: 'balık',
                phonetic: '/fɪʃ/',
                category: 'animals',
                difficulty: DifficultyLevel.beginner,
                hint: 'Suda yaşar',
                example: 'The fish swims in water.',
              ),
              VocabularyWord(
                id: 'animal_5',
                english: 'horse',
                turkish: 'at',
                phonetic: '/hɔːrs/',
                category: 'animals',
                difficulty: DifficultyLevel.beginner,
                hint: 'Binilen büyük hayvan',
                example: 'The horse is fast.',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  /// Create intermediate level data
  List<GameLevel> _createIntermediateLevels() {
    return [
      GameLevel(
        id: 'intermediate_1',
        title: 'Orta Seviye Kelimeler',
        description: 'Günlük konuşmada kullanılan kelimeler',
        difficulty: DifficultyLevel.intermediate,
        exercises: [
          GameExercise(
            id: 'int_ex_1',
            levelId: 'intermediate_1',
            order: 1,
            title: 'Duygular',
            description: 'Temel duygular',
            difficulty: DifficultyLevel.intermediate,
            studyTimeSeconds: 25,
            recallTimeSeconds: 50,
            words: [
              VocabularyWord(
                id: 'emotion_1',
                english: 'happy',
                turkish: 'mutlu',
                phonetic: '/ˈhæpi/',
                category: 'emotions',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Sevinçli durum',
                example: 'I am happy today.',
              ),
              VocabularyWord(
                id: 'emotion_2',
                english: 'sad',
                turkish: 'üzgün',
                phonetic: '/sæd/',
                category: 'emotions',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Kederli durum',
                example: 'She looks sad.',
              ),
              VocabularyWord(
                id: 'emotion_3',
                english: 'angry',
                turkish: 'kızgın',
                phonetic: '/ˈæŋɡri/',
                category: 'emotions',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Öfkeli durum',
                example: 'He is angry about the news.',
              ),
              VocabularyWord(
                id: 'emotion_4',
                english: 'excited',
                turkish: 'heyecanlı',
                phonetic: '/ɪkˈsaɪtɪd/',
                category: 'emotions',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Coşkulu durum',
                example: 'We are excited about the trip.',
              ),
              VocabularyWord(
                id: 'emotion_5',
                english: 'nervous',
                turkish: 'gergin',
                phonetic: '/ˈnɜːrvəs/',
                category: 'emotions',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Endişeli durum',
                example: 'I am nervous before the exam.',
              ),
            ],
          ),
          GameExercise(
            id: 'int_ex_2',
            levelId: 'intermediate_1',
            order: 2,
            title: 'Yiyecekler',
            description: 'Günlük yiyecek isimleri',
            difficulty: DifficultyLevel.intermediate,
            studyTimeSeconds: 25,
            recallTimeSeconds: 50,
            words: [
              VocabularyWord(
                id: 'food_1',
                english: 'bread',
                turkish: 'ekmek',
                phonetic: '/bred/',
                category: 'food',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Temel besin',
                example: 'I eat bread for breakfast.',
              ),
              VocabularyWord(
                id: 'food_2',
                english: 'cheese',
                turkish: 'peynir',
                phonetic: '/tʃiːz/',
                category: 'food',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Sütten yapılan',
                example: 'This cheese tastes good.',
              ),
              VocabularyWord(
                id: 'food_3',
                english: 'apple',
                turkish: 'elma',
                phonetic: '/ˈæpəl/',
                category: 'food',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Kırmızı veya yeşil meyve',
                example: 'An apple a day keeps the doctor away.',
              ),
              VocabularyWord(
                id: 'food_4',
                english: 'water',
                turkish: 'su',
                phonetic: '/ˈwɔːtər/',
                category: 'food',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Yaşam için gerekli',
                example: 'I drink water every day.',
              ),
              VocabularyWord(
                id: 'food_5',
                english: 'coffee',
                turkish: 'kahve',
                phonetic: '/ˈkɔːfi/',
                category: 'food',
                difficulty: DifficultyLevel.intermediate,
                hint: 'Sabah içeceği',
                example: 'I need coffee in the morning.',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  /// Create advanced level data
  List<GameLevel> _createAdvancedLevels() {
    return [
      GameLevel(
        id: 'advanced_1',
        title: 'İleri Seviye Kelimeler',
        description: 'Akademik ve profesyonel kelimeler',
        difficulty: DifficultyLevel.advanced,
        exercises: [
          GameExercise(
            id: 'adv_ex_1',
            levelId: 'advanced_1',
            order: 1,
            title: 'Bilim',
            description: 'Bilimsel terimler',
            difficulty: DifficultyLevel.advanced,
            studyTimeSeconds: 30,
            recallTimeSeconds: 60,
            words: [
              VocabularyWord(
                id: 'science_1',
                english: 'hypothesis',
                turkish: 'hipotez',
                phonetic: '/haɪˈpɑːθəsɪs/',
                category: 'science',
                difficulty: DifficultyLevel.advanced,
                hint: 'Bilimsel tahmin',
                example: 'The scientist proposed a new hypothesis.',
              ),
              VocabularyWord(
                id: 'science_2',
                english: 'experiment',
                turkish: 'deney',
                phonetic: '/ɪkˈsperɪmənt/',
                category: 'science',
                difficulty: DifficultyLevel.advanced,
                hint: 'Bilimsel test',
                example: 'The experiment proved the theory.',
              ),
              VocabularyWord(
                id: 'science_3',
                english: 'analysis',
                turkish: 'analiz',
                phonetic: '/əˈnæləsɪs/',
                category: 'science',
                difficulty: DifficultyLevel.advanced,
                hint: 'Detaylı inceleme',
                example: 'The data analysis revealed important insights.',
              ),
              VocabularyWord(
                id: 'science_4',
                english: 'molecule',
                turkish: 'molekül',
                phonetic: '/ˈmɑːlɪkjuːl/',
                category: 'science',
                difficulty: DifficultyLevel.advanced,
                hint: 'Kimyasal yapı birimi',
                example: 'Water is made of H2O molecules.',
              ),
              VocabularyWord(
                id: 'science_5',
                english: 'phenomenon',
                turkish: 'fenomen',
                phonetic: '/fəˈnɑːmɪnən/',
                category: 'science',
                difficulty: DifficultyLevel.advanced,
                hint: 'Gözlemlenen olay',
                example: 'This is a rare natural phenomenon.',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  /// Create expert level data
  List<GameLevel> _createExpertLevels() {
    return [
      GameLevel(
        id: 'expert_1',
        title: 'Uzman Seviye Kelimeler',
        description: 'Karmaşık ve özel kelimeler',
        difficulty: DifficultyLevel.expert,
        exercises: [
          GameExercise(
            id: 'exp_ex_1',
            levelId: 'expert_1',
            order: 1,
            title: 'Felsefe',
            description: 'Felsefi terimler',
            difficulty: DifficultyLevel.expert,
            studyTimeSeconds: 35,
            recallTimeSeconds: 70,
            words: [
              VocabularyWord(
                id: 'philosophy_1',
                english: 'epistemology',
                turkish: 'epistemoloji',
                phonetic: '/ɪˌpɪstəˈmɑːlədʒi/',
                category: 'philosophy',
                difficulty: DifficultyLevel.expert,
                hint: 'Bilgi felsefesi',
                example: 'Epistemology studies the nature of knowledge.',
              ),
              VocabularyWord(
                id: 'philosophy_2',
                english: 'metaphysics',
                turkish: 'metafizik',
                phonetic: '/ˌmetəˈfɪzɪks/',
                category: 'philosophy',
                difficulty: DifficultyLevel.expert,
                hint: 'Varlık felsefesi',
                example: 'Metaphysics deals with the nature of reality.',
              ),
              VocabularyWord(
                id: 'philosophy_3',
                english: 'phenomenology',
                turkish: 'fenomenoloji',
                phonetic: '/fəˌnɑːməˈnɑːlədʒi/',
                category: 'philosophy',
                difficulty: DifficultyLevel.expert,
                hint: 'Deneyim felsefesi',
                example: 'Phenomenology studies conscious experience.',
              ),
              VocabularyWord(
                id: 'philosophy_4',
                english: 'dialectical',
                turkish: 'diyalektik',
                phonetic: '/ˌdaɪəˈlektɪkəl/',
                category: 'philosophy',
                difficulty: DifficultyLevel.expert,
                hint: 'Karşıt görüşlerin sentezi',
                example: 'He used a dialectical approach to the problem.',
              ),
              VocabularyWord(
                id: 'philosophy_5',
                english: 'existential',
                turkish: 'varoluşsal',
                phonetic: '/ˌeɡzɪˈstenʃəl/',
                category: 'philosophy',
                difficulty: DifficultyLevel.expert,
                hint: 'Varoluşla ilgili',
                example: 'The novel explores existential themes.',
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
