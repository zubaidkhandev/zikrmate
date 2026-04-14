import 'package:zikermate/domain/entities/dhikr_entity.dart';
import 'package:zikermate/domain/repositories/dhikr_repository.dart';

/// Use case to increment a dhikr's counter by 1 and persist the change.
class IncrementCount {
  final DhikrRepository repository;

  IncrementCount(this.repository);

  Future<DhikrEntity> call(String id) async {
    final dhikrs = await repository.getDhikrs();
    final dhikr = dhikrs.firstWhere((d) => d.id == id);
    final updated = dhikr.copyWith(currentCount: dhikr.currentCount + 1);
    await repository.saveDhikr(updated);
    return updated;
  }
}
