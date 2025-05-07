import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/utils/constants/colors.dart';
import 'privacy_policy_screen.dart';
import 'feature_request_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App settings section
          _buildSectionHeader(context, 'Uygulama Ayarları', isDark),
          _buildSettingCard(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Karanlık Mod',
            subtitle: 'Uygulama görünümünü değiştirin',
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(themeControllerProvider.notifier).toggleTheme();
              },
              activeColor: AppColors.primary,
            ),
            isDark: isDark,
            onTap: () {
              ref.read(themeControllerProvider.notifier).toggleTheme();
            },
          ),

          const SizedBox(height: 24),

          // Info section
          _buildSectionHeader(context, 'Bilgi', isDark),
          _buildSettingCard(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Gizlilik Sözleşmesi',
            subtitle: 'Gizlilik politikamızı görüntüleyin',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen()));
            },
          ),
          _buildSettingCard(
            context,
            icon: Icons.lightbulb_outline,
            title: 'Özellik İsteği',
            subtitle: 'Yeni özellik önerin',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeatureRequestScreen()));
            },
          ),
          /* _buildSettingCard(
            context,
            icon: Icons.info_outline,
            title: 'Uygulama Hakkında',
            subtitle: 'Sürüm: 1.0.0',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            isDark: isDark,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Englitics',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 32),
                applicationLegalese: '© 2024 Englitics',
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'İngilizce öğrenmeyi kolay ve eğlenceli hale getiren uygulama.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              );
            },
          ),*/
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.primary : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isDark,
    required VoidCallback onTap,
  }) {
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
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
