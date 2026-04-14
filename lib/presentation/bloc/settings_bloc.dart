import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zikermate/core/utils/constants.dart';
import 'package:zikermate/presentation/bloc/settings_event.dart';
import 'package:zikermate/presentation/bloc/settings_state.dart';

/// BLoC that manages app settings — specifically notification scheduling and persistence.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  SettingsBloc({required this.notificationsPlugin}) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateReminderTime>(_onUpdateReminderTime);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    final box = await Hive.openBox(AppConstants.reminderBoxName);
    final savedMinutes = box.get(AppConstants.reminderTimeKey);
    
    if (savedMinutes != null) {
      final time = TimeOfDay(
        hour: (savedMinutes as int) ~/ 60,
        minute: savedMinutes % 60,
      );
      emit(SettingsLoaded(time));
    } else {
      emit(const SettingsLoaded(null));
    }
  }

  Future<void> _onUpdateReminderTime(
    UpdateReminderTime event,
    Emitter<SettingsState> emit,
  ) async {
    final box = await Hive.openBox(AppConstants.reminderBoxName);
    
    if (event.time == null) {
      await box.delete(AppConstants.reminderTimeKey);
      await notificationsPlugin.cancelAll();
      emit(const SettingsLoaded(null));
    } else {
      final time = event.time!;
      final minutes = time.hour * 60 + time.minute;
      await box.put(AppConstants.reminderTimeKey, minutes);
      await _scheduleNotification(time);
      emit(SettingsLoaded(time));
    }
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    await notificationsPlugin.cancelAll();

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

    await notificationsPlugin.zonedSchedule(
      id: 0,
      title: 'ZikarMate',
      body: 'Time for your dhikr — stay consistent 📿',
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.performance,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
