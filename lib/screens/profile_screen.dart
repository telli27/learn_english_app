import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../core/providers.dart';
import '../utils/constants/colors.dart';
import '../features/settings/screens/terms_of_use_screen.dart';
import '../features/settings/screens/privacy_policy_screen.dart';
import '../features/auth/controllers/theme_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181818) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.user,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.learning_level_beginner,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Profile settings
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Progress section
                  _buildSection(
                    AppLocalizations.of(context)!.progress_status,
                    [
                      _buildProgressItem(
                        AppLocalizations.of(context)!.total_completed_lessons,
                        '8',
                        Icons.book_rounded,
                        const Color(0xFF4F6CFF),
                        isDark,
                      ),
                      _buildProgressItem(
                        AppLocalizations.of(context)!.solved_exercises,
                        '25',
                        Icons.check_circle_rounded,
                        const Color(0xFF00BFA5),
                        isDark,
                      ),
                      _buildProgressItem(
                        AppLocalizations.of(context)!.accuracy_rate,
                        '%72',
                        Icons.trending_up_rounded,
                        const Color(0xFFFF9500),
                        isDark,
                      ),
                    ],
                    isDark,
                  ),

                  const SizedBox(height: 24),

                  // Settings section
                  _buildSection(
                    AppLocalizations.of(context)!.settings,
                    [
                      _buildSettingItem(
                        AppLocalizations.of(context)!.theme,
                        isDark
                            ? AppLocalizations.of(context)!.dark_theme
                            : AppLocalizations.of(context)!.light_theme,
                        Icons.brightness_6_rounded,
                        isDark,
                        onTap: () {
                          ref
                              .read(themeControllerProvider.notifier)
                              .toggleTheme();
                        },
                      ),
                      _buildSettingItem(
                        AppLocalizations.of(context)!.notifications,
                        AppLocalizations.of(context)!.on,
                        Icons.notifications_rounded,
                        isDark,
                      ),
                      _buildSettingItem(
                        AppLocalizations.of(context)!.language,
                        'Türkçe',
                        Icons.language_rounded,
                        isDark,
                      ),
                    ],
                    isDark,
                  ),

                  const SizedBox(height: 24),

                  // Legal section
                  _buildSection(
                    AppLocalizations.of(context)!.legal,
                    [
                      _buildSettingItem(
                        AppLocalizations.of(context)!.terms_of_use,
                        '',
                        Icons.description_outlined,
                        isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsOfUseScreen(),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        AppLocalizations.of(context)!.privacy_policy,
                        '',
                        Icons.privacy_tip_outlined,
                        isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildProgressItem(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      String title, String value, IconData icon, bool isDark,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDark
              ? Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.1),
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
