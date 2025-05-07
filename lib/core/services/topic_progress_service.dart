import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic_progress.dart';
import 'package:flutter/material.dart';

class TopicProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'topic_progress';

  // Fetch all progress for a user
  Future<List<TopicProgress>> getUserProgress(String userId) async {
    try {
      debugPrint('Fetching progress data for user: $userId');
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint('Found ${snapshot.docs.length} progress entries');
      return snapshot.docs
          .map((doc) => TopicProgress.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user progress: $e');
      return [];
    }
  }

  // Get progress for a specific topic
  Future<TopicProgress?> getTopicProgress(String userId, String topicId) async {
    try {
      debugPrint('Fetching progress for topic $topicId');
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('topicId', isEqualTo: topicId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('No progress found for topic $topicId');
        return null;
      }

      debugPrint('Found progress data for topic $topicId');
      return TopicProgress.fromFirestore(snapshot.docs.first);
    } catch (e) {
      debugPrint('Error fetching topic progress: $e');
      return null;
    }
  }

  // Update or create progress for a topic
  Future<bool> updateTopicProgress(String userId, String topicId,
      double progressPercentage, int lastPosition) async {
    try {
      debugPrint('Updating progress for topic $topicId: $progressPercentage%');

      // First, check if a document already exists
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('topicId', isEqualTo: topicId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // Create new progress document
        debugPrint('Creating new progress record for topic $topicId');

        // Create progress data
        final progressData = TopicProgress(
          id: '', // Will be set by Firestore
          userId: userId,
          topicId: topicId,
          progressPercentage: progressPercentage,
          lastPosition: lastPosition,
          lastAccessed: DateTime.now(),
        ).toFirestore();

        // Add timestamp and analytics data
        progressData['createdAt'] = Timestamp.now();
        progressData['updatedAt'] = Timestamp.now();
        progressData['deviceInfo'] = {
          'platform': 'mobile',
          'timezoneOffset': DateTime.now().timeZoneOffset.inMinutes,
        };

        await _firestore.collection(_collection).add(progressData);
        debugPrint('New progress record created successfully');
      } else {
        // Update existing document
        final docId = snapshot.docs.first.id;
        debugPrint('Updating existing progress record: $docId');

        await _firestore.collection(_collection).doc(docId).update({
          'progressPercentage': progressPercentage,
          'lastPosition': lastPosition,
          'lastAccessed': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
        debugPrint('Progress record updated successfully');
      }
      return true;
    } catch (e) {
      debugPrint('Error updating topic progress: $e');
      return false;
    }
  }
}
