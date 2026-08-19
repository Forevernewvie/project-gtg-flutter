import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/features/workout/presentation/exercise_ui_style.dart';

void main() {
  test('GPT-generated exercise icon assets are registered and present', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/exercise_icons/'));

    for (final type in ExerciseType.values) {

      final path = ExerciseUiStyle.assetPath(type);
      final file = File(path);

      expect(path, startsWith('assets/exercise_icons/'));
      expect(file.existsSync(), isTrue, reason: '$path should exist');
      expect(
        file.lengthSync(),
        greaterThan(0),
        reason: '$path should not be empty',
      );
    }
  });
}
