import 'package:zikermate/domain/entities/dhikr_entity.dart';

/// App-wide constants — default dhikr list and notification config.
class AppConstants {
  AppConstants._();

  static const String notificationChannelId = 'dhikr_reminder';
  static const String notificationChannelName = 'Dhikr Reminder';
  static const String notificationChannelDesc =
      'Daily reminder to do your dhikr';

  static const String reminderBoxName = 'settings';
  static const String reminderTimeKey = 'reminder_time';

  static const List<DhikrEntity> defaultDhikrs = [
    DhikrEntity(
      id: 'subhanallah',
      name: 'SubhanAllah',
      currentCount: 0,
      targetCount: 33,
    ),
    DhikrEntity(
      id: 'alhamdulillah',
      name: 'Alhamdulillah',
      currentCount: 0,
      targetCount: 33,
    ),
    DhikrEntity(
      id: 'allahuakbar',
      name: 'Allahu Akbar',
      currentCount: 0,
      targetCount: 34,
    ),
    DhikrEntity(
      id: 'astaghfirullah',
      name: 'Astaghfirullah',
      currentCount: 0,
      targetCount: 33,
    ),
    DhikrEntity(
      id: 'lailahaillallah',
      name: 'La ilaha illallah',
      currentCount: 0,
      targetCount: 33,
    ),
  ];
}
