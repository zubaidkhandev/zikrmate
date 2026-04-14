import 'package:hive/hive.dart';

part 'dhikr_model.g.dart';

/// Hive-persistent model for a dhikr entry — maps to/from the domain DhikrEntity.
@HiveType(typeId: 0)
class DhikrModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int currentCount;

  @HiveField(3)
  final int targetCount;

  DhikrModel({
    required this.id,
    required this.name,
    this.currentCount = 0,
    this.targetCount = 33,
  });
}
