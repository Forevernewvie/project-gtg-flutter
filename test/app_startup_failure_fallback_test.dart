import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/app/gtg_app.dart';
import 'package:project_gtg/core/models/app_theme_preference.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';

class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory('/tmp');
  }
}

class _ThrowingStartupPersistence extends GtgPersistence {
  _ThrowingStartupPersistence()
    : super(directoryProvider: _DummyDirectoryProvider());

  @override
  Future<AppThemePreference> loadAppThemePreference() async {
    throw StateError('theme-load-failed');
  }

  @override
  Future<UserPreferences> loadUserPreferences() async {
    throw StateError('prefs-load-failed');
  }

  @override
  Future<List<ExerciseLog>> loadLogs() async {
    throw StateError('logs-load-failed');
  }

  @override
  Future<ReminderSettings> loadReminderSettings() async {
    return ReminderSettings.defaults;
  }
}

void main() {
  testWidgets('app cold-start survives startup persistence failures', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(_ThrowingStartupPersistence()),
        ],
        child: const GtgApp(locale: Locale('en')),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
