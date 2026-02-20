import 'dart:convert';
import 'dart:io';

import '../../core/logging/app_logger.dart';
import 'directory_provider.dart';
import 'persistence_constants.dart';

/// Handles low-level JSON file IO with atomic write and corruption quarantine.
class JsonFileStore {
  JsonFileStore({
    required DirectoryProvider directoryProvider,
    required AppLogger logger,
    DateTime Function()? nowProvider,
  }) : _directoryProvider = directoryProvider,
       _logger = logger,
       _nowProvider = nowProvider ?? DateTime.now;

  final DirectoryProvider _directoryProvider;
  final AppLogger _logger;
  final DateTime Function() _nowProvider;

  /// Reads and decodes JSON from [fileName], returning null for missing files.
  Future<Object?> readJson(String fileName) async {
    final file = await _resolveFile(fileName);
    if (!await file.exists()) return null;

    try {
      final raw = await file.readAsString();
      return jsonDecode(raw);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to decode JSON. Moving file to quarantine.',
        error: error,
        stackTrace: stackTrace,
      );
      await _quarantineCorruptedFile(file);
      return null;
    }
  }

  /// Writes [payload] to [fileName] using a temporary file + rename strategy.
  Future<void> writeJson(String fileName, Object payload) async {
    final file = await _resolveFile(fileName);
    final tmp = File('${file.path}${PersistenceConstants.temporarySuffix}');
    final encoded = const JsonEncoder.withIndent('  ').convert(payload);

    try {
      await tmp.writeAsString(encoded, flush: true);

      if (await file.exists()) {
        await file.delete();
      }

      await tmp.rename(file.path);
    } catch (error, stackTrace) {
      _logger.error(
        'Atomic JSON write failed.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      if (await tmp.exists()) {
        await tmp.delete();
      }
    }
  }

  /// Resolves [fileName] inside the app-specific persistence directory.
  Future<File> _resolveFile(String fileName) async {
    final base = await _directoryProvider.getApplicationSupportDirectory();
    final appDir = Directory(
      '${base.path}/${PersistenceConstants.appDirectoryName}',
    );
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File('${appDir.path}/$fileName');
  }

  /// Moves corrupted file content out of the happy path for safe recovery.
  Future<void> _quarantineCorruptedFile(File file) async {
    if (!await file.exists()) return;

    final timestamp = _nowProvider().toIso8601String().replaceAll(':', '-');
    final backupPath =
        '${file.path}${PersistenceConstants.corruptedSuffix}$timestamp';
    final backupFile = File(backupPath);

    try {
      await file.rename(backupFile.path);
    } catch (error, stackTrace) {
      _logger.warning(
        'Unable to quarantine corrupted file.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
