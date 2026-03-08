import '../../core/date_utils.dart';
import '../../core/models/exercise_log.dart';
import '../workout/services/workout_analytics_service.dart';

/// Immutable presentation model for the calendar screen.
final class CalendarViewModel {
  /// Creates a presentation model for the currently visible month and selected day.
  const CalendarViewModel({
    required this.today,
    required this.visibleMonth,
    required this.monthStart,
    required this.monthEnd,
    required this.selectedDay,
    required this.monthSummary,
    required this.selectedSummary,
  });

  final DateTime today;
  final DateTime visibleMonth;
  final DateTime monthStart;
  final DateTime monthEnd;
  final DateTime selectedDay;
  final MonthWorkoutSummary monthSummary;
  final DayWorkoutSummary selectedSummary;

  /// Builds a calendar presentation model from raw logs, clock state, and month selection.
  factory CalendarViewModel.create({
    required List<ExerciseLog> logs,
    required WorkoutAnalyticsService analyticsService,
    required DateTime visibleMonth,
    required DateTime selectedDay,
    required DateTime now,
  }) {
    final normalizedVisibleMonth = startOfMonth(visibleMonth);
    final monthStart = DateTime(
      normalizedVisibleMonth.year,
      normalizedVisibleMonth.month,
      1,
    );
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);
    final clampedSelectedDay =
        (selectedDay.isBefore(monthStart) || !selectedDay.isBefore(monthEnd))
        ? monthStart
        : startOfDay(selectedDay);

    final monthSummary = analyticsService.summarizeMonth(
      logs,
      normalizedVisibleMonth,
    );
    final selectedSummary = analyticsService.summarizeDay(
      logs,
      clampedSelectedDay,
    );

    return CalendarViewModel(
      today: startOfDay(now),
      visibleMonth: normalizedVisibleMonth,
      monthStart: monthStart,
      monthEnd: monthEnd,
      selectedDay: clampedSelectedDay,
      monthSummary: monthSummary,
      selectedSummary: selectedSummary,
    );
  }
}
