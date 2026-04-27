// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'PROJECT GTG';

  @override
  String get navHome => '홈';

  @override
  String get navCalendar => '캘린더';

  @override
  String get navSettings => '설정';

  @override
  String get dashboardTitle => '오늘의 루틴';

  @override
  String get dashboardSubtitle => '완벽하게 말고, 자주. 한 세트씩만.';

  @override
  String activeDaysPill(int count) {
    return '활동일 $count일';
  }

  @override
  String get quickLogTitle => '빠른 입력';

  @override
  String get quickLogHelper => '횟수를 조정한 뒤 기록을 누르세요.';

  @override
  String get decreaseValue => '감소';

  @override
  String get increaseValue => '증가';

  @override
  String get reset => '초기화';

  @override
  String get record => '기록';

  @override
  String get loadingLogs => '기록을 불러오는 중입니다...';

  @override
  String get recentLogsTitle => '최근 기록';

  @override
  String get noLogsHint => '기록이 아직 없습니다. 위에서 첫 세트를 기록해보세요.';

  @override
  String get noLogsHintHome => '기록이 아직 없습니다. 홈에서 한 세트만 기록해보세요.';

  @override
  String get calendarTitle => '리듬 캘린더';

  @override
  String get calendarSubtitleHeatmap => '색이 진할수록 횟수가 많습니다. (월간 히트맵)';

  @override
  String get today => '오늘';

  @override
  String get prevMonthTooltip => '이전 달';

  @override
  String get nextMonthTooltip => '다음 달';

  @override
  String get monthTotalLabel => '이번 달 누적';

  @override
  String get activeDaysLabel => '활동일';

  @override
  String dayTotal(int count) {
    return '하루 누적 $count회';
  }

  @override
  String get noLogsForDay => '이 날의 기록이 없습니다. 홈에서 한 세트만 기록해보세요.';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsThemeTitle => '테마';

  @override
  String get settingsThemeSubtitle => '앱 화면 스타일을 선택하세요. 즉시 적용됩니다.';

  @override
  String get settingsThemeSystem => '시스템';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get remindersTitle => '리마인더';

  @override
  String get remindersSubtitle => '반복 주기, 방해 금지 시간, 주말 제외를 설정합니다';

  @override
  String get settingsCoachTitle => 'GTG 코치';

  @override
  String get settingsCoachSubtitle => '최대 반복, GTG 추천 횟수, 오늘 계획을 관리합니다.';

  @override
  String get allLogsTitle => '전체 기록';

  @override
  String get allLogsSubtitle => '날짜별/종목별로 모아보기';

  @override
  String get aboutTitle => '앱 정보';

  @override
  String get privacyPolicyTitle => '개인정보 처리방침';

  @override
  String get privacyPolicySubtitle => '광고/데이터 처리 안내';

  @override
  String get adPrivacyChoicesTitle => '광고 개인정보 선택';

  @override
  String get adPrivacyChoicesSubtitle => '광고 동의 옵션 다시 보기';

  @override
  String get adPrivacyChoicesUnavailable => '지금은 광고 개인정보 옵션을 열 수 없습니다.';

  @override
  String get invalidLink => '링크가 올바르지 않습니다.';

  @override
  String get cannotOpenBrowser => '브라우저를 열 수 없습니다.';

  @override
  String get openExternalFailed => '열 수 없습니다.';

  @override
  String get appUpdateTitle => '업데이트 가능';

  @override
  String appUpdateBody(String version) {
    return '새 버전($version)이 나왔습니다. 최신 개선 사항을 위해 지금 업데이트해보세요.';
  }

  @override
  String get appUpdateLater => '나중에';

  @override
  String get appUpdateNow => '업데이트';

  @override
  String get remindersHeadline => '조용하게, 꾸준히';

  @override
  String get remindersSubheadline => '반복 주기를 설정하면 오늘 남은 시간만큼만 예약합니다.';

  @override
  String get enableRemindersTitle => '리마인더 켜기';

  @override
  String get enableRemindersOffSubtitle => '원할 때만 켜고 끌 수 있어요.';

  @override
  String get enableRemindersNoSlotsSubtitle =>
      '예약할 시간이 없어요. 조용한 시간/주말 쉬기 설정을 확인해주세요.';

  @override
  String enableRemindersNextScheduledSubtitle(String time, int count) {
    return '다음 알림 $time · $count개 예약됨';
  }

  @override
  String get scheduleSectionTitle => '주기';

  @override
  String get intervalLabel => '반복 간격';

  @override
  String minutesShort(int count) {
    return '$count분';
  }

  @override
  String get maxPerDayLabel => '하루 최대';

  @override
  String get reminderOptimizationTitle => '기록 기반 제안';

  @override
  String get reminderOptimizationApply => '적용';

  @override
  String get reminderOptimizationEnable => 'GTG 리듬을 다시 만들 수 있게 리마인더를 켜보세요.';

  @override
  String reminderOptimizationReduceFrequency(int count) {
    return '최근 리듬이 가벼워요. $count분 간격을 시도해보세요.';
  }

  @override
  String get reminderOptimizationSkipWeekends =>
      '주말 기록이 거의 없어요. 주말 쉬기를 시도해보세요.';

  @override
  String reminderOptimizationPreferredTime(String time) {
    return '$time 전후 기록이 많아요. 그 시간대에 알림을 집중해보세요.';
  }

  @override
  String get quietHoursTitle => '조용한 시간';

  @override
  String get startLabel => '시작';

  @override
  String get endLabel => '끝';

  @override
  String get weekendsOffTitle => '주말 쉬기';

  @override
  String get weekendsOffSubtitle => '토/일에는 예약하지 않음';

  @override
  String get silentNotificationsInfo => '알림은 소리 없이 조용히 표시됩니다.';

  @override
  String get permissionDenied => '알림 권한이 필요합니다. 설정에서 허용해주세요.';

  @override
  String get openSettings => '설정';

  @override
  String pickTimeHelp(String label) {
    return '$label 시간 선택';
  }

  @override
  String tomorrowAt(String time) {
    return '내일 $time';
  }

  @override
  String get onboardingLater => '나중에';

  @override
  String get onboardingSubtitle => '완벽하게 말고, 자주. 1분만 설정하면 바로 시작됩니다.';

  @override
  String get onboardingQuestion => '주로 어떤 동작을 할까요?';

  @override
  String get onboardingHint => '기본 종목은 홈 화면에서 가장 먼저 보이게 됩니다.';

  @override
  String get onboardingBaselineTitle => '선택 입력: 최대 반복';

  @override
  String get onboardingBaselineSubtitle =>
      '지금 넣어도 되고, 건너뛰어도 됩니다. 나중에 GTG 코치가 더 가볍게 추천할 때 사용합니다.';

  @override
  String get onboardingBaselineFieldLabel => '현재 깔끔한 최대 반복';

  @override
  String get onboardingBaselineFieldHint =>
      '건너뛰어도 괜찮아요. 나중에 GTG 코치에서 추가할 수 있어요.';

  @override
  String get onboardingNext => '다음';

  @override
  String get onboardingPushUpSubtitle => '가장 빠른 루틴. 어디서든 시작';

  @override
  String get onboardingPullUpSubtitle => '상체 당기기. 폼이 핵심';

  @override
  String get onboardingDipsSubtitle => '푸쉬 라인 강화. 어깨 각도 주의';

  @override
  String get coachFocusTitle => '집중 동작';

  @override
  String get coachFocusSubtitle => '주 종목을 무리 없이 자주 반복할 수 있게 맞춥니다.';

  @override
  String get coachFocusMoveLabel => '주 종목';

  @override
  String get coachRecommendedRepsLabel => '추천 GTG 횟수';

  @override
  String get coachRecommendedHint => '최대 반복의 절반 정도로 유지해 매 세트를 여유 있게 가져갑니다.';

  @override
  String get coachLastTestedLabel => '마지막 최대 반복 측정';

  @override
  String get coachLastTestedNever => '아직 없음';

  @override
  String get coachBaselineTitle => '기준 설정';

  @override
  String get coachBaselineSubtitle => '현재 최대 반복과 하루 세트 목표를 설정하세요.';

  @override
  String get coachBaselineLabel => '현재 최대 반복';

  @override
  String get coachDailySetGoalLabel => '하루 세트 목표';

  @override
  String get coachPlanTitle => '오늘의 계획';

  @override
  String get coachPlanSubtitle => '오늘 기록한 주 종목 로그를 기준으로 진행도를 계산합니다.';

  @override
  String get coachTodayLabel => '오늘';

  @override
  String get coachCompletedSetsLabel => '완료한 세트';

  @override
  String get coachTargetSetsLabel => '목표 세트';

  @override
  String get coachRemainingSetsLabel => '남은 세트';

  @override
  String get coachCardReadySubtitle => '오늘의 GTG 추천과 진행 상황';

  @override
  String get coachCardSetupSubtitle => '최대 반복을 넣으면 홈이 더 가볍게 추천해줍니다.';

  @override
  String get coachSetBaselineAction => '최대반복 추가';

  @override
  String get coachAdjustAction => '조정';

  @override
  String get coachSetupHint =>
      '주 종목의 현재 최대 반복을 저장하세요. 홈이 더 가벼운 GTG 세트를 추천하고 오늘 진행도를 보여줍니다.';

  @override
  String get coachNotSet => '미설정';

  @override
  String get coachRetestDueMessage =>
      '2주 이상 지났어요. 최대 반복을 다시 측정해 추천값을 새로 맞춰보세요.';

  @override
  String coachQuickLogRecommended(int count) {
    return 'GTG $count회';
  }

  @override
  String coachTodayProgress(int done, int target) {
    return '$done/$target세트';
  }

  @override
  String coachRemainingSets(int count) {
    return '오늘 $count세트 남음';
  }

  @override
  String coachSetsShort(int count) {
    return '$count세트';
  }

  @override
  String get gtgInsightsTitle => '로컬 인사이트';

  @override
  String get gtgInsightsSubtitle => '최근 기록에서만 계산한 개인 신호입니다.';

  @override
  String get gtgInsightBaselineMissing => '최대 반복 수를 추가하면 개인화 가이드를 열 수 있어요.';

  @override
  String gtgInsightConsistency(int count) {
    return '최근 14일 동안 $count일 운동했어요.';
  }

  @override
  String gtgInsightTrainingWindow(String time) {
    return '가장 자주 기록한 시간대는 $time 전후예요.';
  }

  @override
  String get gtgInsightRetestDue => '최대 반복 측정이 오래됐어요. 기준을 새로 잡아보세요.';

  @override
  String get splashTapToSkip => '탭하여 스킵';

  @override
  String get exercisePushUp => '푸쉬업';

  @override
  String get exercisePullUp => '풀업';

  @override
  String get exerciseDips => '딥스';

  @override
  String repsWithUnit(int count) {
    return '$count회';
  }

  @override
  String daysWithUnit(int count) {
    return '$count일';
  }

  @override
  String get notifTitle => '한 세트 타이밍';

  @override
  String get notifBody => '푸쉬업/풀업/딥스 중 하나만. 오늘 리듬을 이어가요.';
}
