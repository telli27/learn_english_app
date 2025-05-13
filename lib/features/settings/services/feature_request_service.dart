import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/feature_request.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeatureRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference - koleksiyon ismi doğru mu kontrol et
  final String _collectionName = 'ozellikIstekleri';
  CollectionReference get _featureRequestsCollection =>
      _firestore.collection(_collectionName);

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Initialize with auth state listener
  FeatureRequestService() {
    // Listen for auth changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint('FeatureRequestService - User authenticated: ${user.uid}');
        // Refresh the token if needed to ensure security rules are evaluated with latest auth state
        _refreshIdToken();
      } else {
        debugPrint('FeatureRequestService - User signed out');
      }
    });

    // Listen for token changes
    _auth.idTokenChanges().listen((User? user) {
      if (user != null) {
        debugPrint(
            'FeatureRequestService - ID token refreshed for user: ${user.uid}');
      }
    });
  }

  // Refresh the Firebase ID token to ensure current permissions
  Future<void> _refreshIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Force token refresh
        await user.getIdToken(true);
        debugPrint('FeatureRequestService - ID token refreshed successfully');
      }
    } catch (e) {
      debugPrint('FeatureRequestService - Error refreshing ID token: $e');
    }
  }

  // Force auth status check before performing Firestore operations
  Future<bool> _checkAuthBeforeOperation() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        debugPrint('FeatureRequestService - No user is signed in');
        return false;
      }

      // Reload user to get the latest authentication state
      await user.reload();

      // Check if user is still signed in after reload
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('FeatureRequestService - User session expired after reload');
        return false;
      }

      // Refresh the token
      await _refreshIdToken();

      return true;
    } catch (e) {
      debugPrint('FeatureRequestService - Auth check error: $e');
      return false;
    }
  }

  // Debug: Check collections
  Future<void> debugCheckCollections() async {
    try {
      // Check auth status before operation
      final authValid = await _checkAuthBeforeOperation();
      if (!authValid) {
        debugPrint(
            'FeatureRequestService - Auth check failed before checking collections');
        return;
      }

      // Mevcut koleksiyonu kontrol et
      final testQuery =
          await _firestore.collection(_collectionName).limit(1).get();
      debugPrint(
          'Collection $_collectionName exists, document count in sample: ${testQuery.docs.length}');

      // Kullanıcı koleksiyonunu kontrol et
      final userQuery = await _firestore.collection('users').limit(1).get();
      debugPrint(
          'Collection users exists, document count in sample: ${userQuery.docs.length}');

      // Is user admin
      if (currentUserId != null) {
        final userDoc =
            await _firestore.collection('users').doc(currentUserId).get();
        final isAdmin = userDoc.exists &&
            (userDoc.data() as Map<String, dynamic>)['isAdmin'] == true;
        debugPrint('Current user is admin: $isAdmin');
      }
    } catch (e) {
      debugPrint('Error checking collections: $e');
    }
  }

  // Debug: Create a test feature request
  Future<bool> createTestFeatureRequest() async {
    if (currentUserId == null) return false;

    try {
      // Check auth status before operation
      final authValid = await _checkAuthBeforeOperation();
      if (!authValid) {
        debugPrint(
            'FeatureRequestService - Auth check failed before creating test request');
        return false;
      }

      // Get user information
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (!userDoc.exists) {
        // If user document doesn't exist, create a test document with minimal data
        await _firestore.collection(_collectionName).add({
          'userId': currentUserId,
          'username': 'Test User',
          'requestText': 'Test feature request - ${DateTime.now()}',
          'status': 'inceleniyor',
          'createdAt': Timestamp.now(),
          'updatedAt': null,
          'adminNotes': null,
        });
      } else {
        final userData = userDoc.data() as Map<String, dynamic>;
        final username = userData['username'] ?? 'Test User';

        await _firestore.collection(_collectionName).add({
          'userId': currentUserId,
          'username': username,
          'requestText': 'Test feature request - ${DateTime.now()}',
          'status': 'inceleniyor',
          'createdAt': Timestamp.now(),
          'updatedAt': null,
          'adminNotes': null,
        });
      }

      debugPrint('Test feature request created successfully');
      return true;
    } catch (e) {
      debugPrint('Error creating test feature request: $e');
      return false;
    }
  }

  // Refresh user data to ensure we have the latest information
  Future<void> refreshUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Reload the user to get fresh data
        await user.reload();
        // Refresh the token
        await _refreshIdToken();
        debugPrint('FeatureRequestService - User data refreshed successfully');
      } else {
        debugPrint('FeatureRequestService - No user to refresh');
      }
    } catch (e) {
      debugPrint('FeatureRequestService - Error refreshing user data: $e');
    }
  }

  // Check if user is admin
  Future<bool> isCurrentUserAdmin() async {
    if (_auth.currentUser?.uid == null) return false;

    try {
      // Refresh user data first to ensure we get the latest information
      await refreshUserData();

      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .get();
      final isAdmin = userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>)['isAdmin'] == true;

      debugPrint('Current user admin status: $isAdmin');
      return isAdmin;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  // Submit a new feature request
  Future<bool> submitFeatureRequest(String requestText) async {
    if (currentUserId == null) return false;

    try {
      // Check auth status before operation
      final authValid = await _checkAuthBeforeOperation();
      if (!authValid) {
        debugPrint(
            'FeatureRequestService - Auth check failed before submitting request');
        return false;
      }

      // Get user information
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      String username = 'Kullanıcı';

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        username = userData['username'] ?? 'Kullanıcı';
      } else {
        debugPrint(
            'Warning: User document not found when submitting feature request');
      }

      // Create the feature request
      debugPrint('Submitting feature request to collection: $_collectionName');

      final docRef = await _firestore.collection(_collectionName).add({
        'userId': currentUserId,
        'username': username,
        'requestText': requestText,
        'status': FeatureRequestStatus.inceleniyor.name,
        'createdAt': Timestamp.now(),
        'updatedAt': null,
        'adminNotes': null,
      });

      debugPrint('Feature request added with ID: ${docRef.id}');
      return true;
    } catch (e) {
      debugPrint('Error submitting feature request: $e');
      return false;
    }
  }

  // Get all feature requests for admin
  Stream<List<FeatureRequest>> getAllFeatureRequests() {
    debugPrint(
        'Getting all feature requests from collection: $_collectionName');

    // First check auth
    _checkAuthBeforeOperation().then((authValid) {
      if (!authValid) {
        debugPrint(
            'FeatureRequestService - Auth check failed before getting all requests');
      }
    });

    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      debugPrint(
          'Feature requests snapshot received: ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        debugPrint('No feature requests found in collection: $_collectionName');
      }

      final requests = snapshot.docs
          .map((doc) {
            try {
              return FeatureRequest.fromFirestore(doc);
            } catch (e) {
              debugPrint('Error parsing document ${doc.id}: $e');
              return null;
            }
          })
          .where((req) => req != null)
          .cast<FeatureRequest>()
          .toList();

      // Sort by createdAt in descending order
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('Returning ${requests.length} feature requests');
      return requests;
    });
  }

  // Get feature requests for current user
  Stream<List<FeatureRequest>> getUserFeatureRequests() {
    if (currentUserId == null) {
      debugPrint('Cannot get user feature requests: currentUserId is null');
      return Stream.value([]);
    }

    debugPrint(
        'Getting feature requests for user: $currentUserId from collection: $_collectionName');

    // First check auth
    _checkAuthBeforeOperation().then((authValid) {
      if (!authValid) {
        debugPrint(
            'FeatureRequestService - Auth check failed before getting user requests');
      }
    });

    // Modified to avoid composite index requirement
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      debugPrint(
          'User feature requests snapshot received: ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        debugPrint('No feature requests found for user: $currentUserId');
      }

      // Sort in memory instead of in the query
      final requests = snapshot.docs
          .map((doc) {
            try {
              return FeatureRequest.fromFirestore(doc);
            } catch (e) {
              debugPrint('Error parsing document ${doc.id}: $e');
              return null;
            }
          })
          .where((req) => req != null)
          .cast<FeatureRequest>()
          .toList();

      // Sort by createdAt in descending order
      if (requests.isNotEmpty) {
        requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      debugPrint(
          'Returning ${requests.length} feature requests for user: $currentUserId');
      return requests;
    });
  }

  // Update feature request status (admin only)
  Future<bool> updateFeatureRequestStatus(
      String requestId, FeatureRequestStatus newStatus,
      {String? adminNotes}) async {
    try {
      // Check auth status before operation
      final authValid = await _checkAuthBeforeOperation();
      if (!authValid) {
        debugPrint(
            'FeatureRequestService - Auth check failed before updating request status');
        return false;
      }

      // Check if user is admin
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) return false;

      // Update the feature request
      await _firestore.collection(_collectionName).doc(requestId).update({
        'status': newStatus.name,
        'updatedAt': Timestamp.now(),
        if (adminNotes != null) 'adminNotes': adminNotes,
      });

      return true;
    } catch (e) {
      debugPrint('Error updating feature request: $e');
      return false;
    }
  }

  // Delete feature request (admin only)
  Future<bool> deleteFeatureRequest(String requestId) async {
    try {
      // Check auth status before operation
      final authValid = await _checkAuthBeforeOperation();
      if (!authValid) {
        debugPrint(
            'FeatureRequestService - Auth check failed before deleting request');
        return false;
      }

      // Check if user is admin
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) return false;

      // Delete the feature request
      await _firestore.collection(_collectionName).doc(requestId).delete();

      return true;
    } catch (e) {
      debugPrint('Error deleting feature request: $e');
      return false;
    }
  }

  // Debug: Create sample feature requests (for testing)
  Future<bool> createSampleFeatureRequests() async {
    if (currentUserId == null) return false;

    try {
      // Check auth status before operation
      final authValid = await _checkAuthBeforeOperation();
      if (!authValid) {
        debugPrint(
            'FeatureRequestService - Auth check failed before creating sample requests');
        return false;
      }

      // Sample feature requests
      final sampleRequests = [
        {
          'userId': currentUserId,
          'username': 'Test User',
          'requestText': 'Daha fazla dinleme alıştırması ekleyin lütfen.',
          'status': 'inceleniyor',
          'createdAt': Timestamp.fromDate(DateTime.parse('2024-10-15')),
          'updatedAt': null,
          'adminNotes': null,
        },
        {
          'userId': currentUserId,
          'username': 'Test User',
          'requestText': 'Uygulama içi sözlük özelliği olmalı.',
          'status': 'onaylandi',
          'createdAt': Timestamp.fromDate(DateTime.parse('2024-10-10')),
          'updatedAt': Timestamp.now(),
          'adminNotes': 'Bu özellik V2.0 sürümünde eklenecektir.',
        },
        {
          'userId': currentUserId,
          'username': 'Test User',
          'requestText': 'İngilizce dil seviyesi testi ekleyin.',
          'status': 'tamamlandi',
          'createdAt': Timestamp.fromDate(DateTime.parse('2024-09-28')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2024-10-12')),
          'adminNotes': 'Özellik eklendi ve aktif.',
        },
        {
          'userId': currentUserId,
          'username': 'Test User',
          'requestText': 'Daha fazla günlük konuşma kalıpları ekleyin.',
          'status': 'inceleniyor',
          'createdAt': Timestamp.fromDate(DateTime.parse('2024-10-05')),
          'updatedAt': null,
          'adminNotes': null,
        },
        {
          'userId': currentUserId,
          'username': 'Test User',
          'requestText': 'Kullanıcılar arası sohbet özelliği ekleyin.',
          'status': 'reddedildi',
          'createdAt': Timestamp.fromDate(DateTime.parse('2024-09-20')),
          'updatedAt': Timestamp.fromDate(DateTime.parse('2024-09-25')),
          'adminNotes':
              'Bu özellik uygulamamızın amacı dışında olduğu için şu an için planlanmamaktadır.',
        },
      ];

      // Add sample requests to Firestore
      for (final request in sampleRequests) {
        await _firestore.collection(_collectionName).add(request);
      }

      debugPrint('Örnek özellik istekleri başarıyla oluşturuldu');
      return true;
    } catch (e) {
      debugPrint('Örnek özellik istekleri oluşturulurken hata: $e');
      return false;
    }
  }
}
