import '../models/listening_models.dart';

/// Listening practice data with stories for TTS
class ListeningData {
  static List<ListeningLevel> get levels => [
        // Beginner Level - Daily Life Stories
        ListeningLevel(
          id: 'beginner_daily',
          title: 'Günlük Yaşam Hikayeleri',
          description:
              'Basit günlük yaşam hikayelerini dinleyerek İngilizce anlama becerinizi geliştirin',
          difficulty: ListeningDifficulty.beginner,
          topic: ListeningTopic.dailyLife,
          iconPath: 'assets/icons/daily_life.png',
          isUnlocked: true,
          isPremium: false,
          estimatedDuration: 15,
          learningObjectives: [
            'Günlük aktiviteleri anlama',
            'Basit zaman ifadeleri',
            'Temel kelime dağarcığı',
          ],
          stories: [
            ListeningStory(
              id: 'morning_routine',
              title: 'My Morning Routine',
              summary: 'Sarah\'nın sabah rutinini anlatan kısa hikaye',
              content: '''
Hello, my name is Sarah. I want to tell you about my morning routine.

I wake up at seven o'clock every morning. First, I brush my teeth and wash my face. Then I go to the kitchen and make breakfast. I usually eat toast with butter and drink orange juice.

After breakfast, I take a shower and get dressed. I choose my clothes carefully because I work in an office. I wear a white shirt and black pants.

At eight thirty, I leave my house and walk to the bus stop. The bus comes at eight forty-five. I sit by the window and listen to music during the trip.

I arrive at work at nine o'clock. I say good morning to my colleagues and start my day with a cup of coffee. I love my morning routine because it helps me feel ready for the day.
          ''',
              difficulty: ListeningDifficulty.beginner,
              topic: ListeningTopic.dailyLife,
              estimatedDuration: 3,
              keyVocabulary: [
                'wake up',
                'brush teeth',
                'breakfast',
                'shower',
                'get dressed',
                'leave house',
                'bus stop',
                'colleagues',
                'routine'
              ],
              comprehensionQuestions: [
                ListeningQuestion(
                  id: 'q1',
                  question: 'What time does Sarah wake up?',
                  options: ['6:00', '7:00', '8:00', '9:00'],
                  correctAnswer: '7:00',
                  explanation:
                      'Sarah says "I wake up at seven o\'clock every morning."',
                ),
                ListeningQuestion(
                  id: 'q2',
                  question: 'What does Sarah drink for breakfast?',
                  options: ['Coffee', 'Tea', 'Orange juice', 'Water'],
                  correctAnswer: 'Orange juice',
                  explanation:
                      'Sarah mentions "I usually eat toast with butter and drink orange juice."',
                ),
                ListeningQuestion(
                  id: 'q3',
                  question: 'How does Sarah go to work?',
                  options: ['By car', 'By bus', 'By train', 'On foot'],
                  correctAnswer: 'By bus',
                  explanation:
                      'Sarah walks to the bus stop and takes the bus to work.',
                ),
              ],
            ),
            ListeningStory(
              id: 'weekend_plans',
              title: 'Weekend Plans',
              summary: 'Tom\'un hafta sonu planlarını anlatan hikaye',
              content: '''
Hi, I'm Tom. Today is Friday and I'm very excited about my weekend plans.

Tomorrow morning, I will visit my grandmother. She lives in a small house near the park. We will have tea together and she will tell me stories about her childhood. I love spending time with her.

In the afternoon, I plan to go shopping with my sister. We need to buy some clothes for the summer. The weather is getting warmer, so we need light shirts and shorts.

On Sunday, my family will have a picnic in the park. My mother will prepare sandwiches and my father will bring drinks. We will play football and enjoy the sunshine.

In the evening, I will watch a movie with my friends. We haven't decided which movie yet, but we all like comedy films. After the movie, we might go for ice cream.

I think this weekend will be wonderful. I love spending time with my family and friends.
          ''',
              difficulty: ListeningDifficulty.beginner,
              topic: ListeningTopic.dailyLife,
              estimatedDuration: 3,
              keyVocabulary: [
                'weekend',
                'visit',
                'grandmother',
                'shopping',
                'picnic',
                'prepare',
                'sunshine',
                'movie',
                'comedy',
                'ice cream'
              ],
              comprehensionQuestions: [
                ListeningQuestion(
                  id: 'q1',
                  question: 'Who will Tom visit on Saturday morning?',
                  options: [
                    'His sister',
                    'His grandmother',
                    'His friends',
                    'His mother'
                  ],
                  correctAnswer: 'His grandmother',
                  explanation:
                      'Tom says "Tomorrow morning, I will visit my grandmother."',
                ),
                ListeningQuestion(
                  id: 'q2',
                  question: 'What will the family do on Sunday?',
                  options: [
                    'Go shopping',
                    'Watch a movie',
                    'Have a picnic',
                    'Visit grandmother'
                  ],
                  correctAnswer: 'Have a picnic',
                  explanation:
                      'Tom mentions "On Sunday, my family will have a picnic in the park."',
                ),
              ],
            ),
            ListeningStory(
              id: 'favorite_food',
              title: 'My Favorite Food',
              summary: 'Emma\'nın en sevdiği yemekleri anlatan hikaye',
              content: '''
My name is Emma and I love food! I want to share with you my favorite foods and why I like them.

For breakfast, I always eat cereal with milk and fresh fruit. My favorite fruit is banana because it's sweet and healthy. Sometimes I add strawberries or blueberries to my cereal.

My favorite lunch is pizza. I know it's not very healthy, but I love the cheese and tomato sauce. My favorite pizza has mushrooms, peppers, and chicken. I usually eat pizza once a week.

For dinner, I prefer fish with vegetables. My mother cooks salmon with broccoli and carrots. It's delicious and very good for my health. I also like rice with my fish.

My favorite snack is chocolate cookies. I know I shouldn't eat too many, but they taste so good! I usually have two cookies with a glass of milk after school.

On special occasions, like birthdays, I love chocolate cake. My grandmother makes the best chocolate cake in the world. It has three layers and lots of chocolate cream.

Food makes me happy, but I try to eat healthy most of the time.
          ''',
              difficulty: ListeningDifficulty.beginner,
              topic: ListeningTopic.dailyLife,
              estimatedDuration: 3,
              keyVocabulary: [
                'cereal',
                'fresh fruit',
                'banana',
                'strawberries',
                'pizza',
                'cheese',
                'mushrooms',
                'salmon',
                'broccoli',
                'chocolate cake'
              ],
              comprehensionQuestions: [
                ListeningQuestion(
                  id: 'q1',
                  question: 'What does Emma eat for breakfast?',
                  options: ['Toast', 'Cereal with milk', 'Eggs', 'Pancakes'],
                  correctAnswer: 'Cereal with milk',
                  explanation:
                      'Emma says "For breakfast, I always eat cereal with milk and fresh fruit."',
                ),
                ListeningQuestion(
                  id: 'q2',
                  question: 'How often does Emma eat pizza?',
                  options: [
                    'Every day',
                    'Once a week',
                    'Once a month',
                    'Never'
                  ],
                  correctAnswer: 'Once a week',
                  explanation:
                      'Emma mentions "I usually eat pizza once a week."',
                ),
              ],
            ),
          ],
        ),

        // Intermediate Level - Short Stories
        ListeningLevel(
          id: 'intermediate_stories',
          title: 'Kısa Hikayeler',
          description:
              'İlginç kısa hikayeleri dinleyerek kelime dağarcığınızı genişletin',
          difficulty: ListeningDifficulty.intermediate,
          topic: ListeningTopic.stories,
          iconPath: 'assets/icons/stories.png',
          isUnlocked: true,
          isPremium: false,
          estimatedDuration: 25,
          learningObjectives: [
            'Hikaye akışını takip etme',
            'Karakter analizi',
            'Geçmiş zaman yapıları',
          ],
          stories: [
            ListeningStory(
              id: 'lost_cat',
              title: 'The Lost Cat',
              summary: 'Kayıp kediyi arayan bir ailenin hikayesi',
              content: '''
Last Tuesday, the Johnson family discovered that their cat, Whiskers, was missing. Whiskers was a beautiful orange cat with white paws and green eyes. The family had adopted him from the animal shelter two years ago.

Mrs. Johnson noticed that Whiskers wasn't in his usual sleeping spot on the sofa. She called his name, but he didn't come. The family searched everywhere in the house - under beds, in closets, behind furniture - but Whiskers was nowhere to be found.

They realized that someone must have left the front door open the night before. Whiskers had probably escaped during the night when everyone was sleeping.

The next morning, the whole family went outside to look for Whiskers. They walked around the neighborhood, calling his name and showing his picture to neighbors. Some people said they had seen an orange cat near the park, so the family went there immediately.

At the park, they met an elderly man who was feeding stray cats. He told them that he had seen Whiskers hiding under a bench near the pond. The family rushed to that area and found Whiskers, scared and hungry, but safe.

Whiskers was so happy to see his family that he purred loudly and rubbed against their legs. From that day on, the Johnson family always made sure to check that all doors and windows were properly closed before going to bed.
          ''',
              difficulty: ListeningDifficulty.intermediate,
              topic: ListeningTopic.stories,
              estimatedDuration: 4,
              keyVocabulary: [
                'discovered',
                'missing',
                'adopted',
                'animal shelter',
                'searched',
                'escaped',
                'neighborhood',
                'elderly',
                'stray cats',
                'purred'
              ],
              comprehensionQuestions: [
                ListeningQuestion(
                  id: 'q1',
                  question: 'What color was Whiskers?',
                  options: ['Black', 'Orange with white paws', 'Gray', 'Brown'],
                  correctAnswer: 'Orange with white paws',
                  explanation:
                      'The story describes Whiskers as "a beautiful orange cat with white paws and green eyes."',
                ),
                ListeningQuestion(
                  id: 'q2',
                  question: 'Where did the family find Whiskers?',
                  options: [
                    'In the house',
                    'At the park',
                    'At the shelter',
                    'In the street'
                  ],
                  correctAnswer: 'At the park',
                  explanation:
                      'They found Whiskers "hiding under a bench near the pond" at the park.',
                ),
                ListeningQuestion(
                  id: 'q3',
                  question: 'How long had the family owned Whiskers?',
                  options: [
                    'One year',
                    'Two years',
                    'Three years',
                    'Five years'
                  ],
                  correctAnswer: 'Two years',
                  explanation:
                      'The story mentions "The family had adopted him from the animal shelter two years ago."',
                ),
              ],
            ),
            ListeningStory(
              id: 'birthday_surprise',
              title: 'The Birthday Surprise',
              summary:
                  'Annesine sürpriz doğum günü partisi hazırlayan kızın hikayesi',
              content: '''
Lisa wanted to organize a surprise birthday party for her mother's 45th birthday. Her mother had always been very kind and helpful to everyone, and Lisa thought she deserved something special.

Lisa started planning the party three weeks before her mother's birthday. She secretly called all of her mother's friends and relatives to invite them. She asked everyone to keep the party a secret and to arrive at their house at 6 PM on Saturday.

For the decorations, Lisa chose her mother's favorite colors: purple and silver. She bought balloons, streamers, and a beautiful banner that said "Happy Birthday Mom!" She also ordered a chocolate cake from the best bakery in town because chocolate was her mother's favorite flavor.

On the day of the party, Lisa told her mother that they were going out for a quiet dinner. She asked her mother to dress nicely and be ready by 6 PM. Her mother was a little surprised but agreed.

When they arrived home, all the guests were hiding in the living room. As soon as Lisa's mother opened the door, everyone shouted "Surprise!" Her mother was so shocked that she started crying tears of joy.

The party was wonderful. Everyone shared funny stories about Lisa's mother, they played her favorite music, and they ate the delicious chocolate cake. Lisa's mother said it was the best birthday she had ever had.

Lisa felt very happy that she could make her mother so joyful. She realized that giving happiness to others was the best gift she could give herself.
          ''',
              difficulty: ListeningDifficulty.intermediate,
              topic: ListeningTopic.stories,
              estimatedDuration: 4,
              keyVocabulary: [
                'organize',
                'surprise party',
                'deserved',
                'secretly',
                'relatives',
                'decorations',
                'streamers',
                'banner',
                'bakery',
                'tears of joy'
              ],
              comprehensionQuestions: [
                ListeningQuestion(
                  id: 'q1',
                  question: 'How old was Lisa\'s mother turning?',
                  options: ['40', '43', '45', '50'],
                  correctAnswer: '45',
                  explanation:
                      'Lisa wanted to organize a party "for her mother\'s 45th birthday."',
                ),
                ListeningQuestion(
                  id: 'q2',
                  question: 'What were the decoration colors?',
                  options: [
                    'Pink and gold',
                    'Purple and silver',
                    'Blue and white',
                    'Red and green'
                  ],
                  correctAnswer: 'Purple and silver',
                  explanation:
                      'Lisa chose "her mother\'s favorite colors: purple and silver."',
                ),
              ],
            ),
          ],
        ),

        // Advanced Level - News and Current Events
        ListeningLevel(
          id: 'advanced_news',
          title: 'Haberler ve Güncel Olaylar',
          description:
              'Haber metinlerini dinleyerek ileri seviye anlama becerinizi geliştirin',
          difficulty: ListeningDifficulty.advanced,
          topic: ListeningTopic.news,
          iconPath: 'assets/icons/news.png',
          isUnlocked: true,
          isPremium: false,
          estimatedDuration: 30,
          learningObjectives: [
            'Haber dili anlama',
            'Karmaşık cümle yapıları',
            'Formal kelime dağarcığı',
          ],
          stories: [
            ListeningStory(
              id: 'renewable_energy',
              title: 'Renewable Energy Breakthrough',
              summary: 'Yenilenebilir enerji alanındaki son gelişmeler',
              content: '''
Scientists at the International Energy Research Institute have announced a significant breakthrough in renewable energy technology that could revolutionize how we generate and store clean energy.

The research team, led by Dr. Maria Rodriguez, has developed a new type of solar panel that is 40% more efficient than current models. These innovative panels use a revolutionary material called perovskite, which can capture a broader spectrum of sunlight and convert it into electricity more effectively.

"This technology represents a major step forward in our fight against climate change," Dr. Rodriguez explained during yesterday's press conference. "Not only are these panels more efficient, but they're also cheaper to produce and can be manufactured using existing facilities."

The breakthrough comes at a crucial time when governments worldwide are seeking sustainable alternatives to fossil fuels. According to the International Energy Agency, renewable energy sources must account for 90% of global electricity generation by 2050 to limit global warming to 1.5 degrees Celsius.

The new solar panels have already undergone extensive testing in various climate conditions. Results show that they maintain their efficiency even in low-light conditions and extreme temperatures. The research team expects commercial production to begin within the next two years.

Environmental groups have welcomed the announcement. Sarah Thompson, spokesperson for Green Future Alliance, stated, "This innovation could accelerate the transition to clean energy and help countries meet their carbon neutrality goals more quickly."

However, some experts remain cautious about the timeline for widespread adoption. Professor James Wilson from the Energy Policy Institute warns that infrastructure changes and regulatory approvals could delay implementation.

Despite these challenges, the scientific community is optimistic about the potential impact of this technology on global energy production and environmental protection.
          ''',
              difficulty: ListeningDifficulty.advanced,
              topic: ListeningTopic.news,
              estimatedDuration: 5,
              keyVocabulary: [
                'breakthrough',
                'revolutionize',
                'renewable energy',
                'perovskite',
                'spectrum',
                'sustainable',
                'fossil fuels',
                'carbon neutrality',
                'infrastructure',
                'regulatory approvals'
              ],
              comprehensionQuestions: [
                ListeningQuestion(
                  id: 'q1',
                  question: 'How much more efficient are the new solar panels?',
                  options: ['30%', '40%', '50%', '60%'],
                  correctAnswer: '40%',
                  explanation:
                      'The text states the panels are "40% more efficient than current models."',
                ),
                ListeningQuestion(
                  id: 'q2',
                  question: 'What material do the new panels use?',
                  options: ['Silicon', 'Perovskite', 'Graphene', 'Lithium'],
                  correctAnswer: 'Perovskite',
                  explanation:
                      'The panels use "a revolutionary material called perovskite."',
                ),
              ],
            ),
          ],
        ),

        // Business Level
        ListeningLevel(
          id: 'business_conversations',
          title: 'İş Konuşmaları',
          description:
              'İş dünyasından konuşmaları dinleyerek profesyonel İngilizce öğrenin',
          difficulty: ListeningDifficulty.intermediate,
          topic: ListeningTopic.business,
          iconPath: 'assets/icons/business.png',
          isUnlocked: true,
          isPremium: true,
          estimatedDuration: 20,
          learningObjectives: [
            'İş terminolojisi',
            'Toplantı dili',
            'Profesyonel iletişim',
          ],
          stories: [
            ListeningStory(
              id: 'job_interview',
              title: 'Job Interview',
              summary: 'Başarılı bir iş görüşmesi örneği',
              content: '''
Good morning, Ms. Chen. Thank you for coming in today. I'm David Miller, the Human Resources Manager here at TechSolutions Inc. Please, have a seat.

Thank you, Mr. Miller. I'm excited to be here and learn more about the Marketing Coordinator position.

Excellent. Let me start by telling you a bit about our company. TechSolutions has been developing software applications for small businesses for over ten years. We're currently expanding our marketing team to support our growth in the international market.

That sounds very interesting. I've researched your company extensively, and I'm impressed by your recent expansion into the European market. I believe my experience in digital marketing and my language skills could be valuable for your international campaigns.

That's great to hear. Can you tell me about your previous experience in marketing?

Certainly. For the past three years, I've worked as a Marketing Assistant at Digital Dynamics, where I managed social media campaigns and helped increase our online engagement by 150%. I also coordinated with international clients and translated marketing materials into Spanish and French.

Impressive results. What do you consider your greatest strength in marketing?

I think my ability to analyze data and translate it into actionable marketing strategies is my greatest strength. I'm also very detail-oriented and work well under pressure, which I believe is essential in a fast-paced marketing environment.

Those are exactly the qualities we're looking for. Now, where do you see yourself in five years?

I hope to have grown into a senior marketing role where I can lead campaigns and mentor junior team members. I'm particularly interested in developing expertise in international marketing strategies.

Excellent. Do you have any questions about the position or our company?

Yes, I'd like to know more about the team I'd be working with and what a typical day might look like in this role.

Great question. You'd be working closely with our Marketing Director and two other coordinators. Your daily tasks would include campaign planning, content creation, performance analysis, and client communication.

That sounds perfect for my skills and interests. When can I expect to hear back about your decision?

We'll be conducting interviews for the rest of this week and hope to make a decision by next Monday. We'll contact all candidates by email.

Thank you so much for your time today, Mr. Miller. I look forward to hearing from you.

Thank you, Ms. Chen. It was a pleasure meeting you.
          ''',
              difficulty: ListeningDifficulty.intermediate,
              topic: ListeningTopic.business,
              estimatedDuration: 5,
              keyVocabulary: [
                'Human Resources',
                'Marketing Coordinator',
                'expanding',
                'campaigns',
                'engagement',
                'actionable strategies',
                'detail-oriented',
                'mentor',
                'performance analysis',
                'client communication'
              ],
              comprehensionQuestions: [
                ListeningQuestion(
                  id: 'q1',
                  question: 'What position is Ms. Chen applying for?',
                  options: [
                    'Marketing Director',
                    'Marketing Coordinator',
                    'Marketing Assistant',
                    'HR Manager'
                  ],
                  correctAnswer: 'Marketing Coordinator',
                  explanation:
                      'Mr. Miller mentions "the Marketing Coordinator position."',
                ),
                ListeningQuestion(
                  id: 'q2',
                  question:
                      'By how much did Ms. Chen increase online engagement at her previous job?',
                  options: ['100%', '120%', '150%', '200%'],
                  correctAnswer: '150%',
                  explanation:
                      'Ms. Chen says she "helped increase our online engagement by 150%."',
                ),
              ],
            ),
          ],
        ),

        // Travel Level
        ListeningLevel(
          id: 'travel_adventures',
          title: 'Seyahat Maceraları',
          description:
              'Seyahat hikayelerini dinleyerek farklı kültürler hakkında bilgi edinin',
          difficulty: ListeningDifficulty.intermediate,
          topic: ListeningTopic.travel,
          iconPath: 'assets/icons/travel.png',
          isUnlocked: false,
          isPremium: true,
          estimatedDuration: 25,
          learningObjectives: [
            'Seyahat terminolojisi',
            'Kültürel ifadeler',
            'Coğrafi kelimeler',
          ],
          stories: [
            ListeningStory(
              id: 'tokyo_adventure',
              title: 'Adventure in Tokyo',
              summary: 'Tokyo\'da unutulmaz bir seyahat deneyimi',
              content: '''
Last spring, I had the opportunity to visit Tokyo for the first time. As someone who had always been fascinated by Japanese culture, I was incredibly excited about this trip.

I arrived at Narita Airport on a beautiful cherry blossom morning. The sight of sakura trees in full bloom was absolutely breathtaking. I took the train to Shibuya, where I had booked a small but comfortable hotel room.

My first stop was the famous Shibuya Crossing. Standing in the middle of that organized chaos, with thousands of people crossing in perfect harmony, was an unforgettable experience. I spent hours just watching the flow of humanity.

The next day, I visited the ancient Senso-ji Temple in Asakusa. The contrast between the traditional architecture and the modern skyscrapers in the background was striking. I participated in the traditional ritual of washing my hands and mouth before entering the temple.

One of the highlights of my trip was trying authentic Japanese cuisine. I visited a small ramen shop in a narrow alley where the chef prepared the most delicious tonkotsu ramen I had ever tasted. The rich, creamy broth and perfectly cooked noodles were a revelation.

I also spent a day in the electronics district of Akihabara, where I was amazed by the latest technology and gaming innovations. The multi-story electronics stores were like wonderlands for tech enthusiasts.

On my last evening, I climbed Tokyo Skytree just before sunset. The panoramic view of the city stretching endlessly in all directions was magnificent. As the sun set and the city lights began to twinkle, I felt a deep appreciation for the beauty and complexity of Tokyo.

This trip taught me that traveling is not just about seeing new places, but about opening your mind to different ways of life and finding beauty in unexpected moments.
          ''',
              difficulty: ListeningDifficulty.intermediate,
              topic: ListeningTopic.travel,
              estimatedDuration: 5,
              keyVocabulary: [
                'cherry blossom',
                'sakura',
                'organized chaos',
                'harmony',
                'ancient temple',
                'traditional architecture',
                'authentic cuisine',
                'tonkotsu ramen',
                'electronics district',
                'panoramic view'
              ],
              comprehensionQuestions: [
                ListeningQuestion(
                  id: 'q1',
                  question: 'Which airport did the traveler arrive at?',
                  options: ['Haneda', 'Narita', 'Kansai', 'Chitose'],
                  correctAnswer: 'Narita',
                  explanation:
                      'The text states "I arrived at Narita Airport on a beautiful cherry blossom morning."',
                ),
                ListeningQuestion(
                  id: 'q2',
                  question: 'What type of ramen did the traveler try?',
                  options: ['Miso', 'Shoyu', 'Tonkotsu', 'Shio'],
                  correctAnswer: 'Tonkotsu',
                  explanation:
                      'The traveler mentions "the most delicious tonkotsu ramen I had ever tasted."',
                ),
              ],
            ),
          ],
        ),
      ];

  /// Get level by ID
  static ListeningLevel? getLevelById(String id) {
    try {
      return levels.firstWhere((level) => level.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get story by ID
  static ListeningStory? getStoryById(String storyId) {
    for (final level in levels) {
      try {
        return level.stories.firstWhere((story) => story.id == storyId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Get stories by difficulty
  static List<ListeningStory> getStoriesByDifficulty(
      ListeningDifficulty difficulty) {
    final stories = <ListeningStory>[];
    for (final level in levels) {
      if (level.difficulty == difficulty) {
        stories.addAll(level.stories);
      }
    }
    return stories;
  }

  /// Get stories by topic
  static List<ListeningStory> getStoriesByTopic(ListeningTopic topic) {
    final stories = <ListeningStory>[];
    for (final level in levels) {
      if (level.topic == topic) {
        stories.addAll(level.stories);
      }
    }
    return stories;
  }
}
