import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zikermate/domain/usecases/get_dhikrs.dart';
import 'package:zikermate/domain/usecases/increment_count.dart';
import 'package:zikermate/domain/usecases/reset_count.dart';
import 'package:zikermate/domain/usecases/set_goal.dart';
import 'package:zikermate/domain/usecases/add_custom_dhikr.dart';
import 'package:zikermate/domain/repositories/dhikr_repository.dart';
import 'package:zikermate/presentation/bloc/dhikr_event.dart';
import 'package:zikermate/presentation/bloc/dhikr_state.dart';

/// BLoC that orchestrates dhikr operations — routes events to use cases, emits states.
class DhikrBloc extends Bloc<DhikrEvent, DhikrState> {
  final GetDhikrs getDhikrs;
  final IncrementCount incrementCount;
  final ResetCount resetCount;
  final SetGoal setGoal;
  final AddCustomDhikr addCustomDhikr;
  final DhikrRepository repository;

  DhikrBloc({
    required this.getDhikrs,
    required this.incrementCount,
    required this.resetCount,
    required this.setGoal,
    required this.addCustomDhikr,
    required this.repository,
  }) : super(DhikrInitial()) {
    on<LoadDhikrs>(_onLoadDhikrs);
    on<IncrementDhikr>(_onIncrementDhikr);
    on<ResetDhikr>(_onResetDhikr);
    on<SetGoalEvent>(_onSetGoal);
    on<AddCustomDhikrEvent>(_onAddCustomDhikr);
    on<SelectDhikr>(_onSelectDhikr);
    on<DeleteDhikr>(_onDeleteDhikr);
  }

  Future<void> _onLoadDhikrs(
    LoadDhikrs event,
    Emitter<DhikrState> emit,
  ) async {
    emit(DhikrLoading());
    try {
      final dhikrs = await getDhikrs();
      if (dhikrs.isEmpty) {
        emit(const DhikrError('No dhikrs found'));
        return;
      }
      emit(DhikrLoaded(dhikrs: dhikrs, selectedId: dhikrs.first.id));
    } catch (e) {
      emit(DhikrError('Failed to load dhikrs: $e'));
    }
  }

  Future<void> _onIncrementDhikr(
    IncrementDhikr event,
    Emitter<DhikrState> emit,
  ) async {
    if (state is! DhikrLoaded) return;
    final currentState = state as DhikrLoaded;
    try {
      await incrementCount(event.id);
      final updatedDhikrs = await getDhikrs();
      emit(DhikrLoaded(
        dhikrs: updatedDhikrs,
        selectedId: currentState.selectedId,
      ));
    } catch (e) {
      emit(DhikrError('Failed to increment: $e'));
    }
  }

  Future<void> _onResetDhikr(
    ResetDhikr event,
    Emitter<DhikrState> emit,
  ) async {
    if (state is! DhikrLoaded) return;
    final currentState = state as DhikrLoaded;
    try {
      await resetCount(event.id);
      final updatedDhikrs = await getDhikrs();
      emit(DhikrLoaded(
        dhikrs: updatedDhikrs,
        selectedId: currentState.selectedId,
      ));
    } catch (e) {
      emit(DhikrError('Failed to reset: $e'));
    }
  }

  Future<void> _onSetGoal(
    SetGoalEvent event,
    Emitter<DhikrState> emit,
  ) async {
    if (state is! DhikrLoaded) return;
    final currentState = state as DhikrLoaded;
    try {
      await setGoal(event.id, event.target);
      final updatedDhikrs = await getDhikrs();
      emit(DhikrLoaded(
        dhikrs: updatedDhikrs,
        selectedId: currentState.selectedId,
      ));
    } catch (e) {
      emit(DhikrError('Failed to set goal: $e'));
    }
  }

  Future<void> _onAddCustomDhikr(
    AddCustomDhikrEvent event,
    Emitter<DhikrState> emit,
  ) async {
    if (state is! DhikrLoaded) return;
    try {
      final newDhikr = await addCustomDhikr(event.name, event.target);
      final updatedDhikrs = await getDhikrs();
      emit(DhikrLoaded(
        dhikrs: updatedDhikrs,
        selectedId: newDhikr.id,
      ));
    } catch (e) {
      emit(DhikrError('Failed to add dhikr: $e'));
    }
  }

  Future<void> _onSelectDhikr(
    SelectDhikr event,
    Emitter<DhikrState> emit,
  ) async {
    if (state is! DhikrLoaded) return;
    final currentState = state as DhikrLoaded;
    emit(DhikrLoaded(
      dhikrs: currentState.dhikrs,
      selectedId: event.id,
    ));
  }

  Future<void> _onDeleteDhikr(
    DeleteDhikr event,
    Emitter<DhikrState> emit,
  ) async {
    if (state is! DhikrLoaded) return;
    final currentState = state as DhikrLoaded;
    try {
      await repository.deleteDhikr(event.id);
      final updatedDhikrs = await getDhikrs();
      if (updatedDhikrs.isEmpty) {
        emit(const DhikrError('No dhikrs remaining'));
        return;
      }
      final newSelectedId = currentState.selectedId == event.id
          ? updatedDhikrs.first.id
          : currentState.selectedId;
      emit(DhikrLoaded(
        dhikrs: updatedDhikrs,
        selectedId: newSelectedId,
      ));
    } catch (e) {
      emit(DhikrError('Failed to delete: $e'));
    }
  }
}
