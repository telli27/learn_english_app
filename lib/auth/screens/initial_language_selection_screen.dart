import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:learn_english_app/auth/screens/auth_wrapper.dart';
import 'package:learn_english_app/core/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialLanguageSelectionScreen extends ConsumerWidget {
  const InitialLanguageSelectionScreen({Key? key}) : super(key: key);

  Future<void> _setLanguageSelected(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_selected', true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(languageLoadingProvider);
    final loadingProgress = ref.watch(languageLoadingProgressProvider);

    final languages = [
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
      {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    ];

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.select_language,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: languages.length,
                      itemBuilder: (context, index) {
                        final language = languages[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Text(
                              language['flag']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(language['name']!),
                            enabled: !isLoading,
                            onTap: isLoading
                                ? null
                                : () async {
                                    await ref
                                        .read(localeProvider.notifier)
                                        .setLocale(
                                          Locale(language['code']!, ''),
                                        );
                                    await _setLanguageSelected(ref);
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AuthWrapper(),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: loadingProgress,
                        backgroundColor: Colors.grey[300],
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.loading_data,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(loadingProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
