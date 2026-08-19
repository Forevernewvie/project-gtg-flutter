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
  String get navCalendar => '리듬';

  @override
  String get navSettings => '설정';

  @override
  String get dashboardTitle => '오늘의 운동';

  @override
  String get dashboardSubtitle => '작은 습관이 모여 완벽을 만들어요. 지치지 않게, 자주, 꾸준하게.';

  @override
  String get dashboardReadyTitle => '준비 완료';

  @override
  String dashboardPrimarySetHint(String exercise, int count) {
    return '$exercise $count회, 지금 바로 시작해 볼까요?';
  }

  @override
  String activeDaysPill(int count) {
    return '$count일째 운동 중';
  }

  @override
  String get quickLogTitle => '세트 기록';

  @override
  String get quickLogHelper => '오늘 하루도 멋지게 숫자를 채워보세요.';

  @override
  String get decreaseValue => '줄이기';

  @override
  String get increaseValue => '늘리기';

  @override
  String get reset => '초기화';

  @override
  String get resetLogsTitle => '모든 기록을 지울까요?';

  @override
  String get resetLogsMessage => '기기에 저장된 모든 운동 기록이 영구적으로 지워져요. 계속할까요?';

  @override
  String get record => '기록';

  @override
  String get loadingLogs => '기록을 불러오고 있어요...';

  @override
  String get recentLogsTitle => '최근 기록';

  @override
  String get noLogsHint => '오늘 아직 기록이 없어요. 가볍게 한 세트 어떨까요?';

  @override
  String get noLogsHintHome => '오늘 운동 기록이 없어요. 홈에서 한 세트를 기록해 보세요.';

  @override
  String get calendarTitle => '나의 리듬';

  @override
  String get calendarSubtitleHeatmap => '색이 진해질수록 리듬이 탄탄해지고 있어요.';

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
  String get noLogsForDay => '이날은 기록이 없어요. 홈에서 한 세트 기록해 보세요.';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsThemeTitle => '테마';

  @override
  String get settingsThemeSubtitle => '앱 화면 테마를 선택할 수 있어요.';

  @override
  String get settingsThemeSystem => '시스템';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get remindersTitle => '알림';

  @override
  String get remindersSubtitle => '알림 주기와 조용한 시간을 설정할 수 있어요.';

  @override
  String get settingsCoachTitle => 'GTG 코치';

  @override
  String get settingsCoachSubtitle => '목표 횟수와 추천 계획을 관리할 수 있어요.';

  @override
  String get allLogsTitle => '전체 기록';

  @override
  String get allLogsSubtitle => '모든 기록을 날짜와 종목별로 확인해요.';

  @override
  String get aboutTitle => '앱 정보';

  @override
  String get privacyPolicyTitle => '개인정보 처리방침';

  @override
  String get privacyPolicySubtitle => '데이터 처리에 대한 안내를 확인해요.';

  @override
  String get adPrivacyChoicesTitle => '광고 개인정보 선택';

  @override
  String get adPrivacyChoicesSubtitle => '광고 동의 설정을 다시 확인해요.';

  @override
  String get adPrivacyChoicesUnavailable => '지금은 광고 옵션을 열 수 없어요.';

  @override
  String get invalidLink => '올바른 링크가 아니에요.';

  @override
  String get cannotOpenBrowser => '브라우저를 열지 못했어요. 다시 시도해 주세요.';

  @override
  String get openExternalFailed => '링크를 열지 못했어요.';

  @override
  String get appUpdateTitle => '업데이트 가능';

  @override
  String appUpdateBody(String version) {
    return '새로운 버전($version)이 있어요. 최신 기능과 함께 더 나은 앱을 경험해 보세요.';
  }

  @override
  String get appUpdateLater => '나중에';

  @override
  String get appUpdateNow => '업데이트';

  @override
  String get remindersHeadline => '조용하게, 꾸준히';

  @override
  String get remindersSubheadline => '알림 주기를 설정하면 하루 일과에 맞춰 알림을 보내드려요.';

  @override
  String get enableRemindersTitle => '알림 켜기';

  @override
  String get enableRemindersOffSubtitle => '원할 때만 켜고 끌 수 있어요.';

  @override
  String get enableRemindersNoSlotsSubtitle =>
      '알림을 보낼 시간이 없어요. 조용한 시간이나 주말 쉬기 설정을 확인해 주세요.';

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
  String get reminderOptimizationTitle => '기록 맞춤 제안';

  @override
  String get reminderOptimizationApply => '적용';

  @override
  String get reminderOptimizationEnable => '운동 리듬을 찾을 수 있도록 알림을 켜볼까요?';

  @override
  String reminderOptimizationReduceFrequency(int count) {
    return '최근 리듬이 여유로워요. $count분 간격으로 알림을 받아보세요.';
  }

  @override
  String get reminderOptimizationSkipWeekends =>
      '주말에는 기록이 적네요. 주말 쉬기 옵션을 켜보는 건 어떨까요?';

  @override
  String reminderOptimizationPreferredTime(String time) {
    return '$time 즈음에 기록이 많아요. 이 시간에 집중해서 알림을 받아보세요.';
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
  String get weekendsOffSubtitle => '주말에는 알림을 보내지 않아요.';

  @override
  String get silentNotificationsInfo => '알림은 소리 없이 조용하게 울려요.';

  @override
  String get permissionDenied => '알림 권한이 필요해요. 기기 설정에서 허용해 주세요.';

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
  String get onboardingSubtitle => '완벽함보다 꾸준함이 중요해요. 1분만 설정하면 바로 시작할 수 있어요.';

  @override
  String get onboardingQuestion => '어떤 운동을 주로 하시나요?';

  @override
  String get onboardingHint => '선택한 운동이 홈 화면 가장 앞에 나타나요.';

  @override
  String get onboardingBaselineTitle => '선택: 최대 횟수 입력';

  @override
  String get onboardingBaselineSubtitle =>
      '지금 입력하지 않아도 괜찮아요. 코치가 알맞은 횟수를 추천할 때 참고해요.';

  @override
  String get onboardingBaselineFieldLabel => '한 번에 할 수 있는 최대 횟수';

  @override
  String get onboardingBaselineFieldHint => '건너뛰어도 나중에 언제든 추가할 수 있어요.';

  @override
  String get onboardingNext => '다음';

  @override
  String get onboardingPushUpSubtitle => '언제 어디서나 간편하게 시작해요.';

  @override
  String get onboardingPullUpSubtitle => '정확한 자세로 당기는 상체 운동이에요.';

  @override
  String get onboardingDipsSubtitle => '올바른 각도로 미는 힘을 길러요.';

  @override
  String get coachFocusTitle => '목표 운동';

  @override
  String get coachFocusSubtitle => '무리하지 않고 꾸준히 할 수 있게 목표를 맞춰드릴게요.';

  @override
  String get coachFocusMoveLabel => '주요 운동';

  @override
  String get coachRecommendedRepsLabel => '추천 횟수';

  @override
  String get coachRecommendedHint => '최대 횟수의 절반 정도로 설정하면 여유롭게 리듬을 유지할 수 있어요.';

  @override
  String get coachLastTestedLabel => '마지막 최대 횟수 측정일';

  @override
  String get coachLastTestedNever => '기록 없음';

  @override
  String get coachBaselineTitle => '기준 설정';

  @override
  String get coachBaselineSubtitle => '현재 최대 횟수와 하루 목표 세트를 설정해 주세요.';

  @override
  String get coachBaselineLabel => '현재 최대 횟수';

  @override
  String get coachDailySetGoalLabel => '하루 목표 세트';

  @override
  String get coachPlanTitle => '오늘의 계획';

  @override
  String get coachPlanSubtitle => '오늘 기록한 운동을 바탕으로 진행 상황을 보여드릴게요.';

  @override
  String get coachTodayLabel => '오늘';

  @override
  String get coachCompletedSetsLabel => '완료 세트';

  @override
  String get coachTargetSetsLabel => '목표 세트';

  @override
  String get coachRemainingSetsLabel => '남은 세트';

  @override
  String get coachCardReadySubtitle => '오늘의 추천 목표와 진행도를 확인해요.';

  @override
  String get coachCardSetupSubtitle => '최대 횟수를 입력하면 더 적절한 목표를 추천해 드릴게요.';

  @override
  String get coachSetBaselineAction => '최대 횟수 입력';

  @override
  String get coachAdjustAction => '조정';

  @override
  String get coachSetupHint => '최대 횟수를 저장하면 무리하지 않는 선에서 알맞은 세트를 추천해 드릴게요.';

  @override
  String get coachNotSet => '미설정';

  @override
  String get coachRetestDueMessage =>
      '2주가 지났어요. 최대 횟수를 다시 측정하면 목표를 새롭게 맞출 수 있어요.';

  @override
  String coachQuickLogRecommended(int count) {
    return '추천 $count회';
  }

  @override
  String coachTodayProgress(int done, int target) {
    return '$done/$target세트';
  }

  @override
  String coachRemainingSets(int count) {
    return '오늘은 $count세트 남았어요';
  }

  @override
  String coachSetsShort(int count) {
    return '$count세트';
  }

  @override
  String get gtgInsightsTitle => '나의 기록 분석';

  @override
  String get gtgInsightsSubtitle => '최근 기록을 분석해서 찾은 나만의 패턴이에요.';

  @override
  String get gtgInsightBaselineMissing =>
      '최대 횟수를 입력하면 나에게 딱 맞는 가이드를 받아볼 수 있어요.';

  @override
  String gtgInsightConsistency(int count) {
    return '최근 14일 중 $count일 동안 운동했어요.';
  }

  @override
  String gtgInsightTrainingWindow(String time) {
    return '가장 자주 기록한 시간대는 $time 전후예요.';
  }

  @override
  String get gtgInsightRetestDue => '최대 횟수를 측정한 지 오래됐어요. 새로운 기준을 세워볼까요?';

  @override
  String get splashTapToSkip => '화면을 눌러 건너뛰기';

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
  String get notifTitle => '운동할 시간';

  @override
  String get notifBody => '가볍게 한 세트 기록하고 오늘의 리듬을 이어가 보세요.';

  @override
  String get missionTodayTitle => '오늘의 미션';

  @override
  String get missionTodaySubtitle => '오늘 다시 운동하게 만드는 작고 꾸준한 계획이에요.';

  @override
  String get missionRecoveryTitle => '복귀 미션';

  @override
  String missionRecoverySubtitle(int count) {
    return '$count일 동안 쉬었어요. 가볍게 1세트만 기록하고 리듬을 다시 깨워볼까요?';
  }

  @override
  String get missionCompleteTitle => '오늘의 미션 완료!';

  @override
  String get missionCompleteSubtitle => '멋진 리듬이에요. 오늘의 추가 운동은 선택 사항입니다.';

  @override
  String missionLogAction(int count) {
    return '$count회 기록';
  }

  @override
  String get missionProgressLabel => '진행 상황';

  @override
  String missionProgressValue(int done, int target) {
    return '$done/$target세트';
  }

  @override
  String get missionNextSetLabel => '다음 세트';

  @override
  String get missionDoneValue => '완료';

  @override
  String get missionRhythmLabel => '주간 리듬';

  @override
  String missionRhythmValue(int count) {
    return '$count일 활동';
  }

  @override
  String calendarRhythmMessage(int count7, int count14) {
    return '최근 7일 동안 $count7일 운동했어요. (14일 기준 $count14일)';
  }

  @override
  String calendarRecoveryMessage(int count) {
    return '쉬어가는 것도 중요해요. $count일 쉬었으니 오늘은 가볍게 1세트만 시작해 보세요.';
  }

  @override
  String get adaptiveCoachTitle => '맞춤 코치';

  @override
  String get adaptiveCoachSubtitle => '가장 알맞은 운동 계획을 찾아서 추천해 드려요.';

  @override
  String get adaptiveCoachRemoteSource => 'PocketBase';

  @override
  String get adaptiveCoachLocalSource => '기기 설정';

  @override
  String get adaptiveCoachIntensityRecover => '회복';

  @override
  String get adaptiveCoachIntensityMaintain => '유지';

  @override
  String get adaptiveCoachIntensityProgress => '증가';

  @override
  String get adaptiveCoachReasonRetestDue => '최대 횟수 측정 필요';

  @override
  String get adaptiveCoachReasonRestartAfterGap => '최근 휴식 감지';

  @override
  String get adaptiveCoachReasonRecoverVolume => '운동량 회복 추천';

  @override
  String get adaptiveCoachReasonMaintainVolume => '현재 운동량 유지';

  @override
  String get adaptiveCoachReasonProgressVolume => '안정적인 운동 리듬';

  @override
  String adaptiveCoachRecommendationLine(
    String intensity,
    String reason,
    String source,
  ) {
    return '$intensity · $reason · 출처: $source';
  }

  @override
  String get adaptiveCoachRecommendedSetsLabel => '추천 세트';
}
