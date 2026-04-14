import 'package:equatable/equatable.dart';
import 'package:zikermate/domain/entities/dhikr_entity.dart';

/// All BLoC states — the UI renders based on which state is active.
abstract class DhikrState extends Equatable {
  const DhikrState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class DhikrInitial extends DhikrState {}

/// Loading state while fetching data from Hive.
class DhikrLoading extends DhikrState {}

/// Loaded state containing all dhikrs and the currently selected one.
class DhikrLoaded extends DhikrState {
  final List<DhikrEntity> dhikrs;
  final String selectedId;

  const DhikrLoaded({
    required this.dhikrs,
    required this.selectedId,
  });

  /// Helper to get the currently selected dhikr entity.
  DhikrEntity get selectedDhikr =>
      dhikrs.firstWhere((d) => d.id == selectedId);

  @override
  List<Object?> get props => [dhikrs, selectedId];
}

/// Error state with a descriptive message.
class DhikrError extends DhikrState {
  final String message;

  const DhikrError(this.message);

  @override
  List<Object?> get props => [message];
}
