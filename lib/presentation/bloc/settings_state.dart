import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// All BLoC states for settings — reflects the current config like notification time.
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state for settings.
class SettingsInitial extends SettingsState {}

/// Settings loading state.
class SettingsLoading extends SettingsState {}

/// Loaded state containing the active reminder time.
class SettingsLoaded extends SettingsState {
  final TimeOfDay? reminderTime;

  const SettingsLoaded(this.reminderTime);

  @override
  List<Object?> get props => [reminderTime];
}
