import 'package:flutter/foundation.dart';

/// Listening difficulty levels
enum ListeningDifficulty {
  beginner,
  intermediate,
  advanced,
  native,
}

/// Listening topics
enum ListeningTopic {
  dailyLife,
  stories,
  news,
  conversations,
  education,
  business,
  travel,
  technology,
  health,
  entertainment,
}

/// Extension for topic display names
extension ListeningTopicExtension on ListeningTopic {
  String get displayName {
    switch (this) {
      case ListeningTopic.dailyLife:
        return 'Günlük Yaşam';
      case ListeningTopic.stories:
        return 'Hikayeler';
      case ListeningTopic.news:
        return 'Haberler';
      case ListeningTopic.conversations:
        return 'Konuşmalar';
      case ListeningTopic.education:
        return 'Eğitim';
      case ListeningTopic.business:
        return 'İş Hayatı';
      case ListeningTopic.travel:
        return 'Seyahat';
      case ListeningTopic.technology:
        return 'Teknoloji';
      case ListeningTopic.health:
        return 'Sağlık';
      case ListeningTopic.entertainment:
        return 'Eğlence';
    }
  }

  String get id {
    return name;
  }
}

/// Audio playback speeds
enum AudioSpeed {
  verySlow(0.2, '0.2x'),
  slow(0.4, '0.4x'),
  normal(0.6, '0.6x'),
  medium(0.8, '0.8x'),
  fast(1.0, '1.0x');

  const AudioSpeed(this.value, this.label);
  final double value;
  final String label;
}

/// Listening story model
class ListeningStory {
  final String id;
  final String title;
  final String content;
  final String summary;
  final ListeningDifficulty difficulty;
  final ListeningTopic topic;
  final int estimatedDuration; // in minutes
  final List<String> keyVocabulary;
  final List<ListeningQuestion> comprehensionQuestions;
  final String? imageUrl;

  const ListeningStory({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.difficulty,
    required this.topic,
    required this.estimatedDuration,
    this.keyVocabulary = const [],
    this.comprehensionQuestions = const [],
    this.imageUrl,
  });

  ListeningStory copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    ListeningDifficulty? difficulty,
    ListeningTopic? topic,
    int? estimatedDuration,
    List<String>? keyVocabulary,
    List<ListeningQuestion>? comprehensionQuestions,
    String? imageUrl,
  }) {
    return ListeningStory(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      difficulty: difficulty ?? this.difficulty,
      topic: topic ?? this.topic,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      keyVocabulary: keyVocabulary ?? this.keyVocabulary,
      comprehensionQuestions:
          comprehensionQuestions ?? this.comprehensionQuestions,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Listening question for comprehension
class ListeningQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const ListeningQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

/// Listening level containing multiple stories
class ListeningLevel {
  final String id;
  final String title;
  final String description;
  final ListeningDifficulty difficulty;
  final ListeningTopic topic;
  final List<ListeningStory> stories;
  final String iconPath;
  final bool isUnlocked;
  final bool isPremium;
  final int estimatedDuration; // in minutes
  final List<String> learningObjectives;

  const ListeningLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.topic,
    required this.stories,
    required this.iconPath,
    this.isUnlocked = false,
    this.isPremium = false,
    required this.estimatedDuration,
    this.learningObjectives = const [],
  });

  ListeningLevel copyWith({
    String? id,
    String? title,
    String? description,
    ListeningDifficulty? difficulty,
    ListeningTopic? topic,
    List<ListeningStory>? stories,
    String? iconPath,
    bool? isUnlocked,
    bool? isPremium,
    int? estimatedDuration,
    List<String>? learningObjectives,
  }) {
    return ListeningLevel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      topic: topic ?? this.topic,
      stories: stories ?? this.stories,
      iconPath: iconPath ?? this.iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isPremium: isPremium ?? this.isPremium,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      learningObjectives: learningObjectives ?? this.learningObjectives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListeningLevel &&
        other.id == id &&
        other.title == title &&
        other.difficulty == difficulty &&
        other.topic == topic;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ difficulty.hashCode ^ topic.hashCode;
  }
}

/// User's listening session
class ListeningSession {
  final String id;
  final String storyId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final AudioSpeed playbackSpeed;
  final int pauseCount;
  final int replayCount;
  final Duration totalListeningTime;
  final Map<String, String> questionAnswers;
  final int comprehensionScore;

  const ListeningSession({
    required this.id,
    required this.storyId,
    required this.startedAt,
    this.completedAt,
    this.isCompleted = false,
    this.playbackSpeed = AudioSpeed.normal,
    this.pauseCount = 0,
    this.replayCount = 0,
    this.totalListeningTime = Duration.zero,
    this.questionAnswers = const {},
    this.comprehensionScore = 0,
  });

  ListeningSession copyWith({
    String? id,
    String? storyId,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isCompleted,
    AudioSpeed? playbackSpeed,
    int? pauseCount,
    int? replayCount,
    Duration? totalListeningTime,
    Map<String, String>? questionAnswers,
    int? comprehensionScore,
  }) {
    return ListeningSession(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      pauseCount: pauseCount ?? this.pauseCount,
      replayCount: replayCount ?? this.replayCount,
      totalListeningTime: totalListeningTime ?? this.totalListeningTime,
      questionAnswers: questionAnswers ?? this.questionAnswers,
      comprehensionScore: comprehensionScore ?? this.comprehensionScore,
    );
  }
}

/// User's overall listening progress
class ListeningProgress {
  final String userId;
  final Map<ListeningTopic, int> topicProgress;
  final Map<ListeningDifficulty, int> difficultyProgress;
  final int totalStoriesCompleted;
  final double averageComprehensionScore;
  final Duration totalListeningTime;
  final DateTime? lastPracticeDate;
  final List<String> completedStoryIds;
  final AudioSpeed preferredSpeed;

  const ListeningProgress({
    required this.userId,
    this.topicProgress = const {},
    this.difficultyProgress = const {},
    this.totalStoriesCompleted = 0,
    this.averageComprehensionScore = 0.0,
    this.totalListeningTime = Duration.zero,
    this.lastPracticeDate,
    this.completedStoryIds = const [],
    this.preferredSpeed = AudioSpeed.normal,
  });

  ListeningProgress copyWith({
    String? userId,
    Map<ListeningTopic, int>? topicProgress,
    Map<ListeningDifficulty, int>? difficultyProgress,
    int? totalStoriesCompleted,
    double? averageComprehensionScore,
    Duration? totalListeningTime,
    DateTime? lastPracticeDate,
    List<String>? completedStoryIds,
    AudioSpeed? preferredSpeed,
  }) {
    return ListeningProgress(
      userId: userId ?? this.userId,
      topicProgress: topicProgress ?? this.topicProgress,
      difficultyProgress: difficultyProgress ?? this.difficultyProgress,
      totalStoriesCompleted:
          totalStoriesCompleted ?? this.totalStoriesCompleted,
      averageComprehensionScore:
          averageComprehensionScore ?? this.averageComprehensionScore,
      totalListeningTime: totalListeningTime ?? this.totalListeningTime,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      completedStoryIds: completedStoryIds ?? this.completedStoryIds,
      preferredSpeed: preferredSpeed ?? this.preferredSpeed,
    );
  }
}
