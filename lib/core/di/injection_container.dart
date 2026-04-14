import 'package:get_it/get_it.dart';
import 'package:zikermate/data/datasources/hive_local_datasource.dart';
import 'package:zikermate/data/repositories/dhikr_repository_impl.dart';
import 'package:zikermate/domain/repositories/dhikr_repository.dart';
import 'package:zikermate/domain/usecases/get_dhikrs.dart';
import 'package:zikermate/domain/usecases/increment_count.dart';
import 'package:zikermate/domain/usecases/reset_count.dart';
import 'package:zikermate/domain/usecases/set_goal.dart';
import 'package:zikermate/domain/usecases/add_custom_dhikr.dart';
import 'package:zikermate/presentation/bloc/dhikr_bloc.dart';

/// GetIt dependency injection container — wires together all layers of Clean Architecture.
final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Data Sources ──
  sl.registerLazySingleton<HiveLocalDataSource>(() => HiveLocalDataSource());

  // ── Repositories ──
  sl.registerLazySingleton<DhikrRepository>(
    () => DhikrRepositoryImpl(sl<HiveLocalDataSource>()),
  );

  // ── Use Cases ──
  sl.registerLazySingleton(() => GetDhikrs(sl<DhikrRepository>()));
  sl.registerLazySingleton(() => IncrementCount(sl<DhikrRepository>()));
  sl.registerLazySingleton(() => ResetCount(sl<DhikrRepository>()));
  sl.registerLazySingleton(() => SetGoal(sl<DhikrRepository>()));
  sl.registerLazySingleton(() => AddCustomDhikr(sl<DhikrRepository>()));

  // ── BLoC (factory = new instance per widget tree) ──
  sl.registerFactory(() => DhikrBloc(
        getDhikrs: sl<GetDhikrs>(),
        incrementCount: sl<IncrementCount>(),
        resetCount: sl<ResetCount>(),
        setGoal: sl<SetGoal>(),
        addCustomDhikr: sl<AddCustomDhikr>(),
        repository: sl<DhikrRepository>(),
      ));
}
