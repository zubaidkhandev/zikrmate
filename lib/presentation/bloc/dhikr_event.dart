import 'package:equatable/equatable.dart';

/// All BLoC events for dhikr operations — each event is a user intention.
abstract class DhikrEvent extends Equatable {
  const DhikrEvent();

  @override
  List<Object?> get props => [];
}

/// Load all dhikrs from storage on app startup.
class LoadDhikrs extends DhikrEvent {}

/// Increment the counter for a specific dhikr by 1.
class IncrementDhikr extends DhikrEvent {
  final String id;

  const IncrementDhikr(this.id);

  @override
  List<Object?> get props => [id];
}

/// Reset the counter for a specific dhikr back to 0.
class ResetDhikr extends DhikrEvent {
  final String id;

  const ResetDhikr(this.id);

  @override
  List<Object?> get props => [id];
}

/// Update the target (goal) count for a specific dhikr.
class SetGoalEvent extends DhikrEvent {
  final String id;
  final int target;

  const SetGoalEvent(this.id, this.target);

  @override
  List<Object?> get props => [id, target];
}

/// Add a new user-created custom dhikr.
class AddCustomDhikrEvent extends DhikrEvent {
  final String name;
  final int target;

  const AddCustomDhikrEvent(this.name, this.target);

  @override
  List<Object?> get props => [name, target];
}

/// Select a specific dhikr as the active one for counting.
class SelectDhikr extends DhikrEvent {
  final String id;

  const SelectDhikr(this.id);

  @override
  List<Object?> get props => [id];
}

/// Delete a custom dhikr entry.
class DeleteDhikr extends DhikrEvent {
  final String id;

  const DeleteDhikr(this.id);

  @override
  List<Object?> get props => [id];
}
