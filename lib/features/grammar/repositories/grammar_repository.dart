import '../../../core/models/grammar_topic.dart';
import '../../../core/data/grammar_data.dart';

class GrammarRepository {
  List<GrammarTopic> getGrammarTopics() {
    return GrammarData.topics.where((topic) {
      return topic.title.trim().isNotEmpty &&
          topic.description.trim().isNotEmpty;
    }).toList();
  }

  GrammarTopic? getGrammarTopic(String topicId) {
    try {
      return GrammarData.topics.firstWhere(
        (topic) => topic.id == topicId,
      );
    } catch (e) {
      return null;
    }
  }

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
