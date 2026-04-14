import 'package:uuid/uuid.dart';
import 'package:zikermate/domain/entities/dhikr_entity.dart';
import 'package:zikermate/domain/repositories/dhikr_repository.dart';

/// Use case to create a new custom dhikr entry with a unique ID and persist it.
class AddCustomDhikr {
  final DhikrRepository repository;

  AddCustomDhikr(this.repository);

  Future<DhikrEntity> call(String name, int target) async {
    final entity = DhikrEntity(
      id: const Uuid().v4(),
      name: name,
      currentCount: 0,
      targetCount: target,
    );
    await repository.saveDhikr(entity);
    return entity;
  }
}
