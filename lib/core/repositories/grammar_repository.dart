import 'package:learn_english_app/core/data/grammar_data.dart';

import '../models/grammar_topic.dart';


class GrammarRepository {
  // In a real app, this would be connected to a database or API
  Future<List<GrammarTopic>> getGrammarTopics() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

List<GrammarTopic> _topics=GrammarData.topics;
    // Return dummy data for now
    return _topics;
  }

  Future<GrammarTopic> getGrammarTopic(String topicId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get all topics and find the matching one
    final topics = await getGrammarTopics();
    final topic = topics.firstWhere(
      (topic) => topic.id == topicId,
      orElse: () => throw Exception('Topic not found'),
    );

    return topic;
  }

  Future<GrammarSubtopic> getGrammarSubtopic(
      String topicId, String subtopicId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Get the topic and find the matching subtopic
    final topic = await getGrammarTopic(topicId);
    final subtopic = topic.subtopics.firstWhere(
      (subtopic) => subtopic.id == subtopicId,
      orElse: () => throw Exception('Subtopic not found'),
    );

    return subtopic;
  }
}
