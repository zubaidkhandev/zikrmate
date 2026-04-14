import 'package:zikermate/domain/entities/dhikr_entity.dart';
import 'package:zikermate/domain/repositories/dhikr_repository.dart';

/// Use case to fetch all saved dhikr entries from the repository.
class GetDhikrs {
  final DhikrRepository repository;

  GetDhikrs(this.repository);

  Future<List<DhikrEntity>> call() async {
    return await repository.getDhikrs();
  }
}
