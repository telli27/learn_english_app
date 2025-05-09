import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

// ConnectivityService provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

// Connectivity state provider that tracks if the device has internet
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

// Simple provider to get the current connectivity status synchronously
final isConnectedProvider = Provider<bool>((ref) {
  // Try to get the last value from the stream provider
  final connectivityValue = ref.watch(connectivityProvider);

  // Return the value if available, otherwise get it directly from the service
  return connectivityValue.when(
    data: (isConnected) => isConnected,
    error: (_, __) => ref.watch(connectivityServiceProvider).isConnected,
    loading: () => ref.watch(connectivityServiceProvider).isConnected,
  );
});
