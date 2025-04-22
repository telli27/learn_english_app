import '../../../core/models/grammar_topic.dart';
import '../../../core/data/grammar_data.dart';

class GrammarRepository {
  // Fetch all grammar topics
  List<GrammarTopic> getGrammarTopics() {
    return GrammarData.topics;
  }

  // Get a specific grammar topic by ID
  GrammarTopic? getGrammarTopic(String topicId) {
    try {
      return GrammarData.topics.firstWhere(
        (topic) => topic.id == topicId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get a specific grammar subtopic by topic ID and subtopic ID
  GrammarSubtopic? getGrammarSubtopic(String topicId, String subtopicId) {
    try {
      final topic = getGrammarTopic(topicId);
      if (topic == null) return null;

      return topic.subtopics.firstWhere(
        (subtopic) => subtopic.id == subtopicId,
      );
    } catch (e) {
      return null;
    }
  }
}
