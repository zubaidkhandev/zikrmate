import 'package:zikermate/domain/entities/dhikr_entity.dart';

/// Abstract repository interface — domain layer defines what it needs, data layer implements it.
abstract class DhikrRepository {
  Future<List<DhikrEntity>> getDhikrs();
  Future<void> saveDhikr(DhikrEntity dhikr);
  Future<void> deleteDhikr(String id);
}
