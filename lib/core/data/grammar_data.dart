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
    try {
      debugPrint('Loading grammar topics...');

      // Check if topics list is already populated
      if (topics.isNotEmpty) {
        debugPrint('Topics already loaded with ${topics.length} topics');
        return;
      }

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
}
