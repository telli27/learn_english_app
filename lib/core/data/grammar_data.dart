import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/grammar_topic.dart';
import 'grammar_version_checker.dart';
import '../../utils/update_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GrammarData {
  static List<GrammarTopic> topics = [];
  static final GrammarVersionChecker _versionChecker = GrammarVersionChecker();

  static Future<void> loadTopics({String languageCode = 'tr'}) async {
    print("📚 GrammarData.loadTopics called with language: $languageCode");
    print("📊 Current topics count: ${topics.length}");

    // Always check version and load data, don't skip based on existing topics
    // because topics might be for a different language

    try {
      // Always use version checker for proper version control and language support
      await _loadTopicsFromGitHub(languageCode);
    } catch (e) {
      print('Konular yüklenirken hata oluştu: $e');
      rethrow;
    }
  }

  static Future<void> _loadTopicsFromGitHub(String languageCode) async {
    try {
      debugPrint('Loading grammar topics for language: $languageCode...');

      // Use the version checker to check and update grammar data
      debugPrint('Calling checkAndUpdateGrammarData...');
      topics = await _versionChecker.checkAndUpdateGrammarData(
          languageCode: languageCode);
      debugPrint('checkAndUpdateGrammarData returned ${topics.length} topics');

      if (topics.isEmpty) {
        debugPrint(
            'No grammar data could be loaded, forcing download from GitHub');

        // Try to force download from GitHub
        final prefs = await SharedPreferences.getInstance();

        // Remove existing data to force fresh download
        debugPrint('Removing existing SharedPreferences data...');
        await prefs.remove(GrammarVersionChecker.VERSION_KEY);
        await prefs
            .remove(GrammarVersionChecker.getGrammarDataKey(languageCode));

        // Try again
        debugPrint('Retry calling checkAndUpdateGrammarData...');
        topics = await _versionChecker.checkAndUpdateGrammarData(
            languageCode: languageCode);

        if (topics.isEmpty) {
          debugPrint('Still unable to load grammar data after forced attempt');
        } else {
          debugPrint(
              'Successfully loaded ${topics.length} topics after forced attempt');
        }
      } else {
        debugPrint('Grammar data loaded with ${topics.length} topics');
      }
    } catch (e) {
      debugPrint('Error loading grammar data: $e');
      topics = [];
    }
  }

  // This method should be called after loadTopics, passing the current BuildContext
  static void showUpdateDialogIfNeeded(BuildContext context,
      {String languageCode = 'tr'}) {
    debugPrint(
        "Checking if update dialog should be shown: hasNewVersion=${_versionChecker.hasNewVersion}, newVersionData=${_versionChecker.newVersionData}");

    debugPrint(
        "Current version: ${_versionChecker.currentVersion}, Remote version: ${_versionChecker.remoteVersion}");

    if (_versionChecker.hasNewVersion &&
        _versionChecker.newVersionData.isNotEmpty) {
      debugPrint(
          "Showing update dialog with: ${_versionChecker.newVersionData}");
      // Show update dialog with the new version data
      UpdateDialog.showUpdateDialog(context, _versionChecker.newVersionData);

      // Mark this version as having shown the dialog
      debugPrint(
          "Marking update dialog as shown for version ${_versionChecker.remoteVersion}");
      _versionChecker.markUpdateDialogShown(languageCode: languageCode);
    } else {
      if (!_versionChecker.hasNewVersion) {
        debugPrint("No update dialog needed: hasNewVersion is false");
      }
      if (_versionChecker.newVersionData.isEmpty) {
        debugPrint("No update dialog needed: newVersionData is empty");
      }
    }
  }

  // Force check for updates by clearing SharedPreferences
  static Future<void> forceCheckForUpdates(BuildContext context,
      {String languageCode = 'tr'}) async {
    debugPrint("Forcing check for updates by clearing SharedPreferences");

    // Clear all data for language switching
    await GrammarVersionChecker.clearAllData();

    debugPrint("SharedPreferences cleared, now loading topics again");

    // Reload topics
    await loadTopics(languageCode: languageCode);

    // Show dialog if needed
    if (context.mounted) {
      showUpdateDialogIfNeeded(context, languageCode: languageCode);
    }

    debugPrint("Force check completed");
  }

  static void _checkForUpdatesInBackground(String languageCode) {
    // Arka planda güncellemeleri kontrol et, kullanıcı deneyimini engellemeden
    Future.microtask(() async {
      try {
        // Version checker ile güncellemeleri kontrol et
        final versionChecker = GrammarVersionChecker();

        // Verileri güncelle ve sonuçları al
        final updatedTopics = await versionChecker.checkAndUpdateGrammarData(
            languageCode: languageCode);

        // Eğer güncellenmiş konular boş değilse, güncelle
        if (updatedTopics.isNotEmpty) {
          topics = updatedTopics;
          debugPrint('Konular arka planda güncellendi: ${topics.length} konu');
        }
      } catch (e) {
        // Arka plan güncellemesi sırasında hata olursa, sessizce devam et
        // Bu, kullanıcı deneyimini etkilemez
        debugPrint('Arka planda güncelleme kontrol edilirken hata: $e');
      }
    });
  }
}
