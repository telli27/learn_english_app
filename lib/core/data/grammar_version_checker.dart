import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grammar_topic.dart';

class GrammarVersionChecker {
  static const String VERSION_KEY = 'grammar_version_json';
  static const String LAST_SHOWN_VERSION_KEY = 'last_shown_version';
  static const String VERSION_URL =
      'https://raw.githubusercontent.com/telli27/english_repository/main/version_grammer.json?cache=bust';

  // Language-specific grammar data URLs
  static const Map<String, String> GRAMMAR_DATA_URLS = {
    'tr':
        'https://raw.githubusercontent.com/telli27/english_repository/main/grammar_data.json?cache=bust', // Default Turkish
    'es':
        'https://raw.githubusercontent.com/telli27/english_repository/main/espanol.json?cache=bust', // TODO: Change to espanol.json when created
    'fr':
        'https://raw.githubusercontent.com/telli27/english_repository/main/francais.json?cache=bust', // TODO: Change to Francais.json when created
    'pt':
        'https://raw.githubusercontent.com/telli27/english_repository/main/portugues.json?cache=bust', // TODO: Change to Portugues.json when created
    'it':
        'https://raw.githubusercontent.com/telli27/english_repository/main/italiano.json?cache=bust', // TODO: Change to Italiano.json when created
  };

  // Language-specific SharedPreferences keys
  static String getGrammarDataKey(String languageCode) =>
      'grammar_data_json_$languageCode';
  static String getLastShownVersionKey(String languageCode) =>
      'last_shown_version_$languageCode';

  final Dio _dio = Dio();
  List<String> _newVersionData = [];
  bool _hasNewVersion = false;
  String _currentVersion = "0";
  String _remoteVersion = "0";

  // Getters for update information
  List<String> get newVersionData => _newVersionData;
  bool get hasNewVersion => _hasNewVersion;
  String get currentVersion => _currentVersion;
  String get remoteVersion => _remoteVersion;

