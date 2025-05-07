import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/models/exercise_answer.dart';

class ExerciseAnswerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'exercise_answers';

  // Create or update exercise answer
  Future<String> saveExerciseAnswer({
    required String userId,
    required String topicId,
    required String subtopicId,
    required String exerciseId,
    required bool isCorrect,
  }) async {
    try {
      // Check if answer already exists
      final existingAnswers = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('topicId', isEqualTo: topicId)
          .where('subtopicId', isEqualTo: subtopicId)
          .where('exerciseId', isEqualTo: exerciseId)
          .get();

      // If answer exists, update it
      if (existingAnswers.docs.isNotEmpty) {
        final docId = existingAnswers.docs.first.id;
        await _firestore.collection(_collectionName).doc(docId).update({
          'isCorrect': isCorrect,
          'completedAt': Timestamp.now(),
        });
        return docId;
      }

      // Otherwise, create a new answer document
      final docRef = await _firestore.collection(_collectionName).add({
        'userId': userId,
        'topicId': topicId,
        'subtopicId': subtopicId,
        'exerciseId': exerciseId,
        'isCorrect': isCorrect,
        'completedAt': Timestamp.now(),
      });

      return docRef.id;
    } catch (e) {
      debugPrint('Error saving exercise answer: $e');
      throw Exception('Failed to save exercise answer: ${e.toString()}');
    }
  }

  // Get all exercise answers for a user
  Future<List<ExerciseAnswer>> getUserExerciseAnswers(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnswer.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user exercise answers: $e');
      throw Exception('Failed to fetch exercise answers: ${e.toString()}');
    }
  }

  // Get all correct exercise answers for a user
  Future<List<ExerciseAnswer>> getUserCorrectExerciseAnswers(
      String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isCorrect', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnswer.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user correct exercise answers: $e');
      throw Exception(
          'Failed to fetch correct exercise answers: ${e.toString()}');
    }
  }

  // Get all exercise answers for a specific topic and subtopic
  Future<List<ExerciseAnswer>> getTopicExerciseAnswers(
      String userId, String topicId, String subtopicId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('topicId', isEqualTo: topicId)
          .where('subtopicId', isEqualTo: subtopicId)
          .get();

      return querySnapshot.docs
          .map((doc) => ExerciseAnswer.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching topic exercise answers: $e');
      throw Exception(
          'Failed to fetch topic exercise answers: ${e.toString()}');
    }
  }

  // Get all exercise IDs that user has completed correctly
  Future<List<String>> getUserCorrectExerciseIds(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isCorrect', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['exerciseId'] as String)
          .toList();
    } catch (e) {
      debugPrint('Error fetching user correct exercise IDs: $e');
      throw Exception('Failed to fetch correct exercise IDs: ${e.toString()}');
    }
  }
}
