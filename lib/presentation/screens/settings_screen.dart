import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zikermate/core/theme/app_theme.dart';
import 'package:zikermate/core/utils/constants.dart';

/// Settings screen — lets user pick a daily reminder time for dhikr notifications.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  TimeOfDay? _selectedTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadSavedTime();
  }

  Future<void> _initNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notificationsPlugin.initialize(settings: initSettings);
  }

  Future<void> _loadSavedTime() async {
    final box = await Hive.openBox(AppConstants.reminderBoxName);
    final savedMinutes = box.get(AppConstants.reminderTimeKey);
    if (savedMinutes != null && mounted) {
      _selectedTime = TimeOfDay(
        hour: (savedMinutes as int) ~/ 60,
        minute: savedMinutes % 60,
      );
    }
    if (mounted) {
      _isLoading = false;
      // Using BLoC for dhikr state, but notification settings are isolated
      // and local to this screen — minimal state, OK to rebuild via setState-free approach.
      // We use a simple ValueNotifier pattern internally.
      (context as Element).markNeedsBuild();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 6, minute: 0),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.cardDark,
              hourMinuteColor: AppTheme.cardLight,
              dialBackgroundColor: AppTheme.cardLight,
              dialHandColor: AppTheme.primaryTeal,
              entryModeIconColor: AppTheme.accentGold,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _selectedTime = picked;
      await _saveAndSchedule(picked);
      if (mounted) (context as Element).markNeedsBuild();
    }
  }

  Future<void> _saveAndSchedule(TimeOfDay time) async {
    // Save to Hive
    final box = await Hive.openBox(AppConstants.reminderBoxName);
    final minutes = time.hour * 60 + time.minute;
    await box.put(AppConstants.reminderTimeKey, minutes);

    // Schedule notification
    await _scheduleNotification(time);
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    await _notificationsPlugin.cancelAll();

    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: 0,
      title: 'ZikarMate',
      body: 'Time for your dhikr — stay consistent 📿',
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _cancelReminder() async {
    await _notificationsPlugin.cancelAll();
    final box = await Hive.openBox(AppConstants.reminderBoxName);
    await box.delete(AppConstants.reminderTimeKey);
    _selectedTime = null;
    if (mounted) (context as Element).markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryTeal),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Reminder Section ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.notifications_active_rounded,
                                color: AppTheme.accentGold, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Daily Reminder',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Set a daily notification to remind you to complete your dhikr.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        if (_selectedTime != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryTeal.withValues(alpha: 0.15),
                                  AppTheme.primaryDark.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    AppTheme.primaryTeal.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    color: AppTheme.primaryTeal, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedTime!.format(context),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Daily',
                                  style: TextStyle(
                                    color: AppTheme.primaryTeal,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickTime,
                                icon: Icon(
                                  _selectedTime != null
                                      ? Icons.edit_rounded
                                      : Icons.alarm_add_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  _selectedTime != null
                                      ? 'Change Time'
                                      : 'Set Reminder',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryTeal,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedTime != null) ...[
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: _cancelReminder,
                                icon: const Icon(Icons.notifications_off_rounded,
                                    color: Color(0xFFEF5350)),
                                tooltip: 'Cancel Reminder',
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF5350)
                                      .withValues(alpha: 0.12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(14),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── About Section ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.textSecondary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('📿',
                                style: TextStyle(fontSize: 22)),
                            SizedBox(width: 12),
                            Text(
                              'ZikarMate',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your digital tasbih companion. Keep track of your daily dhikr with ease.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
