import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';

class WeakConnectionScreen extends ConsumerWidget {
  final VoidCallback onRetry;

  const WeakConnectionScreen({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the connectivity stream to rebuild when connection status changes
    final connectivityStatus = ref.watch(connectivityProvider);

    return Scaffold(
      body: connectivityStatus.when(
        data: (isConnected) {
          // Even if we're connected, we still show this screen until onRetry is called
          // by the parent widget
          return _buildWeakConnectionUI(context, isConnected);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildWeakConnectionUI(context, false),
      ),
    );
  }

  Widget _buildWeakConnectionUI(BuildContext context, bool isConnected) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFA726), // Orange
            const Color(0xFFFF7043), // Deep Orange
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Space at the top
              const Spacer(flex: 1),

              // Weak connection illustration
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.wifi,
                        color: Colors.white.withOpacity(0.5),
                        size: 100,
                      ),
                      Positioned(
                        right: 50,
                        bottom: 50,
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'Zayıf İnternet Bağlantısı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'İnternet bağlantınız zayıf görünüyor. Konular yüklenirken sorun yaşanabilir.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Retry button
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, color: Colors.deepOrange.shade800),
                label: Text(
                  'Tekrar Dene',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black38,
                ),
              ),

              const SizedBox(height: 20),

              // Continue anyway button
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Yine de Devam Et',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),

              // Space at the bottom
              const Spacer(flex: 2),

              // Connection status indicator
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                color: isConnected
                    ? Colors.green.withOpacity(0.8)
                    : Colors.red.withOpacity(0.8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isConnected ? Icons.wifi : Icons.wifi_off,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isConnected
                          ? 'Bağlantı var, ancak zayıf olabilir'
                          : 'Bağlantı yok',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
