/// Pure domain entity representing a single dhikr — no package dependencies.
class DhikrEntity {
  final String id;
  final String name;
  final int currentCount;
  final int targetCount;

  const DhikrEntity({
    required this.id,
    required this.name,
    this.currentCount = 0,
    this.targetCount = 33,
  });

  DhikrEntity copyWith({
    String? id,
    String? name,
    int? currentCount,
    int? targetCount,
  }) {
    return DhikrEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount ?? this.targetCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          currentCount == other.currentCount &&
          targetCount == other.targetCount;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ currentCount.hashCode ^ targetCount.hashCode;

  @override
  String toString() =>
      'DhikrEntity(id: $id, name: $name, count: $currentCount/$targetCount)';
}
