import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/constants/colors.dart';
import 'home_screen.dart';
import '../../../features/settings/screens/settings_screen.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/user_avatar.dart';
import 'package:flutter/services.dart';
import '../../grammar/screens/exercises_screen.dart';
import '../../../screens/daily_phrases_screen.dart';
import '../../../features/vocabulary/screens/vocabulary_screen.dart';

// Global function to show user menu
void showUserMenu(BuildContext context, WidgetRef ref, bool isDark) {
  final authState = ref.read(authProvider);
  final isLoggedIn = authState.isLoggedIn;
  final l10n = AppLocalizations.of(context)!;

  if (!isLoggedIn) {
    // Kullanıcı giriş yapmamışsa giriş ekranına yönlendir
    Navigator.pushNamed(context, '/login');
    return;
  }

  // Hafif titreşim geri bildirimi
  HapticFeedback.lightImpact();

  final username = authState.username ?? 'ehname';
  final email = authState.email ?? 'huseyintelli30@gmail.com';

  // Popup menu pozisyonunu hesapla - Avatar'ın hemen altında
  showMenu(
    context: context,
    color: Colors.transparent,
    elevation: 0,
    position: RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width -
          250 -
          20, // Sol taraftan (Sağa hizalı)
      kToolbarHeight +
          MediaQuery.of(context).padding.top +
          10, // Avatar'ın hemen altı
      20, // Sağdan
      0, // Alttan (önemsiz)
    ),
    items: [
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 250,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'E',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.1)),
                // Logout button
                InkWell(
                  onTap: () {
                    Navigator.pop(context); // Menüyü kapat
                    // Log user out directly
                    ref.read(authProvider.notifier).logout();

                    // Show snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.logged_out,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green.shade600,
                        margin:
                            EdgeInsets.only(bottom: 80, left: 40, right: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.logout,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    DailyPhrasesScreen(),
    VocabularyScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242424) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primary,
            unselectedItemColor:
                isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
            items: [
              _buildNavItem(Icons.home_rounded, l10n.home_page, 0),
              _buildNavItem(Icons.chat_bubble_outline, l10n.conversation, 1),
              _buildNavItem(Icons.menu_book_rounded, l10n.words, 2),
              _buildNavItem(Icons.settings_rounded, l10n.settings, 3),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
