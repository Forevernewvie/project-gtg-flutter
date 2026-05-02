import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PROJECT GTG'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Routine'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Not perfect, just frequent. One set at a time.'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for today'**
  String get dashboardReadyTitle;

  /// No description provided for @dashboardPrimarySetHint.
  ///
  /// In en, this message translates to:
  /// **'Start with {exercise}: one set of {count} reps.'**
  String dashboardPrimarySetHint(String exercise, int count);

  /// No description provided for @activeDaysPill.
  ///
  /// In en, this message translates to:
  /// **'Active {count} days'**
  String activeDaysPill(int count);

  /// No description provided for @quickLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Log'**
  String get quickLogTitle;

  /// No description provided for @quickLogHelper.
  ///
  /// In en, this message translates to:
  /// **'Adjust reps, then tap Record.'**
  String get quickLogHelper;

  /// No description provided for @decreaseValue.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decreaseValue;

  /// No description provided for @increaseValue.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increaseValue;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get record;

  /// No description provided for @loadingLogs.
  ///
  /// In en, this message translates to:
  /// **'Loading logs...'**
  String get loadingLogs;

  /// No description provided for @recentLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Logs'**
  String get recentLogsTitle;

  /// No description provided for @noLogsHint.
  ///
  /// In en, this message translates to:
  /// **'No logs yet. Log your first set above.'**
  String get noLogsHint;

  /// No description provided for @noLogsHintHome.
  ///
  /// In en, this message translates to:
  /// **'No logs yet. Log a set on Home.'**
  String get noLogsHintHome;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Rhythm Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarSubtitleHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Darker cells mean more reps. Monthly heatmap.'**
  String get calendarSubtitleHeatmap;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @prevMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get prevMonthTooltip;

  /// No description provided for @nextMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonthTooltip;

  /// No description provided for @monthTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Month total'**
  String get monthTotalLabel;

  /// No description provided for @activeDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDaysLabel;

  /// No description provided for @dayTotal.
  ///
  /// In en, this message translates to:
  /// **'Day total {count} reps'**
  String dayTotal(int count);

  /// No description provided for @noLogsForDay.
  ///
  /// In en, this message translates to:
  /// **'No logs for this day. Log a set on Home.'**
  String get noLogsForDay;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app appearance. Applied immediately.'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set interval, quiet hours, and weekends off'**
  String get remindersSubtitle;

  /// No description provided for @settingsCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'GTG Coach'**
  String get settingsCoachTitle;

  /// No description provided for @settingsCoachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your max reps, GTG recommendation, and today\'s plan'**
  String get settingsCoachSubtitle;

  /// No description provided for @allLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Logs'**
  String get allLogsTitle;

  /// No description provided for @allLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse by date and exercise'**
  String get allLogsSubtitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ads and data usage'**
  String get privacyPolicySubtitle;

  /// No description provided for @adPrivacyChoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy choices'**
  String get adPrivacyChoicesTitle;

  /// No description provided for @adPrivacyChoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review ad consent options'**
  String get adPrivacyChoicesSubtitle;

  /// No description provided for @adPrivacyChoicesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy choices aren\'t available right now.'**
  String get adPrivacyChoicesUnavailable;

  /// No description provided for @invalidLink.
  ///
  /// In en, this message translates to:
  /// **'Invalid link.'**
  String get invalidLink;

  /// No description provided for @cannotOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the browser.'**
  String get cannotOpenBrowser;

  /// No description provided for @openExternalFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open.'**
  String get openExternalFailed;

  /// No description provided for @appUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get appUpdateTitle;

  /// No description provided for @appUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'A newer version ({version}) is available. Update now for the latest improvements.'**
  String appUpdateBody(String version);

  /// No description provided for @appUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get appUpdateLater;

  /// No description provided for @appUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get appUpdateNow;

  /// No description provided for @remindersHeadline.
  ///
  /// In en, this message translates to:
  /// **'Quiet and consistent'**
  String get remindersHeadline;

  /// No description provided for @remindersSubheadline.
  ///
  /// In en, this message translates to:
  /// **'We only schedule within the time left today.'**
  String get remindersSubheadline;

  /// No description provided for @enableRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders'**
  String get enableRemindersTitle;

  /// No description provided for @enableRemindersOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn it on only when you want.'**
  String get enableRemindersOffSubtitle;

  /// No description provided for @enableRemindersNoSlotsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No time slots available. Check quiet hours/weekends off.'**
  String get enableRemindersNoSlotsSubtitle;

  /// No description provided for @enableRemindersNextScheduledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Next {time} · {count} scheduled'**
  String enableRemindersNextScheduledSubtitle(String time, int count);

  /// No description provided for @scheduleSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleSectionTitle;

  /// No description provided for @intervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get intervalLabel;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @maxPerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Max per day'**
  String get maxPerDayLabel;

  /// No description provided for @reminderOptimizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Log-based suggestion'**
  String get reminderOptimizationTitle;

  /// No description provided for @reminderOptimizationApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get reminderOptimizationApply;

  /// No description provided for @reminderOptimizationEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn reminders on to rebuild your GTG rhythm.'**
  String get reminderOptimizationEnable;

  /// No description provided for @reminderOptimizationReduceFrequency.
  ///
  /// In en, this message translates to:
  /// **'Your recent rhythm is light. Try a {count}-minute interval.'**
  String reminderOptimizationReduceFrequency(int count);

  /// No description provided for @reminderOptimizationSkipWeekends.
  ///
  /// In en, this message translates to:
  /// **'You rarely log on weekends. Try weekends off.'**
  String get reminderOptimizationSkipWeekends;

  /// No description provided for @reminderOptimizationPreferredTime.
  ///
  /// In en, this message translates to:
  /// **'You often log around {time}. Focus reminders near that window.'**
  String reminderOptimizationPreferredTime(String time);

  /// No description provided for @quietHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get quietHoursTitle;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @endLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLabel;

  /// No description provided for @weekendsOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekends off'**
  String get weekendsOffTitle;

  /// No description provided for @weekendsOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No schedules on Sat/Sun'**
  String get weekendsOffSubtitle;

  /// No description provided for @silentNotificationsInfo.
  ///
  /// In en, this message translates to:
  /// **'Notifications are silent.'**
  String get silentNotificationsInfo;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required. Enable it in Settings.'**
  String get permissionDenied;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// No description provided for @pickTimeHelp.
  ///
  /// In en, this message translates to:
  /// **'Select {label} time'**
  String pickTimeHelp(String label);

  /// No description provided for @tomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow {time}'**
  String tomorrowAt(String time);

  /// No description provided for @onboardingLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get onboardingLater;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Not perfect, just frequent. Start in 1 minute.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which move will you focus on?'**
  String get onboardingQuestion;

  /// No description provided for @onboardingHint.
  ///
  /// In en, this message translates to:
  /// **'Your primary move shows first on Home.'**
  String get onboardingHint;

  /// No description provided for @onboardingBaselineTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional max reps'**
  String get onboardingBaselineTitle;

  /// No description provided for @onboardingBaselineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add it now or skip it. GTG Coach can use it for a lighter recommendation later.'**
  String get onboardingBaselineSubtitle;

  /// No description provided for @onboardingBaselineFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Current clean max reps'**
  String get onboardingBaselineFieldLabel;

  /// No description provided for @onboardingBaselineFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Skip this if you want. You can add it later in GTG Coach.'**
  String get onboardingBaselineFieldHint;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingPushUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fastest routine. Start anywhere.'**
  String get onboardingPushUpSubtitle;

  /// No description provided for @onboardingPullUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pulling strength. Form matters.'**
  String get onboardingPullUpSubtitle;

  /// No description provided for @onboardingDipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Push strength. Watch your shoulders.'**
  String get onboardingDipsSubtitle;

  /// No description provided for @coachFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus move'**
  String get coachFocusTitle;

  /// No description provided for @coachFocusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your primary move fresh and repeatable.'**
  String get coachFocusSubtitle;

  /// No description provided for @coachFocusMoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary move'**
  String get coachFocusMoveLabel;

  /// No description provided for @coachRecommendedRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended GTG reps'**
  String get coachRecommendedRepsLabel;

  /// No description provided for @coachRecommendedHint.
  ///
  /// In en, this message translates to:
  /// **'About half of your max so each set stays well below failure.'**
  String get coachRecommendedHint;

  /// No description provided for @coachLastTestedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last max test'**
  String get coachLastTestedLabel;

  /// No description provided for @coachLastTestedNever.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get coachLastTestedNever;

  /// No description provided for @coachBaselineTitle.
  ///
  /// In en, this message translates to:
  /// **'Baseline'**
  String get coachBaselineTitle;

  /// No description provided for @coachBaselineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your current max and the number of daily practice sets.'**
  String get coachBaselineSubtitle;

  /// No description provided for @coachBaselineLabel.
  ///
  /// In en, this message translates to:
  /// **'Current max reps'**
  String get coachBaselineLabel;

  /// No description provided for @coachDailySetGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily set goal'**
  String get coachDailySetGoalLabel;

  /// No description provided for @coachPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get coachPlanTitle;

  /// No description provided for @coachPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Progress is counted from today\'s logs for your primary move.'**
  String get coachPlanSubtitle;

  /// No description provided for @coachTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get coachTodayLabel;

  /// No description provided for @coachCompletedSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed sets'**
  String get coachCompletedSetsLabel;

  /// No description provided for @coachTargetSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Target sets'**
  String get coachTargetSetsLabel;

  /// No description provided for @coachRemainingSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining sets'**
  String get coachRemainingSetsLabel;

  /// No description provided for @coachCardReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s GTG suggestion and progress'**
  String get coachCardReadySubtitle;

  /// No description provided for @coachCardSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your max reps to get a lighter GTG suggestion'**
  String get coachCardSetupSubtitle;

  /// No description provided for @coachSetBaselineAction.
  ///
  /// In en, this message translates to:
  /// **'Add max'**
  String get coachSetBaselineAction;

  /// No description provided for @coachAdjustAction.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get coachAdjustAction;

  /// No description provided for @coachSetupHint.
  ///
  /// In en, this message translates to:
  /// **'Save your current max for your focus move. Home will suggest a lighter GTG set and track today\'s progress.'**
  String get coachSetupHint;

  /// No description provided for @coachNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get coachNotSet;

  /// No description provided for @coachRetestDueMessage.
  ///
  /// In en, this message translates to:
  /// **'It has been over 2 weeks. Recheck your max and refresh the recommendation.'**
  String get coachRetestDueMessage;

  /// No description provided for @coachQuickLogRecommended.
  ///
  /// In en, this message translates to:
  /// **'GTG {count} reps'**
  String coachQuickLogRecommended(int count);

  /// No description provided for @coachTodayProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{target} sets'**
  String coachTodayProgress(int done, int target);

  /// No description provided for @coachRemainingSets.
  ///
  /// In en, this message translates to:
  /// **'{count} sets left today'**
  String coachRemainingSets(int count);

  /// No description provided for @coachSetsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String coachSetsShort(int count);

  /// No description provided for @gtgInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Local insights'**
  String get gtgInsightsTitle;

  /// No description provided for @gtgInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Private signals from your recent logs.'**
  String get gtgInsightsSubtitle;

  /// No description provided for @gtgInsightBaselineMissing.
  ///
  /// In en, this message translates to:
  /// **'Add max reps to unlock personalized guidance.'**
  String get gtgInsightBaselineMissing;

  /// No description provided for @gtgInsightConsistency.
  ///
  /// In en, this message translates to:
  /// **'You trained on {count} days in the last 14 days.'**
  String gtgInsightConsistency(int count);

  /// No description provided for @gtgInsightTrainingWindow.
  ///
  /// In en, this message translates to:
  /// **'Your most common training window is around {time}.'**
  String gtgInsightTrainingWindow(String time);

  /// No description provided for @gtgInsightRetestDue.
  ///
  /// In en, this message translates to:
  /// **'Your max test is getting old. Consider a fresh baseline.'**
  String get gtgInsightRetestDue;

  /// No description provided for @splashTapToSkip.
  ///
  /// In en, this message translates to:
  /// **'Tap to skip'**
  String get splashTapToSkip;

  /// No description provided for @exercisePushUp.
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get exercisePushUp;

  /// No description provided for @exercisePullUp.
  ///
  /// In en, this message translates to:
  /// **'Pull-ups'**
  String get exercisePullUp;

  /// No description provided for @exerciseDips.
  ///
  /// In en, this message translates to:
  /// **'Dips'**
  String get exerciseDips;

  /// No description provided for @repsWithUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} reps'**
  String repsWithUnit(int count);

  /// No description provided for @daysWithUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysWithUnit(int count);

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for a set'**
  String get notifTitle;

  /// No description provided for @notifBody.
  ///
  /// In en, this message translates to:
  /// **'Do one set: push-ups, pull-ups, or dips. Keep your rhythm today.'**
  String get notifBody;

  /// No description provided for @missionTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s GTG mission'**
  String get missionTodayTitle;

  /// No description provided for @missionTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A small plan for coming back today, not a workout marathon.'**
  String get missionTodaySubtitle;

  /// No description provided for @missionRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Return mission'**
  String get missionRecoveryTitle;

  /// No description provided for @missionRecoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You missed {count} days. One light set is enough to restart.'**
  String missionRecoverySubtitle(int count);

  /// No description provided for @missionCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission complete'**
  String get missionCompleteTitle;

  /// No description provided for @missionCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nice rhythm. Extra sets are optional today.'**
  String get missionCompleteSubtitle;

  /// No description provided for @missionLogAction.
  ///
  /// In en, this message translates to:
  /// **'Log {count}'**
  String missionLogAction(int count);

  /// No description provided for @missionProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Mission progress'**
  String get missionProgressLabel;

  /// No description provided for @missionProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{done}/{target} sets'**
  String missionProgressValue(int done, int target);

  /// No description provided for @missionNextSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Next set'**
  String get missionNextSetLabel;

  /// No description provided for @missionDoneValue.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get missionDoneValue;

  /// No description provided for @missionRhythmLabel.
  ///
  /// In en, this message translates to:
  /// **'7-day rhythm'**
  String get missionRhythmLabel;

  /// No description provided for @missionRhythmValue.
  ///
  /// In en, this message translates to:
  /// **'{count} active days'**
  String missionRhythmValue(int count);

  /// No description provided for @calendarRhythmMessage.
  ///
  /// In en, this message translates to:
  /// **'You logged on {count7} of the last 7 days ({count14}/14). Keep the rhythm light and repeatable.'**
  String calendarRhythmMessage(int count7, int count14);

  /// No description provided for @calendarRecoveryMessage.
  ///
  /// In en, this message translates to:
  /// **'No penalty for a gap. You missed {count} days; restart with one easy set today.'**
  String calendarRecoveryMessage(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
