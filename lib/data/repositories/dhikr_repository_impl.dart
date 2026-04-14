import 'package:zikermate/data/datasources/hive_local_datasource.dart';
import 'package:zikermate/data/models/dhikr_model.dart';
import 'package:zikermate/domain/entities/dhikr_entity.dart';
import 'package:zikermate/domain/repositories/dhikr_repository.dart';

/// Concrete implementation of DhikrRepository — bridges domain entities and Hive models.
class DhikrRepositoryImpl implements DhikrRepository {
  final HiveLocalDataSource localDataSource;

  DhikrRepositoryImpl(this.localDataSource);

  @override
  Future<List<DhikrEntity>> getDhikrs() async {
    final models = await localDataSource.getAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<void> saveDhikr(DhikrEntity dhikr) async {
    await localDataSource.save(_toModel(dhikr));
  }

  @override
  Future<void> deleteDhikr(String id) async {
    await localDataSource.delete(id);
  }

  DhikrEntity _toEntity(DhikrModel model) {
    return DhikrEntity(
      id: model.id,
      name: model.name,
      currentCount: model.currentCount,
      targetCount: model.targetCount,
    );
  }

  DhikrModel _toModel(DhikrEntity entity) {
    return DhikrModel(
      id: entity.id,
      name: entity.name,
      currentCount: entity.currentCount,
      targetCount: entity.targetCount,
    );
  }
}
