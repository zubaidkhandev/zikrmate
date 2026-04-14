import 'package:zikermate/domain/entities/dhikr_entity.dart';
import 'package:zikermate/domain/repositories/dhikr_repository.dart';

/// Use case to update a dhikr's target count (daily goal) and persist the change.
class SetGoal {
  final DhikrRepository repository;

  SetGoal(this.repository);

  Future<DhikrEntity> call(String id, int target) async {
    final dhikrs = await repository.getDhikrs();
    final dhikr = dhikrs.firstWhere((d) => d.id == id);
    final updated = dhikr.copyWith(targetCount: target);
    await repository.saveDhikr(updated);
    return updated;
  }
}
