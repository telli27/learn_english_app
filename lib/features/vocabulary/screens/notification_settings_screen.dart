import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationSettings = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Günlük Kelime Bildirimleri'),
          const SizedBox(height: 8),
          _buildCard(
            context,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Günlük Kelime Bildirimleri'),
                  subtitle:
                      const Text('Her gün yeni kelimeler hakkında bildirim al'),
                  value: notificationSettings.dailyWordEnabled,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    notifier.toggleDailyWordNotification(value);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Bildirim Zamanı'),
                  subtitle: Text(notificationSettings.notificationTime),
                  trailing: const Icon(Icons.access_time),
                  enabled: notificationSettings.dailyWordEnabled,
                  onTap: () => _showTimePickerDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Bildirim Tercihleri'),
          const SizedBox(height: 8),
          _buildCard(
            context,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Ses'),
                  subtitle: const Text('Bildirimlerde ses çalsın'),
                  value: notificationSettings.soundEnabled,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    notifier.toggleSoundEnabled(value);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Titreşim'),
                  subtitle: const Text('Bildirimlerde telefonun titreşsin'),
                  value: notificationSettings.vibrationEnabled,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    notifier.toggleVibrationEnabled(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            title: 'Bildirimleri etkinleştirin',
            message:
                'Günlük kelime hatırlatmaları ile dil öğrenmenizi düzenli hale getirin ve kelime haznenizi geliştirin.',
            icon: Icons.lightbulb_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 24,
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
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(notificationProvider.notifier);
    final currentTime = ref.read(notificationProvider).notificationTime;

    // Parse current time string into TimeOfDay
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      // Format to hh:mm
      final hour = selectedTime.hour.toString().padLeft(2, '0');
      final minute = selectedTime.minute.toString().padLeft(2, '0');
      final newTime = '$hour:$minute';

      notifier.setNotificationTime(newTime);
    }
  }
}
