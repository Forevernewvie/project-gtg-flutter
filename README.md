# PROJECT GTG (Flutter)

## 1) Project Overview
PROJECT GTG is a local-first GTG (Grease The Groove) workout app for iOS and Android.
It focuses on fast repetition logging for Push-ups, Pull-ups, and Dips, plus lightweight progress visibility through dashboard and calendar views.

Current navigation structure:
- Home
- Calendar
- Settings
  - Reminder Settings (nested route)
  - All Logs (nested route)

Onboarding and splash are handled as root overlays.

## 2) Feature Highlights
### Onboarding
- First-run onboarding asks for a primary exercise.
- Supports skip and complete flows.
- Triggered by persisted user preference (`hasCompletedOnboarding`).

### Home quick logging (Push-up / Pull-up / Dip)
- Per-exercise +/- steppers and one-tap log action.
- Immediate persistence through Riverpod controller.
- Reset action clears all logs.

### Stats (daily/weekly/monthly)
- Analytics service supports day/week/month totals.
- Current UI surfaces:
  - Daily totals on Home hero card.
  - Active days in the last 14 days.
  - Monthly total and active days in Calendar.

### Calendar heatmap + day timeline
- Monthly heatmap grid with intensity by logged reps.
- Tap a day to view day total, per-exercise totals, and time-sorted entries.
- Month navigation and "Today" jump are included.

### Reminder controls + smart reminder area
- Enable/disable reminders with permission-aware behavior.
- Controls: interval, max per day, quiet hours (start/end), skip weekends.
- Smart scheduling summary shows next planned reminder and count.

### History list/edit/undo
- All Logs screen provides grouped day-by-day history view.
- Current UI supports browsing only; explicit edit/undo actions are not exposed in this release.

### Settings (Theme mode: System/Light/Dark, etc.)
- Theme selector: System / Light / Dark.
- Reminder and All Logs entry points.
- Privacy policy external link handling and fallback snackbar.

## 3) Tech Stack and Architecture
- Framework: Flutter (Dart)
- State management: `flutter_riverpod` (AsyncNotifier + Provider)
- Navigation: `go_router` (`StatefulShellRoute`)
- Localization: `flutter_localizations` + ARB + generated localizations
- Local notifications: `flutter_local_notifications`
- Local storage:
  - Preferred backend: Isar (`isar_community`)
  - Fallback/backend migration source: JSON file store
- Ads: `google_mobile_ads`

High-level layout:
- `lib/app`: app shell, router, root overlays
- `lib/core`: models, theme, env, utilities
- `lib/data`: persistence (Isar + JSON fallback)
- `lib/features`: onboarding, workout, calendar, reminders, settings
- `test`: unit/widget/layout compatibility tests
- `tool`: gate, smoke, release helpers

## 4) Theme System (GTG Light/Dark)
Theme is configured at app root and applied via `ThemeMode`.

Primary files:
- `lib/core/gtg_colors.dart` (GTG light/dark tokens)
- `lib/core/gtg_gradients.dart` (light/dark gradients)
- `lib/core/gtg_theme.dart` (ThemeData for light/dark)
- `lib/app/gtg_app.dart` (`theme`, `darkTheme`, `themeMode` wiring)
- `lib/features/settings/settings_screen.dart` (System/Light/Dark selector)
- `lib/features/settings/state/theme_preference_controller.dart` (state)
- `lib/core/models/app_theme_preference.dart` (enum/model)

Persistence behavior:
- Theme mode is saved in `theme_preference.json` via `GtgPersistence`.
- Selection is restored on app restart.

## 5) Localization Status (EN/KO)
Current localization setup supports:
- `en`
- `ko`

Source files:
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ko.arb`

Generated output:
- `lib/l10n/app_localizations.dart`
- `lib/l10n/app_localizations_en.dart`
- `lib/l10n/app_localizations_ko.dart`

Regenerate localizations after ARB changes:
```bash
flutter gen-l10n
```

## 6) Getting Started (prerequisites, install, run)
### Prerequisites
- Flutter SDK (stable)
- Xcode + CocoaPods (for iOS)
- Android SDK / Android Studio (for Android)

### Install dependencies
```bash
cd /Users/jaebinchoi/Desktop/project-gtg-flutter
flutter pub get
```

### Run (Android emulator)
```bash
flutter run -d emulator-5554 --debug
```

### Run (iOS simulator)
```bash
flutter run -d "iPhone 16" --debug
```

## 7) Quality Gates
Run these before commit:
```bash
cd /Users/jaebinchoi/Desktop/project-gtg-flutter
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Optional consolidated gate:
```bash
./tool/gate.sh
```

## 8) Build & Install
Build debug APK:
```bash
cd /Users/jaebinchoi/Desktop/project-gtg-flutter
flutter build apk --debug
```

Install debug APK to emulator/device:
```bash
flutter install -d emulator-5554 --debug \
  --use-application-binary build/app/outputs/flutter-apk/app-debug.apk
```

Uninstall only (if needed):
```bash
flutter install -d emulator-5554 --debug --uninstall-only
```

## 9) Repository Workflow
Use feature branches prefixed with `codex/`.

Recommended flow:
```bash
cd /Users/jaebinchoi/Desktop/project-gtg-flutter
git switch main
git pull --ff-only
git switch -c codex/feature/<task-name>

# implement changes

dart format --set-exit-if-changed .
flutter analyze
flutter test

git add <files>
git commit -m "feat(scope): summary"
git push -u origin codex/feature/<task-name>
```

PR guidance:
- Open PR from `codex/...` -> `main`
- Ensure checks pass
- Merge after review

## 10) Troubleshooting
### Build artifacts or dependency drift
```bash
cd /Users/jaebinchoi/Desktop/project-gtg-flutter
flutter clean
flutter pub get
```

### iOS pods issues
```bash
cd /Users/jaebinchoi/Desktop/project-gtg-flutter/ios
pod install
```

### Emulator install issues
- Verify device list: `flutter devices`
- Reinstall debug APK:
  ```bash
  flutter install -d emulator-5554 --debug --uninstall-only
  flutter install -d emulator-5554 --debug
  ```

## 11) Changelog Snapshot
Recent major updates reflected in current codebase:
- Added GTG dual theme system (Light/Dark) and Settings theme selector with persistence.
- Introduced Isar-first persistence with safe JSON-to-Isar migration and JSON fallback.
- Expanded QA coverage for persistence, reminders, onboarding, layout compatibility, and widget smoke paths.
- Hardened test/runtime behavior (test runtime detection, scheduling sync checks, formatting/analyze/test gates).
