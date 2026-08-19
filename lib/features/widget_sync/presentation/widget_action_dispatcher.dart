import 'package:home_widget/home_widget.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/exercise_type.dart';
import '../../../data/isar/entities/exercise_log_entity.dart';
import '../../../data/isar/isar_database.dart';
import '../../../data/persistence/directory_provider.dart';
import '../application/widget_sync_service.dart';
import '../domain/widget_data_model.dart';

/// Top-level callback triggered by Native (iOS/Android) when a widget button is pressed.
/// This runs in a separate background isolate and does NOT share memory with the main app isolate.
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;

  // The URI scheme is expected to be something like: gtgwidget://log?type=pushUp&reps=1
  if (uri.host == 'log') {
    final typeStr = uri.queryParameters['type'];
    final repsStr = uri.queryParameters['reps'];

    if (typeStr == null || repsStr == null) return;

    final type = ExerciseTypeX.fromKey(typeStr);
    final reps = int.tryParse(repsStr) ?? 1;

    // 1. Initialize DB in background isolate
    final directoryProvider = DefaultDirectoryProvider();
    final db = IsarDatabase(directoryProvider: directoryProvider);
    final isar = await db.open();

    try {
      // 2. Save new log
      final now = DateTime.now();
      final newLog = ExerciseLogEntity()
        ..logId = const Uuid().v4()
        ..typeKey = type.key
        ..reps = reps
        ..timestamp = now;

      await isar.writeTxn(() async {
        await isar.exerciseLogEntitys.put(newLog);
      });

      // 3. Re-calculate today's total for the widget (simple query)
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Isar doesn't support complex aggregations natively, so we fetch today's logs for this type
      final todayLogs = await isar.exerciseLogEntitys
          .filter()
          .typeKeyEqualTo(type.key)
          .timestampBetween(startOfDay, endOfDay, includeLower: true, includeUpper: false)
          .findAll();

      final todayTotal = todayLogs.fold<int>(0, (int sum, ExerciseLogEntity log) => sum + log.reps);

      // We might not have the full coaching target logic in background, so we use a fallback or fetch from prefs.
      // For now, we update the todayTotal which is the most critical feedback for the user.
      final widgetData = WidgetDataModel(
        todayTotal: todayTotal,
        targetTotal: 0, // Placeholder, can be synced from main app later
        primaryExercise: type,
      );

      // 4. Sync updated data to OS and trigger widget render
      await WidgetSyncService.syncData(widgetData);
    } finally {
      // Clean up Isar in background isolate
      await db.close();
    }
  }
}

/// Helper to register the background callback. Called from main.dart.
Future<void> registerWidgetDispatcher() async {
  await WidgetSyncService.initialize();
  await HomeWidget.registerInteractivityCallback(backgroundCallback);
}