  // Main method to check and update grammar data
  Future<List<GrammarTopic>> checkAndUpdateGrammarData(
      {String languageCode = 'tr'}) async {
    try {
      _hasNewVersion = false;
      _newVersionData = [];

      // First get remote version to always have it available
      debugPrint('Fetching remote version first from URL: $VERSION_URL');
      final Response remoteResponse = await _dio.get(VERSION_URL);
      final String remoteResponseStr = remoteResponse.data.toString();
      debugPrint('Remote response: $remoteResponseStr');

      // Parse remote version data
      Map<String, dynamic> remoteVersionData;
      try {
        remoteVersionData = json.decode(remoteResponseStr);
        debugPrint('Remote version data: $remoteVersionData');
      } catch (e) {
        debugPrint('Error parsing remote version data: $e');
        remoteVersionData = {
          "settings": {"version": 0}
        };
      }

      // Extract remote version
      _remoteVersion = _safeGetVersion(remoteVersionData);
      debugPrint('Remote version extracted: $_remoteVersion');

      // Check if newVersionData exists in remote and extract it
      if (remoteVersionData.containsKey('newVersionData')) {
        debugPrint(
            'Remote contains newVersionData: ${remoteVersionData['newVersionData']}');
        if (remoteVersionData['newVersionData'] is List) {
          _newVersionData =
              List<String>.from(remoteVersionData['newVersionData']);
          debugPrint('Extracted new version data: $_newVersionData');
        } else {
          _newVersionData = ['Yeni içerik güncellendi.'];
          debugPrint(
              'newVersionData is not a list, using default: $_newVersionData');
        }
      } else {
        _newVersionData = ['Yeni içerik güncellendi.'];
        debugPrint(
            'No newVersionData in remote, using default: $_newVersionData');
      }

      // Get local versions from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? versionJson = prefs.getString(VERSION_KEY);
      final String? grammarDataJson =
          prefs.getString(getGrammarDataKey(languageCode));
      final String? lastShownVersion =
          prefs.getString(getLastShownVersionKey(languageCode));

      debugPrint(
          'Retrieved from SharedPreferences - versionJson: ${versionJson != null ? 'exists' : 'null'}, grammarDataJson: ${grammarDataJson != null ? 'exists' : 'null'}, lastShownVersion: $lastShownVersion');
      debugPrint(
          'Grammar data key for language $languageCode: ${getGrammarDataKey(languageCode)}');

      // If no local data, download and save
      if (versionJson == null || grammarDataJson == null) {
        // Either version or grammar data is missing, download both
        // Ensure _hasNewVersion is false for first time users
        _hasNewVersion = false;
        debugPrint(
            'Missing data in SharedPreferences. Downloading both JSONs... No update dialog will be shown.');

        final topics = await _downloadAndSaveBothJsons(languageCode);
        // Set the last shown version to the current remote version to avoid showing dialog on first download
        await prefs.setString(
            getLastShownVersionKey(languageCode), _remoteVersion);
        return topics;
      }

      // If we have local data, parse and compare versions
      final Map<String, dynamic> localVersionData = json.decode(versionJson!);
      debugPrint('Local version data: $localVersionData');

      // Safely extract local version value
      _currentVersion = _safeGetVersion(localVersionData);
      debugPrint('Current version extracted: $_currentVersion');

      // Compare versions - if remote is newer, update content
      if (_isNewerVersion(_remoteVersion, _currentVersion)) {
        debugPrint(
            'Remote version $_remoteVersion is newer than current version $_currentVersion.');

        // Check if we've already shown the dialog for this version
        if (lastShownVersion == null || lastShownVersion != _remoteVersion) {
          debugPrint('Dialog has not been shown for this version yet.');
          _hasNewVersion = true;
          debugPrint('Setting hasNewVersion=true for version $_remoteVersion');
        } else {
          debugPrint('Update dialog already shown for version $_remoteVersion');
        }

        // Update both JSONs regardless of whether dialog is shown
        debugPrint(
            'New version available: $_currentVersion -> $_remoteVersion. Updating grammar data...');
        return await _downloadAndSaveBothJsons(languageCode);
      } else {
        // Current version is up to date
        debugPrint('Grammar data is up to date (Version: $_currentVersion)');

        // Try to parse the grammar data
        try {
          final Map<String, dynamic> grammarData =
              json.decode(grammarDataJson!);

          // Debug the grammar data structure
          if (grammarData.containsKey('topics')) {
            final topics = grammarData['topics'];
            debugPrint('Grammar data has ${topics.length} topics');
            if (topics.isNotEmpty) {
              final firstTopic = topics.first;
              debugPrint('First topic keys: ${firstTopic.keys.toList()}');
            }
          } else {
            debugPrint('ERROR: Grammar data does not have "topics" key!');
            debugPrint('Grammar data keys: ${grammarData.keys.toList()}');
          }

          final List<GrammarTopic> topics = _parseGrammarTopics(grammarData);

          if (topics.isNotEmpty) {
            debugPrint(
                'Successfully loaded ${topics.length} topics from SharedPreferences');
            return topics;
          } else {
            debugPrint(
                'No topics found in SharedPreferences data, downloading fresh data');
            return await _downloadAndSaveBothJsons(languageCode);
          }
        } catch (e) {
          debugPrint('Error parsing grammar data from SharedPreferences: $e');
          debugPrint('Downloading fresh data instead');
          return await _downloadAndSaveBothJsons(languageCode);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error checking/updating grammar data: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Mark the current version as having shown the dialog
  Future<void> markUpdateDialogShown({String languageCode = 'tr'}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          getLastShownVersionKey(languageCode), _remoteVersion);
      debugPrint(
          'Marked update dialog as shown for version $_remoteVersion for language: $languageCode');
    } catch (e) {
      debugPrint('Error marking dialog as shown: $e');
    }
  }

  // Clear all SharedPreferences data (for language switching)
  static Future<void> clearAllData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Clear version data
      await prefs.remove(VERSION_KEY);
      await prefs.remove(LAST_SHOWN_VERSION_KEY);

      // Clear all language-specific data
      for (String languageCode in GRAMMAR_DATA_URLS.keys) {
        await prefs.remove(getGrammarDataKey(languageCode));
        await prefs.remove(getLastShownVersionKey(languageCode));
      }

      debugPrint('Cleared all SharedPreferences data');
    } catch (e) {
      debugPrint('Error clearing SharedPreferences: $e');
    }
  }

