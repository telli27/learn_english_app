import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseAnswer {
  final String id;
  final String userId;
  final String topicId;
  final String subtopicId;
  final String exerciseId;
  final bool isCorrect;
  final DateTime completedAt;

  ExerciseAnswer({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.subtopicId,
    required this.exerciseId,
    required this.isCorrect,
    required this.completedAt,
  });

  // Create from Firestore document
  factory ExerciseAnswer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExerciseAnswer(
      id: doc.id,
      userId: data['userId'] ?? '',
      topicId: data['topicId'] ?? '',
      subtopicId: data['subtopicId'] ?? '',
      exerciseId: data['exerciseId'] ?? '',
      isCorrect: data['isCorrect'] ?? false,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'topicId': topicId,
      'subtopicId': subtopicId,
      'exerciseId': exerciseId,
      'isCorrect': isCorrect,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}
