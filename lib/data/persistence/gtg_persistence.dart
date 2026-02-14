import 'dart:convert';
import 'dart:io';

import '../../core/models/exercise_log.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/models/user_preferences.dart';
import 'directory_provider.dart';

class GtgPersistence {
  GtgPersistence({DirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? DefaultDirectoryProvider();

  final DirectoryProvider _directoryProvider;

  Future<Directory> _appDir() async {
    final base = await _directoryProvider.getApplicationSupportDirectory();
    final dir = Directory('${base.path}/ProjectGTG');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _file(String fileName) async {
    final dir = await _appDir();
    return File('${dir.path}/$fileName');
  }

  Future<List<ExerciseLog>> loadLogs() async {
    final file = await _file('exercise_logs.json');
    final raw = await _readJson(file);
    if (raw == null) return <ExerciseLog>[];

    if (raw is! List) return <ExerciseLog>[];

    final logs = <ExerciseLog>[];
    for (final item in raw) {
      if (item is Map) {
        final map = item.map((k, v) => MapEntry('$k', v));
        logs.add(ExerciseLog.fromJson(map));
      }
    }
    return logs;
  }

  Future<void> saveLogs(List<ExerciseLog> logs) async {
    final file = await _file('exercise_logs.json');
    final payload = logs.map((e) => e.toJson()).toList(growable: false);
    await _writeJson(file, payload);
  }

  Future<ReminderSettings> loadReminderSettings() async {
    final file = await _file('reminder_settings.json');
    final raw = await _readJson(file);
    if (raw is Map) {
      final map = raw.map((k, v) => MapEntry('$k', v));
      return ReminderSettings.fromJson(map);
    }
    return ReminderSettings.defaults;
  }

  Future<void> saveReminderSettings(ReminderSettings settings) async {
    final file = await _file('reminder_settings.json');
    await _writeJson(file, settings.toJson());
  }

  Future<UserPreferences> loadUserPreferences() async {
    final file = await _file('user_preferences.json');
    final raw = await _readJson(file);
    if (raw is Map) {
      final map = raw.map((k, v) => MapEntry('$k', v));
      return UserPreferences.fromJson(map);
    }
    return UserPreferences.defaults;
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final file = await _file('user_preferences.json');
    await _writeJson(file, preferences.toJson());
  }

  Future<Object?> _readJson(File file) async {
    if (!file.existsSync()) return null;

    try {
      final raw = await file.readAsString();
      return jsonDecode(raw);
    } catch (_) {
      await _quarantineCorruptedFile(file);
      return null;
    }
  }

  Future<void> _writeJson(File file, Object payload) async {
    final tmp = File('${file.path}.tmp');
    final json = const JsonEncoder.withIndent('  ').convert(payload);

    await tmp.writeAsString(json, flush: true);

    if (file.existsSync()) {
      await file.delete();
    }

    await tmp.rename(file.path);
  }

  Future<void> _quarantineCorruptedFile(File file) async {
    if (!file.existsSync()) return;

    final iso = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backup = File('${file.path}.corrupted-$iso');

    try {
      await file.rename(backup.path);
    } catch (_) {
      // Best effort; ignore.
    }
  }
}
