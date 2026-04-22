// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PROJECT GTG';

  @override
  String get navHome => 'Home';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navSettings => 'Settings';

  @override
  String get dashboardTitle => 'Today\'s Routine';

  @override
  String get dashboardSubtitle =>
      'Not perfect, just frequent. One set at a time.';

  @override
  String activeDaysPill(int count) {
    return 'Active $count days';
  }

  @override
  String get quickLogTitle => 'Quick Log';

  @override
  String get quickLogHelper => 'Adjust reps, then tap Record.';

  @override
  String get decreaseValue => 'Decrease';

  @override
  String get increaseValue => 'Increase';

  @override
  String get reset => 'Reset';

  @override
  String get record => 'Log';

  @override
  String get loadingLogs => 'Loading logs...';

  @override
  String get recentLogsTitle => 'Recent Logs';

  @override
  String get noLogsHint => 'No logs yet. Log your first set above.';

  @override
  String get noLogsHintHome => 'No logs yet. Log a set on Home.';

  @override
  String get calendarTitle => 'Rhythm Calendar';

  @override
  String get calendarSubtitleHeatmap =>
      'Darker cells mean more reps. Monthly heatmap.';

  @override
  String get today => 'Today';

  @override
  String get prevMonthTooltip => 'Previous month';

  @override
  String get nextMonthTooltip => 'Next month';

  @override
  String get monthTotalLabel => 'Month total';

  @override
  String get activeDaysLabel => 'Active days';

  @override
  String dayTotal(int count) {
    return 'Day total $count reps';
  }

  @override
  String get noLogsForDay => 'No logs for this day. Log a set on Home.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSubtitle =>
      'Choose app appearance. Applied immediately.';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersSubtitle => 'Set interval, quiet hours, and weekends off';

  @override
  String get settingsCoachTitle => 'GTG Coach';

  @override
  String get settingsCoachSubtitle =>
      'Your max reps, GTG recommendation, and today\'s plan';

  @override
  String get allLogsTitle => 'All Logs';

  @override
  String get allLogsSubtitle => 'Browse by date and exercise';

  @override
  String get aboutTitle => 'About';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Ads and data usage';

  @override
  String get invalidLink => 'Invalid link.';

  @override
  String get cannotOpenBrowser => 'Couldn\'t open the browser.';

  @override
  String get openExternalFailed => 'Couldn\'t open.';

  @override
  String get appUpdateTitle => 'Update available';

  @override
  String appUpdateBody(String version) {
    return 'A newer version ($version) is available. Update now for the latest improvements.';
  }

  @override
  String get appUpdateLater => 'Later';

  @override
  String get appUpdateNow => 'Update';

  @override
  String get remindersHeadline => 'Quiet and consistent';

  @override
  String get remindersSubheadline =>
      'We only schedule within the time left today.';

  @override
  String get enableRemindersTitle => 'Enable reminders';

  @override
  String get enableRemindersOffSubtitle => 'Turn it on only when you want.';

  @override
  String get enableRemindersNoSlotsSubtitle =>
      'No time slots available. Check quiet hours/weekends off.';

  @override
  String enableRemindersNextScheduledSubtitle(String time, int count) {
    return 'Next $time · $count scheduled';
  }

  @override
  String get scheduleSectionTitle => 'Schedule';

  @override
  String get intervalLabel => 'Interval';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get maxPerDayLabel => 'Max per day';

  @override
  String get quietHoursTitle => 'Quiet hours';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'End';

  @override
  String get weekendsOffTitle => 'Weekends off';

  @override
  String get weekendsOffSubtitle => 'No schedules on Sat/Sun';

  @override
  String get silentNotificationsInfo => 'Notifications are silent.';

  @override
  String get permissionDenied =>
      'Notification permission is required. Enable it in Settings.';

  @override
  String get openSettings => 'Settings';

  @override
  String pickTimeHelp(String label) {
    return 'Select $label time';
  }

  @override
  String tomorrowAt(String time) {
    return 'Tomorrow $time';
  }

  @override
  String get onboardingLater => 'Later';

  @override
  String get onboardingSubtitle =>
      'Not perfect, just frequent. Start in 1 minute.';

  @override
  String get onboardingQuestion => 'Which move will you focus on?';

  @override
  String get onboardingHint => 'Your primary move shows first on Home.';

  @override
  String get onboardingBaselineTitle => 'Optional max reps';

  @override
  String get onboardingBaselineSubtitle =>
      'Add it now or skip it. GTG Coach can use it for a lighter recommendation later.';

  @override
  String get onboardingBaselineFieldLabel => 'Current clean max reps';

  @override
  String get onboardingBaselineFieldHint =>
      'Skip this if you want. You can add it later in GTG Coach.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingPushUpSubtitle => 'Fastest routine. Start anywhere.';

  @override
  String get onboardingPullUpSubtitle => 'Pulling strength. Form matters.';

  @override
  String get onboardingDipsSubtitle => 'Push strength. Watch your shoulders.';

  @override
  String get coachFocusTitle => 'Focus move';

  @override
  String get coachFocusSubtitle =>
      'Keep your primary move fresh and repeatable.';

  @override
  String get coachFocusMoveLabel => 'Primary move';

  @override
  String get coachRecommendedRepsLabel => 'Recommended GTG reps';

  @override
  String get coachRecommendedHint =>
      'About half of your max so each set stays well below failure.';

  @override
  String get coachLastTestedLabel => 'Last max test';

  @override
  String get coachLastTestedNever => 'Not yet';

  @override
  String get coachBaselineTitle => 'Baseline';

  @override
  String get coachBaselineSubtitle =>
      'Set your current max and the number of daily practice sets.';

  @override
  String get coachBaselineLabel => 'Current max reps';

  @override
  String get coachDailySetGoalLabel => 'Daily set goal';

  @override
  String get coachPlanTitle => 'Today\'s plan';

  @override
  String get coachPlanSubtitle =>
      'Progress is counted from today\'s logs for your primary move.';

  @override
  String get coachTodayLabel => 'Today';

  @override
  String get coachCardReadySubtitle => 'Today\'s GTG suggestion and progress';

  @override
  String get coachCardSetupSubtitle =>
      'Add your max reps to get a lighter GTG suggestion';

  @override
  String get coachSetBaselineAction => 'Add max';

  @override
  String get coachAdjustAction => 'Adjust';

  @override
  String get coachSetupHint =>
      'Save your current max for your focus move. Home will suggest a lighter GTG set and track today\'s progress.';

  @override
  String get coachNotSet => 'Not set';

  @override
  String get coachRetestDueMessage =>
      'It has been over 2 weeks. Recheck your max and refresh the recommendation.';

  @override
  String coachQuickLogRecommended(int count) {
    return 'GTG $count reps';
  }

  @override
  String coachTodayProgress(int done, int target) {
    return '$done/$target sets';
  }

  @override
  String coachRemainingSets(int count) {
    return '$count sets left today';
  }

  @override
  String coachSetsShort(int count) {
    return '$count sets';
  }

  @override
  String get splashTapToSkip => 'Tap to skip';

  @override
  String get exercisePushUp => 'Push-ups';

  @override
  String get exercisePullUp => 'Pull-ups';

  @override
  String get exerciseDips => 'Dips';

  @override
  String repsWithUnit(int count) {
    return '$count reps';
  }

  @override
  String daysWithUnit(int count) {
    return '$count days';
  }

  @override
  String get notifTitle => 'Time for a set';

  @override
  String get notifBody =>
      'Do one set: push-ups, pull-ups, or dips. Keep your rhythm today.';
}
