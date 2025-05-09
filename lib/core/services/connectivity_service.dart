import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  // Create a stream controller to broadcast connectivity status
  final _connectivityStream = StreamController<bool>.broadcast();

  // Getter to expose the connectivity stream
  Stream<bool> get connectivityStream => _connectivityStream.stream;

  // Connectivity plugin instance
  final Connectivity _connectivity = Connectivity();

  // Initial status
  bool _isConnected = true;

  // Constructor starts listening to connectivity changes
  ConnectivityService() {
    _initConnectivity();
    _setupConnectivityListener();
  }

  // Check initial connectivity
  Future<void> _initConnectivity() async {
    try {
      ConnectivityResult result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      if (kDebugMode) {
        print("Connectivity initialization error: $e");
      }
      // Default to no connection if there's an error
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }

  // Set up a listener for future connectivity changes
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  // Process connectivity result and update stream
  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected = result != ConnectivityResult.none;
    _connectivityStream.add(_isConnected);
  }

  // Current connectivity status
  bool get isConnected => _isConnected;

  // Clean up resources when done
  void dispose() {
    _connectivityStream.close();
  }
}
