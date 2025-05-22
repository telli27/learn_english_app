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

  static Future<void> loadTopics() async {
    if (topics.isNotEmpty) {
      return; // Eğer konular zaten yüklenmişse fonksiyondan çık
    }

    try {
      // Önce önbellekten yüklemeyi dene
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('grammar_data_json');

      if (cachedData != null && cachedData.isNotEmpty) {
        // Önbellekteki verileri kullan
        try {
          final dynamic decoded = jsonDecode(cachedData);

          // Veri bir liste olabilir veya {topics: [...]} şeklinde bir nesne olabilir
          if (decoded is List) {
            // Doğrudan liste formatında
            topics =
                decoded.map((json) => GrammarTopic.fromJson(json)).toList();
          } else if (decoded is Map && decoded.containsKey('topics')) {
            // {topics: [...]} formatında
            final topicsList = decoded['topics'] as List;
            topics =
                topicsList.map((json) => GrammarTopic.fromJson(json)).toList();
          } else {
            debugPrint(
                'Önbellekteki veri geçerli bir formatta değil, GitHub\'dan yükleniyor...');
            await _loadTopicsFromGitHub();
            return;
          }

          // Hemen verileri kullanmaya başla ve arka planda güncel verileri kontrol et
          _checkForUpdatesInBackground();
          return;
        } catch (e) {
          debugPrint('Önbellekteki veriyi ayrıştırırken hata oluştu: $e');
          // Hata durumunda GitHub'dan yükle
          await _loadTopicsFromGitHub();
          return;
        }
      }

      // Önbellekte veri yoksa GitHub'dan yükle
      await _loadTopicsFromGitHub();
    } catch (e) {
      print('Konular yüklenirken hata oluştu: $e');
      rethrow;
    }
  }

  static Future<void> _loadTopicsFromGitHub() async {
    try {
      debugPrint('Loading grammar topics...');

      // Use the version checker to check and update grammar data
      topics = await _versionChecker.checkAndUpdateGrammarData();

      if (topics.isEmpty) {
        debugPrint(
            'No grammar data could be loaded, forcing download from GitHub');

        // Try to force download from GitHub
        final prefs = await SharedPreferences.getInstance();

        // Remove existing data to force fresh download
        await prefs.remove(GrammarVersionChecker.VERSION_KEY);
        await prefs.remove(GrammarVersionChecker.GRAMMAR_DATA_KEY);

        // Try again
        topics = await _versionChecker.checkAndUpdateGrammarData();

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
  static void showUpdateDialogIfNeeded(BuildContext context) {
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
      _versionChecker.markUpdateDialogShown();
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
  static Future<void> forceCheckForUpdates(BuildContext context) async {
    debugPrint("Forcing check for updates by clearing SharedPreferences");

    // Clear SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(GrammarVersionChecker.VERSION_KEY);
    await prefs.remove(GrammarVersionChecker.GRAMMAR_DATA_KEY);
    await prefs.remove(GrammarVersionChecker.LAST_SHOWN_VERSION_KEY);

    debugPrint("SharedPreferences cleared, now loading topics again");

    // Reload topics
    await loadTopics();

    // Show dialog if needed
    if (context.mounted) {
      showUpdateDialogIfNeeded(context);
    }

    debugPrint("Force check completed");
  }

  static void _checkForUpdatesInBackground() {
    // Arka planda güncellemeleri kontrol et, kullanıcı deneyimini engellemeden
    Future.microtask(() async {
      try {
        // Version checker ile güncellemeleri kontrol et
        final versionChecker = GrammarVersionChecker();

        // Verileri güncelle ve sonuçları al
        final updatedTopics = await versionChecker.checkAndUpdateGrammarData();

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
