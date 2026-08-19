import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/features/widget_sync/domain/widget_data_model.dart';

void main() {
  group('WidgetDataModel', () {
    test('toMap converts data correctly', () {
      const model = WidgetDataModel(
        todayTotal: 42,
        targetTotal: 100,
        primaryExercise: ExerciseType.pullUp,
      );

      final map = model.toMap();

      expect(map['gtg_today_total'], 42);
      expect(map['gtg_target_total'], 100);
      expect(map['gtg_primary_exercise'], 'pullUp');
    });

    test('toMap handles boundary values', () {
      const model = WidgetDataModel(
        todayTotal: 0,
        targetTotal: 0,
        primaryExercise: ExerciseType.pushUp,
      );

      final map = model.toMap();

      expect(map['gtg_today_total'], 0);
      expect(map['gtg_target_total'], 0);
      expect(map['gtg_primary_exercise'], 'pushUp');
    });
  });
}
