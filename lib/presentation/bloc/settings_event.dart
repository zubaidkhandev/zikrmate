import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// All BLoC events for app settings — specifically notification reminder time.
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load saved settings from Hive.
class LoadSettings extends SettingsEvent {}

/// Event to update and persist the notification reminder time.
class UpdateReminderTime extends SettingsEvent {
  final TimeOfDay? time;

  const UpdateReminderTime(this.time);

  @override
  List<Object?> get props => [time];
}
