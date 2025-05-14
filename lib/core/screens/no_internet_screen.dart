import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../data/grammar_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoInternetScreen extends ConsumerStatefulWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen> {
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if connectivity status changed to connected
    final connectivityStatus = ref.watch(connectivityProvider);
    connectivityStatus.whenData((isConnected) {
      if (isConnected && !_isLoading) {
        _reloadContentOnReconnect();
      }
    });
  }

  // This method reloads content when internet connection is restored
  Future<void> _reloadContentOnReconnect() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if we have content in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final hasGrammarData = prefs.containsKey('grammar_data_json');

      // If no data in SharedPreferences, force reload from GitHub
      if (!hasGrammarData) {
        await GrammarData.loadTopics();
      }
    } catch (e) {
      debugPrint('Error reloading content: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the connectivity stream to rebuild when connection status changes
    final connectivityStatus = ref.watch(connectivityProvider);

    return Scaffold(
      body: connectivityStatus.when(
        data: (isConnected) {
          // If connection is restored, this will rebuild but app
          // should navigate away from this screen in parent widget
          return _buildNoInternetUI(context, isConnected);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildNoInternetUI(context, false),
      ),
    );
  }

  Widget _buildNoInternetUI(BuildContext context, bool isConnected) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF5467FF),
            const Color(0xFF7B4EFF),
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

              // No internet illustration placeholder
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'İnternet Bağlantısı Yok',
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
                  'Uygulama için internet bağlantısına ihtiyaç vardır. Bağlantınızı kontrol edip tekrar deneyin.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Retry button - only show if not already reconnected
              if (!isConnected) _buildRetryButton(context),

              // Loading indicator
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(color: Colors.white),
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
                    : Colors.transparent,
                child: isConnected
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Bağlantı kuruldu! Yönlendiriliyorsunuz...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // Manually trigger a refresh of the connectivity provider
        ref.invalidate(connectivityProvider);

        // Force reload content from GitHub
        if (!_isLoading) {
          setState(() {
            _isLoading = true;
          });

          try {
            // Check if we have content in SharedPreferences
            final prefs = await SharedPreferences.getInstance();

            // Clear grammar data
            await prefs.remove('grammar_data_json');
            await prefs.remove('grammar_version_json');

            // Force reload from GitHub
            await GrammarData.loadTopics();
          } catch (e) {
            debugPrint('Error reloading content: $e');
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        }
      },
      icon: Icon(Icons.refresh, color: Colors.indigo.shade800),
      label: Text(
        'Tekrar Dene',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.indigo.shade800,
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
    );
  }
}
