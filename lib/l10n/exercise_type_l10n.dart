import '../core/models/exercise_type.dart';
import 'app_localizations.dart';

extension ExerciseTypeL10nX on ExerciseType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      ExerciseType.pushUp => l10n.exercisePushUp,
      ExerciseType.pullUp => l10n.exercisePullUp,
      ExerciseType.dips => l10n.exerciseDips,
    };
  }
}
