import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';

class FakeDirectoryProvider implements DirectoryProvider {
  FakeDirectoryProvider(this.dir);

  final Directory dir;

  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return dir;
  }
}

void main() {
  test('corrupted JSON is quarantined and load returns defaults', () async {
    final tmp = await Directory.systemTemp.createTemp('gtg_persist_test_');
    addTearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    final persistence = GtgPersistence(
      directoryProvider: FakeDirectoryProvider(tmp),
    );

    // Create an invalid JSON file.
    final projectDir = Directory('${tmp.path}/ProjectGTG');
    await projectDir.create(recursive: true);
    final logsFile = File('${projectDir.path}/exercise_logs.json');
    await logsFile.writeAsString('{not json');

    final logs = await persistence.loadLogs();
    expect(logs, isEmpty);

    final quarantined = projectDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('exercise_logs.json.corrupted-'))
        .toList();

    expect(quarantined.length, 1);
  });
}
