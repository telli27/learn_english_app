import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feature_request.dart';
import '../services/feature_request_service.dart';

// Feature request service provider
final featureRequestServiceProvider = Provider<FeatureRequestService>((ref) {
  return FeatureRequestService();
});

// Admin check provider
final isAdminProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(featureRequestServiceProvider);
  // Force a refresh of the current user data before checking admin status
  await service.refreshUserData();
  return await service.isCurrentUserAdmin();
});

// Stream of all feature requests (for admins)
final allFeatureRequestsProvider = StreamProvider<List<FeatureRequest>>((ref) {
  final service = ref.watch(featureRequestServiceProvider);
  return service.getAllFeatureRequests();
});

// Stream of user's feature requests
final userFeatureRequestsProvider = StreamProvider<List<FeatureRequest>>((ref) {
  final service = ref.watch(featureRequestServiceProvider);
  return service.getUserFeatureRequests();
});

// Provider for currently selected feature request (for editing)
final selectedFeatureRequestProvider =
    StateProvider<FeatureRequest?>((ref) => null);

// Feature request status update provider
final updateFeatureRequestStatusProvider =
    FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(featureRequestServiceProvider);
  final requestId = params['requestId'] as String;
  final newStatus = params['status'] as FeatureRequestStatus;
  final adminNotes = params['adminNotes'] as String?;

  return await service.updateFeatureRequestStatus(requestId, newStatus,
      adminNotes: adminNotes);
});
