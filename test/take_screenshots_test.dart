import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/app/gtg_app.dart';
import 'package:project_gtg/core/models/app_theme_preference.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/models/user_preferences.dart';

class _DummyDirProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory('/tmp');
  }
}

class _ScreenshotPersistence extends GtgPersistence {
  _ScreenshotPersistence() : super(directoryProvider: _DummyDirProvider());

  @override
  Future<List<ExerciseLog>> loadLogs() async {
    final now = DateTime.now();
    return [
      ExerciseLog(id: '1', type: ExerciseType.pushUp, reps: 15, timestamp: now),
      ExerciseLog(
        id: '2',
        type: ExerciseType.pullUp,
        reps: 5,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  @override
  Future<UserPreferences> loadUserPreferences() async => UserPreferences(
    hasCompletedOnboarding: true,
    primaryExercise: ExerciseType.pushUp,
  );

  @override
  Future<AppThemePreference> loadAppThemePreference() async =>
      AppThemePreference.dark;

  @override
  Future<ReminderSettings> loadReminderSettings() async =>
      ReminderSettings.defaults;
}

void main() {
  testWidgets(
    'take screenshots',
    skip: !const bool.fromEnvironment('SMOKE_SCREENSHOTS'),
    (tester) async {
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(1080, 2400);

      final persistence = _ScreenshotPersistence();
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: ProviderScope(
            overrides: [persistenceProvider.overrideWithValue(persistence)],
            child: const GtgApp(locale: Locale('en')),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      Future<void> capture(String name) async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.0);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('real_screenshots');
        if (!dir.existsSync()) dir.createSync();
        File(
          'real_screenshots/$name.png',
        ).writeAsBytesSync(data!.buffer.asUint8List());
      }

      await capture('1_home');

      await tester.tap(find.byIcon(Icons.calendar_month_rounded));
      await tester.pump(const Duration(seconds: 1));
      await capture('2_calendar');

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pump(const Duration(seconds: 1));
      await capture('3_settings');
    },
  );
}
