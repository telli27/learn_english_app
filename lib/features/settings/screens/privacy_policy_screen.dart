import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/utils/constants/colors.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    // Şimdiki zamanı alalım
    final now = DateTime.now();
    final aylar = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    final currentMonth = aylar[now.month - 1];
    final currentYear = now.year.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Sözleşmesi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Title
          Text(
            'Gizlilik Politikamız',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Last updated date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: isDark
                      ? AppColors.primary.withOpacity(0.8)
                      : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Son Güncelleme: $currentMonth $currentYear',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.primary.withOpacity(0.9)
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Introduction
          _buildSection(
            'Giriş',
            'Englitics uygulamasını kullanarak, gizliliğinizi ve kişisel verilerinizin nasıl işlendiğini önemsediğimizi belirtmek isteriz. Bu gizlilik politikası, topladığımız bilgileri, bu bilgileri nasıl kullandığımızı ve sizin haklarınızı açıklar.',
            isDark,
          ),

          _buildSection(
            'Topladığımız Bilgiler',
            'Uygulamamız, size daha iyi bir deneyim sunmak için aşağıdaki bilgileri toplayabilir:\n\n'
                '• Kullanım Verileri: Uygulama içindeki etkinlikleriniz, tamamladığınız alıştırmalar ve öğrenme performansınız\n'
                '• Cihaz Bilgileri: İşletim sistemi, cihaz türü ve benzeri teknik bilgiler',
            isDark,
          ),

          _buildSection(
            'Bilgilerin Kullanımı',
            'Topladığımız bilgileri şu amaçlarla kullanıyoruz:\n\n'
                '• Hizmetimizi sağlamak ve geliştirmek\n'
                '• Öğrenme deneyiminizi kişiselleştirmek\n'
                '• İlerlemenizi takip etmek ve size geri bildirim sağlamak\n'
                '• Teknik sorunları gidermek',
            isDark,
          ),

          _buildSection(
            'Değişiklikler',
            'Bu gizlilik politikasını zaman zaman güncelleyebiliriz. Önemli değişiklikler olduğunda sizi bilgilendireceğiz.',
            isDark,
          ),

          _buildSection(
            'İletişim',
            'Gizlilik politikamızla ilgili sorularınız veya endişeleriniz varsa, lütfen bizimle iletişime geçin.',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
