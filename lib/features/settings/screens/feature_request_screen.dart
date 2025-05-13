import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/utils/constants/colors.dart';
import '../providers/feature_request_provider.dart';
import 'user_feature_requests_screen.dart';
import 'admin_feature_requests_screen.dart';

class FeatureRequestScreen extends ConsumerStatefulWidget {
  const FeatureRequestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeatureRequestScreen> createState() =>
      _FeatureRequestScreenState();
}

class _FeatureRequestScreenState extends ConsumerState<FeatureRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _featureController = TextEditingController();

  bool _isSubmitting = false;
  bool _submitted = false;
  String? _errorMessage;
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

  @override
  void dispose() {
    _featureController.dispose();
    super.dispose();
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(featureRequestServiceProvider);
      final success =
          await service.submitFeatureRequest(_featureController.text);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = success;
          if (!success) {
            _errorMessage =
                'Özellik isteği gönderilirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Özellik isteği gönderilirken bir hata oluştu: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final isAdminAsync = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Özellik İsteği'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Özellik İsteklerim',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserFeatureRequestsScreen(),
                ),
              );
            },
          ),
          if (isAdminAsync.maybeWhen(
            data: (isAdmin) {
              log("isAdmin ** * $isAdmin");
              return isAdmin;
            },
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
          /* PopupMenuButton(
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
          ),*/
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child:
                _submitted ? _buildSuccessView(isDark) : _buildFormView(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primary,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'Teşekkürler!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Özellik öneriniz başarıyla gönderildi. Öneriniz değerlendirme sürecine alınmıştır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _submitted = false;
                      _featureController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Yeni Öneri Gönder',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserFeatureRequestsScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                  child: const Text(
                    'İsteklerimi Gör',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Yeni Özellik Öner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Uygulamamızı geliştirmemize yardımcı olun. Görmek istediğiniz özellikleri bize bildirin.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Özellik İsteğiniz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _featureController,
                    decoration: InputDecoration(
                      hintText:
                          'Görmek istediğiniz özelliği ayrıntılı olarak açıklayın',
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    minLines: 5,
                    maxLines: 8,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen özellik isteğinizi açıklayın';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Gönder',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