  // Download and save both JSONs to SharedPreferences
  Future<List<GrammarTopic>> _downloadAndSaveBothJsons(
      String languageCode) async {
    try {
      debugPrint('Attempting to download JSON data from GitHub...');

      // Download version JSON with retry logic
      debugPrint('Downloading version data from $VERSION_URL');
      Response? versionResponse;
      int retryCount = 0;
      const int maxRetries = 3;

      while (versionResponse == null && retryCount < maxRetries) {
        try {
          versionResponse = await _dio.get(VERSION_URL);
        } catch (e) {
          retryCount++;
          debugPrint(
              'Error downloading version data (attempt $retryCount/$maxRetries): $e');
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: 1)); // Wait before retry
          }
        }
      }

      if (versionResponse == null) {
        throw Exception(
            'Failed to download version data after $maxRetries attempts');
      }

      final String versionResponseStr = versionResponse.data.toString();
      debugPrint('Version response: $versionResponseStr');

      // Manually parse JSON string
      final Map<String, dynamic> versionData = json.decode(versionResponseStr);
      debugPrint('Parsed version data: $versionData');

      // Get the remote version
      _remoteVersion = _safeGetVersion(versionData);
      debugPrint('Extracted remote version: $_remoteVersion');

      // Check for newVersionData in new version
      if (versionData.containsKey('newVersionData')) {
        if (versionData['newVersionData'] is List) {
          _newVersionData = List<String>.from(versionData['newVersionData']);
          debugPrint('Extracted newVersionData: $_newVersionData');
        } else {
          // If no newVersionData, create a default message
          _newVersionData = ['Yeni içerik güncellendi.'];
          debugPrint(
              'No newVersionData in JSON, using default: $_newVersionData');
        }
      } else {
        // If no newVersionData, create a default message
        _newVersionData = ['Yeni içerik güncellendi.'];
        debugPrint(
            'No newVersionData in JSON, using default: $_newVersionData');
      }

      // Get the last shown version
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? lastShownVersion = prefs.getString(LAST_SHOWN_VERSION_KEY);
      debugPrint('Last shown version: $lastShownVersion');

      // Check if we should show the update dialog
      // Only show dialog if the last shown version is different from the current remote version
      if (lastShownVersion != _remoteVersion) {
        _hasNewVersion = true;
        debugPrint(
            'New version detected: $_remoteVersion (last shown: $lastShownVersion)');
      } else {
        _hasNewVersion = false;
        debugPrint(
            'Version already shown to user: $_remoteVersion (last shown: $lastShownVersion)');
      }

      // Download grammar data JSON with retry logic
      final grammarDataUrl =
          GRAMMAR_DATA_URLS[languageCode] ?? GRAMMAR_DATA_URLS['tr']!;
      debugPrint(
          'Downloading grammar data from $grammarDataUrl for language: $languageCode');
      debugPrint(
          'Available language URLs: ${GRAMMAR_DATA_URLS.keys.join(', ')}');
      debugPrint('Language code requested: $languageCode');
      Response? grammarResponse;
      retryCount = 0;

      while (grammarResponse == null && retryCount < maxRetries) {
        try {
          debugPrint(
              'Attempting to download grammar data (attempt ${retryCount + 1}/$maxRetries)...');
          grammarResponse = await _dio.get(grammarDataUrl);
          debugPrint('Grammar data download successful!');
        } catch (e) {
          retryCount++;
          debugPrint(
              'Error downloading grammar data (attempt $retryCount/$maxRetries): $e');

          // Check if this is a 404 error and we're not already trying Turkish
          if (e.toString().contains('404') &&
              languageCode != 'tr' &&
              retryCount >= maxRetries) {
            debugPrint(
                'File not found for $languageCode, trying Turkish fallback...');
            try {
              grammarResponse = await _dio.get(GRAMMAR_DATA_URLS['tr']!);
              debugPrint('Turkish fallback successful!');
              break; // Exit the retry loop
            } catch (turkishError) {
              debugPrint('Turkish fallback also failed: $turkishError');
            }
          }

          if (retryCount < maxRetries) {
            debugPrint('Waiting 1 second before retry...');
            await Future.delayed(Duration(seconds: 1)); // Wait before retry
          }
        }
      }

      if (grammarResponse == null) {
        // If we couldn't get the requested language, try Turkish as fallback
        if (languageCode != 'tr') {
          debugPrint(
              'Failed to download $languageCode data, trying Turkish fallback...');
          final turkishUrl = GRAMMAR_DATA_URLS['tr']!;

          try {
            grammarResponse = await _dio.get(turkishUrl);
            debugPrint('Turkish fallback data downloaded successfully');
          } catch (e) {
            debugPrint('Turkish fallback also failed: $e');
            throw Exception(
                'Failed to download grammar data for both $languageCode and Turkish');
          }
        } else {
          throw Exception(
              'Failed to download grammar data after $maxRetries attempts');
        }
      }

      final String grammarResponseStr = grammarResponse.data.toString();

      // Debug response size
      debugPrint(
          'Grammar data response size: ${grammarResponseStr.length} characters');

      // Debug first few characters to see what we actually received
      final String firstChars = grammarResponseStr.length > 200
          ? grammarResponseStr.substring(0, 200)
          : grammarResponseStr;
      debugPrint('First 200 characters of grammar response: $firstChars');

      // Parse grammar data
      debugPrint('Parsing grammar data JSON...');
      Map<String, dynamic> grammarData;
      try {
        // Clean the response string before parsing
        String cleanedResponse = grammarResponseStr.trim();

        // Remove any potential BOM (Byte Order Mark) characters
        if (cleanedResponse.startsWith('\uFEFF')) {
          cleanedResponse = cleanedResponse.substring(1);
        }

        // Remove any invisible characters at the beginning
        while (cleanedResponse.isNotEmpty &&
            cleanedResponse.codeUnitAt(0) <= 32 &&
            cleanedResponse.codeUnitAt(0) != 9 && // tab
            cleanedResponse.codeUnitAt(0) != 10 && // newline
            cleanedResponse.codeUnitAt(0) != 13) {
          // carriage return
          cleanedResponse = cleanedResponse.substring(1);
        }

        debugPrint(
            'Cleaned response first 200 chars: ${cleanedResponse.length > 200 ? cleanedResponse.substring(0, 200) : cleanedResponse}');

        grammarData = json.decode(cleanedResponse);
        debugPrint('Grammar data JSON parsed successfully');
      } catch (e) {
        debugPrint('ERROR: Failed to parse grammar data JSON: $e');
        debugPrint(
            'This usually means the URL returned HTML instead of JSON or has invalid characters');
        debugPrint('Check if the file exists at: $grammarDataUrl');

        // If this is not Turkish and parsing failed, try Turkish fallback
        if (languageCode != 'tr') {
          debugPrint(
              'JSON parsing failed for $languageCode, trying Turkish fallback...');
          try {
            final turkishUrl = GRAMMAR_DATA_URLS['tr']!;
            final turkishResponse = await _dio.get(turkishUrl);
            final turkishResponseStr = turkishResponse.data.toString();

            // Clean Turkish response too
            String cleanedTurkishResponse = turkishResponseStr.trim();
            if (cleanedTurkishResponse.startsWith('\uFEFF')) {
              cleanedTurkishResponse = cleanedTurkishResponse.substring(1);
            }

            grammarData = json.decode(cleanedTurkishResponse);
            debugPrint('Turkish fallback JSON parsed successfully');
          } catch (turkishError) {
            debugPrint('Turkish fallback also failed: $turkishError');
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      // Debug the grammar data structure
      if (grammarData.containsKey('topics')) {
        final topics = grammarData['topics'];
        debugPrint('Grammar data has ${topics.length} topics');
        if (topics.isNotEmpty) {
          final firstTopic = topics.first;
          debugPrint('First topic keys: ${firstTopic.keys.toList()}');
        }
      } else {
        debugPrint('ERROR: Grammar data does not have "topics" key!');
        debugPrint('Grammar data keys: ${grammarData.keys.toList()}');
      }

      // Save both to SharedPreferences
      final SharedPreferences prefs2 = await SharedPreferences.getInstance();

      // Save version data
      final String versionJsonStr = json.encode(versionData);
      debugPrint('Saving version JSON to prefs: $versionJsonStr');
      final bool versionSaved =
          await prefs2.setString(VERSION_KEY, versionJsonStr);
      debugPrint('Version saved successfully: $versionSaved');

      // Verify the saved version
      final String? savedVersionJson = prefs2.getString(VERSION_KEY);
      if (savedVersionJson != null) {
        final savedVersion = _safeGetVersion(json.decode(savedVersionJson));
        debugPrint(
            'Verified saved version in prefs: $savedVersion (should match $_remoteVersion)');
      } else {
        debugPrint('ERROR: Version was not saved to SharedPreferences!');
      }

      // Save grammar data
      final String grammarJsonStr = json.encode(grammarData);
      debugPrint(
          'Saving grammar JSON to prefs (length: ${grammarJsonStr.length}) for language: $languageCode');
      final bool grammarSaved = await prefs2.setString(
          getGrammarDataKey(languageCode), grammarJsonStr);
      debugPrint('Grammar saved successfully: $grammarSaved');

      // Parse grammar data into model objects
      debugPrint('Converting grammar data to topic objects...');
      final List<GrammarTopic> topics = _parseGrammarTopics(grammarData);
      debugPrint('Parsed ${topics.length} grammar topics');

      if (topics.isEmpty) {
        debugPrint('WARNING: No topics were parsed from grammar data!');
      } else {
        debugPrint(
            'Successfully parsed topics: ${topics.map((t) => t.title).take(3).join(', ')}...');
      }

      debugPrint('Downloaded and saved both JSONs to SharedPreferences');
      return topics;
    } catch (e, stackTrace) {
      debugPrint('Error downloading and saving JSONs: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Safely get version - with fallback to empty string
  String _safeGetVersion(Map<String, dynamic> data) {
    try {
      debugPrint('Extracting version from data: $data');

      if (data.containsKey('settings')) {
        final settings = data['settings'];
        debugPrint('Found settings: $settings');

        if (settings is Map && settings.containsKey('version')) {
          final version = settings['version'];
          final versionStr = version != null ? version.toString() : '0';
          debugPrint('Found version: $version (as string: $versionStr)');
          return versionStr;
        } else {
          debugPrint(
              'Settings does not contain version or is not a Map: $settings');
        }
      } else {
        debugPrint('Data does not contain settings key');
      }

      debugPrint('Could not find settings.version in data, returning "0"');
      return '0';
    } catch (e) {
      debugPrint('Error getting version: $e');
      return '0';
    }
  }

  // Parse JSON data into GrammarTopic objects
  List<GrammarTopic> _parseGrammarTopics(Map<String, dynamic> grammarData) {
    try {
      if (!grammarData.containsKey('topics')) {
        debugPrint('Grammar data does not contain topics key');
        return [];
      }

      final List<dynamic> topicsJson = grammarData['topics'];
      if (topicsJson.isEmpty) {
        debugPrint('Topics list is empty');
        return [];
      }

      final List<GrammarTopic> result = [];

      // Process each topic individually to isolate errors
      for (var topicJson in topicsJson) {
        try {
          // Skip topics with missing required fields
          if (topicJson == null ||
              topicJson is! Map<String, dynamic> ||
              !topicJson.containsKey('title') ||
              !topicJson.containsKey('description') ||
              topicJson['title'] == null ||
              topicJson['description'] == null ||
              topicJson['title'].toString().trim().isEmpty) {
            debugPrint('Skipping invalid or empty topic: $topicJson');
            continue;
          }

          final topic = GrammarTopic.fromJson(topicJson);
          result.add(topic);
        } catch (e) {
          debugPrint('Error parsing topic: $e');
          debugPrint('Problematic topic data: $topicJson');
          // Continue with next topic
        }
      }

      debugPrint('After filtering, returning ${result.length} valid topics');
      return result;
    } catch (e, stackTrace) {
      debugPrint('Error parsing grammar topics: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Compare version strings to determine if remoteVersion is newer
  bool _isNewerVersion(String remoteVersion, String currentVersion) {
    try {
      // Handle empty versions
      if (remoteVersion.isEmpty) {
        debugPrint('Remote version is empty, returning false');
        return false;
      }
      if (currentVersion.isEmpty) {
        debugPrint('Current version is empty, returning true');
        return true;
      }

      // Ensure numeric comparison by parsing to integers
      int remoteNum = int.tryParse(remoteVersion) ?? 0;
      int currentNum = int.tryParse(currentVersion) ?? 0;

      debugPrint(
          'Comparing versions numerically: REMOTE=$remoteNum vs CURRENT=$currentNum');

      // Direct numeric comparison - clearer and more reliable
      if (remoteNum > currentNum) {
        debugPrint('Remote version is NEWER: $remoteNum > $currentNum');
        return true;
      } else {
        debugPrint('Remote version is NOT newer: $remoteNum <= $currentNum');
        return false;
      }
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      // If we can't parse properly, assume remote is newer for safety
      return true;
    }
  }
}
