import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/logging/app_logger.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/json_file_store.dart';
import 'package:project_gtg/data/persistence/persistence_constants.dart';

class _FakeDirectoryProvider implements DirectoryProvider {
  _FakeDirectoryProvider(this.dir);

  final Directory dir;

  @override
  Future<Directory> getApplicationSupportDirectory() async => dir;
}

class _SpyLogger implements AppLogger {
  final List<String> infos = <String>[];
  final List<String> warnings = <String>[];
  final List<String> errors = <String>[];

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    errors.add(message);
  }

  @override
  void info(String message) {
    infos.add(message);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    warnings.add(message);
  }
}

void main() {
  test('writeJson persists data and cleans temporary file', () async {
    final tmp = await Directory.systemTemp.createTemp('json_store_test_');
    addTearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    final logger = _SpyLogger();
    final store = JsonFileStore(
      directoryProvider: _FakeDirectoryProvider(tmp),
      logger: logger,
    );

    await store.writeJson('sample.json', <String, Object?>{'value': 1});
    final raw = await store.readJson('sample.json');

    expect(raw, isA<Map<String, dynamic>>());
    expect((raw as Map<String, dynamic>)['value'], 1);

    final appDir = Directory(
      '${tmp.path}/${PersistenceConstants.appDirectoryName}',
    );
    final tmpFiles = appDir
        .listSync()
        .whereType<File>()
        .where(
          (file) => file.path.endsWith(PersistenceConstants.temporarySuffix),
        )
        .toList();
    expect(tmpFiles, isEmpty);
    expect(logger.errors, isEmpty);
  });

  test('readJson quarantines corrupted files and returns null', () async {
    final tmp = await Directory.systemTemp.createTemp('json_store_test_');
    addTearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    final logger = _SpyLogger();
    final fixedNow = DateTime(2026, 2, 20, 10, 30, 0);
    final store = JsonFileStore(
      directoryProvider: _FakeDirectoryProvider(tmp),
      logger: logger,
      nowProvider: () => fixedNow,
    );

    final appDir = Directory(
      '${tmp.path}/${PersistenceConstants.appDirectoryName}',
    );
    await appDir.create(recursive: true);
    final corruptedFile = File('${appDir.path}/sample.json');
    await corruptedFile.writeAsString('{invalid');

    final raw = await store.readJson('sample.json');
    expect(raw, isNull);
    expect(logger.warnings, isNotEmpty);

    final quarantined = appDir
        .listSync()
        .whereType<File>()
        .where(
          (file) => file.path.contains(
            'sample.json${PersistenceConstants.corruptedSuffix}',
          ),
        )
        .toList();

    expect(quarantined.length, 1);
    expect(await corruptedFile.exists(), isFalse);
  });
}
