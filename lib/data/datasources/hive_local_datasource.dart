import 'package:hive/hive.dart';
import 'package:zikermate/data/models/dhikr_model.dart';

/// Low-level Hive data source — all raw Hive CRUD operations live here.
class HiveLocalDataSource {
  static const String _boxName = 'dhikrs';

  Future<Box<DhikrModel>> get _box async =>
      Hive.isBoxOpen(_boxName)
          ? Hive.box<DhikrModel>(_boxName)
          : await Hive.openBox<DhikrModel>(_boxName);

  Future<List<DhikrModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> save(DhikrModel model) async {
    final box = await _box;
    await box.put(model.id, model);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<bool> isEmpty() async {
    final box = await _box;
    return box.isEmpty;
  }
}
