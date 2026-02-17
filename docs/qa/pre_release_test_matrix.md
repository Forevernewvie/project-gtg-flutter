# PROJECT GTG Pre-release QA Matrix

## Scope

- Target: Android Play release readiness
- Mode: local-only app (no backend sync)
- Policy: no secrets in repo/logs

## Feature Matrix

| Feature | Test Type | Evidence File |
|---|---|---|
| 온보딩 선택/스킵/완료 | widget + provider | `test/onboarding_screen_widget_test.dart`, `test/user_preferences_controller_test.dart` |
| 홈 빠른 기록(+/-/기록) | widget | `test/dashboard_quick_log_widget_test.dart` |
| 통계(일/주/월 계산) | unit | `test/workout_analytics_service_test.dart` |
| 캘린더 히트맵 + 날짜 상세 | widget | `test/calendar_heatmap_widget_test.dart` |
| 리마인더 enable/permission/schedule | widget | `test/reminder_settings_widget_test.dart` |
| 리마인더 플래너(간격/조용한시간/주말/max) | unit | `test/reminder_planner_test.dart` |
| 전체 기록 그룹/정렬/빈 상태 | widget | `test/all_logs_screen_widget_test.dart` |
| 설정 라우팅/개인정보 링크 실패 처리 | widget | `test/settings_screen_widget_test.dart` |
| 로컬 저장소(손상 격리/roundtrip/tmp 정리) | unit | `test/gtg_persistence_test.dart` |
| 스플래시 표시 정책 | unit | `test/root_overlays_policy_test.dart` |
| Android 런타임 동선/오버플로우 로그 | smoke script | `tool/smoke_android.sh`, `docs/screenshots/android_*.png` |
| AAB 릴리즈 산출물 | release build | `tool/release_android.sh`, `build/app/outputs/bundle/release/app-release.aab` |

## Gate Commands

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --dart-define=UI_TESTING=true
for i in 1 2 3 4 5; do flutter test --dart-define=UI_TESTING=true; done
ADS_ENABLED=false ./tool/release_android.sh
./tool/smoke_android.sh
```

## Known Limits

- 광고 SDK 실제 랜더링은 CI/테스트 런타임에서 비활성화(`UI_TESTING=true`).
- 배너 오버플로우는 Android smoke 로그 스캔으로 최종 검증.
