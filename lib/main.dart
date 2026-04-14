import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:zikermate/core/di/injection_container.dart';
import 'package:zikermate/core/theme/app_theme.dart';
import 'package:zikermate/core/utils/constants.dart';
import 'package:zikermate/data/datasources/hive_local_datasource.dart';
import 'package:zikermate/data/models/dhikr_model.dart';
import 'package:zikermate/presentation/bloc/dhikr_bloc.dart';
import 'package:zikermate/presentation/bloc/dhikr_event.dart';
import 'package:zikermate/presentation/screens/home_screen.dart';

/// App entry point — initializes Hive, timezone, DI, seeds defaults, and launches the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DhikrModelAdapter());

  // Initialize timezone for scheduled notifications
  tz.initializeTimeZones();

  // Setup dependency injection
  await setupDependencies();

  // Seed default dhikrs on first launch
  await _seedDefaults();

  runApp(const ZikarApp());
}

/// Seeds the default dhikr list into Hive if no data exists yet.
Future<void> _seedDefaults() async {
  final dataSource = sl<HiveLocalDataSource>();
  if (await dataSource.isEmpty()) {
    for (final dhikr in AppConstants.defaultDhikrs) {
      await dataSource.save(DhikrModel(
        id: dhikr.id,
        name: dhikr.name,
        currentCount: dhikr.currentCount,
        targetCount: dhikr.targetCount,
      ));
    }
  }
}

/// Root widget — provides the DhikrBloc to the entire widget tree.
class ZikarApp extends StatelessWidget {
  const ZikarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DhikrBloc>()..add(LoadDhikrs()),
      child: MaterialApp(
        title: 'ZikarMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
