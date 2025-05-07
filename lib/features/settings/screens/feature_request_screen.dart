import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/utils/constants/colors.dart';

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

  @override
  void dispose() {
    _featureController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulating API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Özellik İsteği'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _submitted ? _buildSuccessView(isDark) : _buildFormView(isDark),
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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _submitted = false;
                  _featureController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Yeni Öneri Gönder',
                style: TextStyle(fontSize: 16),
              ),
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
