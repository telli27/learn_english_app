import 'package:cloud_firestore/cloud_firestore.dart';

class TopicProgress {
  final String id;
  final String userId;
  final String topicId;
  final double progressPercentage;
  final int lastPosition; // Last scroll position or content index viewed
  final DateTime lastAccessed;

  TopicProgress({
    required this.id,
    required this.userId,
    required this.topicId,
    this.progressPercentage = 0.0,
    this.lastPosition = 0,
    required this.lastAccessed,
  });

  // Create from Firestore document
  factory TopicProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TopicProgress(
      id: doc.id,
      userId: data['userId'] ?? '',
      topicId: data['topicId'] ?? '',
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      lastPosition: data['lastPosition'] ?? 0,
      lastAccessed: (data['lastAccessed'] as Timestamp).toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'topicId': topicId,
      'progressPercentage': progressPercentage,
      'lastPosition': lastPosition,
      'lastAccessed': Timestamp.fromDate(lastAccessed),
    };
  }
}
