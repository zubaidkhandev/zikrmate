import 'package:zikermate/domain/entities/dhikr_entity.dart';
import 'package:zikermate/domain/repositories/dhikr_repository.dart';

/// Use case to reset a dhikr's counter back to zero and persist the change.
class ResetCount {
  final DhikrRepository repository;

  ResetCount(this.repository);

  Future<DhikrEntity> call(String id) async {
    final dhikrs = await repository.getDhikrs();
    final dhikr = dhikrs.firstWhere((d) => d.id == id);
    final updated = dhikr.copyWith(currentCount: 0);
    await repository.saveDhikr(updated);
    return updated;
  }
}
