import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/utils/constants/colors.dart';
import '../providers/feature_request_provider.dart';
import '../models/feature_request.dart';
import 'package:intl/intl.dart';
import 'admin_feature_requests_screen.dart';

class UserFeatureRequestsScreen extends ConsumerStatefulWidget {
  const UserFeatureRequestsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserFeatureRequestsScreen> createState() =>
      _UserFeatureRequestsScreenState();
}

class _UserFeatureRequestsScreenState
    extends ConsumerState<UserFeatureRequestsScreen> {
  String? _debugMessage;

  @override
  void initState() {
    super.initState();
    // Schedule a refresh of the isAdmin status after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will force the isAdminProvider to refresh
      ref.refresh(isAdminProvider);
    });
  }

  Future<void> _debugCheckCollections() async {
    setState(() {
      _debugMessage = "Koleksiyonlar kontrol ediliyor...";
    });

    try {
      final service = ref.read(featureRequestServiceProvider);
      await service.debugCheckCollections();

      setState(() {
        _debugMessage =
            "Debug log'ları konsola yazdırıldı. Lütfen konsolu kontrol edin.";
      });

      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _debugMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _debugMessage = "Hata: $e";
      });
    }
  }

  Future<void> _createTestFeatureRequest() async {
    setState(() {
      _debugMessage = "Test özellik isteği oluşturuluyor...";
    });

    try {
      final service = ref.read(featureRequestServiceProvider);
      final result = await service.createTestFeatureRequest();

      setState(() {
        if (result) {
          _debugMessage = "Test özellik isteği başarıyla oluşturuldu.";
        } else {
          _debugMessage = "Test özellik isteği oluşturulamadı.";
        }
      });

      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _debugMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _debugMessage = "Hata: $e";
      });
    }
  }

  Future<void> _createSampleFeatureRequests() async {
    setState(() {
      _debugMessage = "Örnek özellik istekleri oluşturuluyor...";
    });

    try {
      final service = ref.read(featureRequestServiceProvider);
      final result = await service.createSampleFeatureRequests();

      setState(() {
        if (result) {
          _debugMessage = "Örnek özellik istekleri başarıyla oluşturuldu.";
          // Yeni istekleri görmek için listeyi yenile
          ref.refresh(userFeatureRequestsProvider);
        } else {
          _debugMessage = "Örnek özellik istekleri oluşturulamadı.";
        }
      });

      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _debugMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _debugMessage = "Hata: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final requestsAsyncValue = ref.watch(userFeatureRequestsProvider);
    final service = ref.read(featureRequestServiceProvider);
    final currentUserId = service.currentUserId;
    final isAdminAsync = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Özellik İsteklerim'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Admin ise yönetim ekranı butonu
          if (isAdminAsync.maybeWhen(
            data: (isAdmin) => isAdmin,
            orElse: () => false,
          ))
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Özellik İstekleri Yönetimi',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminFeatureRequestsScreen(),
                  ),
                );
              },
            ),

          // Debug menüsü
          PopupMenuButton(
            icon: Icon(Icons.bug_report),
            tooltip: 'Debug',
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Koleksiyonları Kontrol Et'),
                onTap: () => Future.delayed(
                  Duration(seconds: 0),
                  () => _debugCheckCollections(),
                ),
              ),
              PopupMenuItem(
                child: Text('Test İsteği Oluştur'),
                onTap: () => Future.delayed(
                  Duration(seconds: 0),
                  () => _createTestFeatureRequest(),
                ),
              ),
              PopupMenuItem(
                child: Text('Örnek İstekler Oluştur'),
                onTap: () => Future.delayed(
                  Duration(seconds: 0),
                  () => _createSampleFeatureRequests(),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Kullanıcı bilgisi
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            color: Colors.grey.withOpacity(0.1),
            child: Center(
              child: Text(
                'Kullanıcı ID: ${currentUserId ?? 'Giriş yapılmamış'}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ),

          // Debug mesajı (varsa)
          if (_debugMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              color: Colors.blue.withOpacity(0.2),
              child: Text(
                _debugMessage!,
                style: TextStyle(color: Colors.blue[800]),
                textAlign: TextAlign.center,
              ),
            ),

          // Ana içerik
          Expanded(
            child: requestsAsyncValue.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return _buildEmptyState(context, isDark);
                }
                return _buildRequestsList(context, requests, isDark);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bir hata oluştu:',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$error',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.refresh(userFeatureRequestsProvider);
                        },
                        child: Text('Yeniden Dene'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 70,
            color:
                isDark ? Colors.white.withOpacity(0.5) : Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Henüz özellik isteği göndermediniz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? Colors.white.withOpacity(0.7) : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Yeni bir özellik önermek için geri dönün',
            style: TextStyle(
              fontSize: 16,
              color:
                  isDark ? Colors.white.withOpacity(0.5) : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Yeni Özellik İsteği',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(
      BuildContext context, List<FeatureRequest> requests, bool isDark) {
    final dateFormatter = DateFormat('dd.MM.yyyy');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        Color statusColor;

        // Set status color based on status
        switch (request.status) {
          case FeatureRequestStatus.onaylandi:
            statusColor = Colors.blue;
            break;
          case FeatureRequestStatus.gelistiriliyor:
            statusColor = Colors.deepPurple;
            break;
          case FeatureRequestStatus.tamamlandi:
            statusColor = Colors.green;
            break;
          case FeatureRequestStatus.reddedildi:
            statusColor = Colors.red;
            break;
          case FeatureRequestStatus.inceleniyor:
          default:
            statusColor = Colors.orange;
            break;
        }

        return Card(
          elevation: 0,
          color: isDark ? const Color(0xFF242424) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Request Text
                Text(
                  request.requestText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Dates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tarih: ${dateFormatter.format(request.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.grey.shade600,
                      ),
                    ),
                    if (request.updatedAt != null)
                      Text(
                        'Güncelleme: ${dateFormatter.format(request.updatedAt!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),

                // Admin Notes
                if (request.adminNotes != null &&
                    request.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Notu:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.adminNotes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withOpacity(0.7)
                                : Colors.black87.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
