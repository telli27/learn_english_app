import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(languageLoadingProvider);
    final loadingProgress = ref.watch(languageLoadingProgressProvider);

    final languages = [
      {'code': 'tr', 'name': l10n.turkish, 'flag': '🇹🇷'},
      {'code': 'es', 'name': l10n.spanish, 'flag': '🇪🇸'},
      {'code': 'fr', 'name': l10n.french, 'flag': '🇫🇷'},
      {'code': 'pt', 'name': l10n.portuguese, 'flag': '🇵🇹'},
      {'code': 'it', 'name': l10n.italian, 'flag': '🇮🇹'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.select_language),
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              final isSelected = currentLocale.languageCode == language['code'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Text(
                    language['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    language['name']!,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  enabled: !isLoading,
                  onTap: isLoading
                      ? null
                      : () async {
                          await ref.read(localeProvider.notifier).setLocale(
                                Locale(language['code']!, ''),
                              );
                          // Navigate back after successful language change
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                ),
              );
            },
          ),
          // Loading overlay
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
