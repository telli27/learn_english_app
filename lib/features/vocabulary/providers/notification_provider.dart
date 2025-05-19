import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool dailyWordEnabled;
  final String notificationTime;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationSettings({
    this.dailyWordEnabled = true,
    this.notificationTime = '09:00',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationSettings copyWith({
    bool? dailyWordEnabled,
    String? notificationTime,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      dailyWordEnabled: dailyWordEnabled ?? this.dailyWordEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

class NotificationController extends StateNotifier<NotificationSettings> {
  NotificationController() : super(NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final dailyWordEnabled =
          prefs.getBool('notification_daily_word_enabled') ?? true;
      final notificationTime = prefs.getString('notification_time') ?? '09:00';
      final soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
      final vibrationEnabled =
          prefs.getBool('notification_vibration_enabled') ?? true;

      state = NotificationSettings(
        dailyWordEnabled: dailyWordEnabled,
        notificationTime: notificationTime,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
      );
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  Future<void> toggleDailyWordNotification(bool enabled) async {
    state = state.copyWith(dailyWordEnabled: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_daily_word_enabled', enabled);

      // Here you would implement the actual notification scheduling
      // using platform-specific notification plugins
      if (enabled) {
        _scheduleDailyWordNotification();
      } else {
        _cancelDailyWordNotification();
      }
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  Future<void> setNotificationTime(String time) async {
    state = state.copyWith(notificationTime: time);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_time', time);

      if (state.dailyWordEnabled) {
        _scheduleDailyWordNotification();
      }
    } catch (e) {
      print('Error saving notification time: $e');
    }
  }

  Future<void> toggleSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_sound_enabled', enabled);
    } catch (e) {
      print('Error saving sound setting: $e');
    }
  }

  Future<void> toggleVibrationEnabled(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_vibration_enabled', enabled);
    } catch (e) {
      print('Error saving vibration setting: $e');
    }
  }

  // Placeholder for actual notification scheduling
  void _scheduleDailyWordNotification() {
    // This would use a platform-specific notification plugin
    print('Scheduling daily word notification for ${state.notificationTime}');

    // Implementation example (pseudo-code):
    // final [hour, minute] = state.notificationTime.split(':').map(int.parse).toList();
    // NotificationPlugin.scheduleDaily(
    //   id: 1,
    //   title: 'Yeni Günün Kelimesi',
    //   body: 'Bugün için yeni bir kelime öğrenmeye hazır mısınız?',
    //   hour: hour,
    //   minute: minute,
    //   sound: state.soundEnabled,
    //   vibration: state.vibrationEnabled,
    // );
  }

  void _cancelDailyWordNotification() {
    // This would use a platform-specific notification plugin
    print('Cancelling daily word notification');

    // Implementation example (pseudo-code):
    // NotificationPlugin.cancel(id: 1);
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationController, NotificationSettings>(
  (ref) => NotificationController(),
);
