# PROJECT GTG Pre-Release QA Checklist

## 1) Static Gate
- [ ] `dart format --set-exit-if-changed .`
- [ ] `flutter analyze`
- [ ] `flutter test --dart-define=UI_TESTING=true`
- [ ] `flutter test --dart-define=UI_TESTING=true` repeated 5 times

## 2) Android Runtime Smoke
- [ ] `./tool/smoke_android.sh`
- [ ] Home screen renders without overflow
- [ ] Calendar screen opens and day detail updates
- [ ] Settings screen opens and no black/blank rendering
- [ ] Reminders screen opens and settings controls are usable
- [ ] All Logs screen opens and ad area does not overflow
- [ ] logcat has no `RenderFlex overflowed`
- [ ] logcat has no `EXCEPTION CAUGHT BY RENDERING LIBRARY`
- [ ] logcat has no `Fatal Exception`

## 3) Release Build Chain
- [ ] `ADS_ENABLED=false ./tool/release_android.sh`
- [ ] AAB exists: `build/app/outputs/bundle/release/app-release.aab`
- [ ] `android/key.properties` is ignored by git
- [ ] keystore exists at local secure path

## 4) Policy and Store Readiness
- [ ] Privacy policy link opens from Settings
- [ ] Ads only appear in allowed screens (Settings / All Logs)
- [ ] Reminder permission is requested only when enabling reminders
- [ ] Data storage statement matches implementation (local only)

## 5) Manual Sanity (10 minutes)
- [ ] First launch onboarding flow works (select / skip / complete)
- [ ] Quick log updates today total and exercise cards
- [ ] Day / Week / Month stats are consistent
- [ ] Splash behavior matches mode (UI_TESTING vs normal)
- [ ] App icon and branding are correct in launcher
