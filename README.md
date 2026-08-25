# PROJECT GTG (Flutter)

[![Google Play Store](https://img.shields.io/badge/Google_Play-414141?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.forevernewvie.projectgtg&hl=kr)

A local-first GTG (Grease The Groove) workout app focused on frequent, low-fatigue training.
The app currently targets Push-up, Pull-up, and Dip logging with calendar visibility, reminders, and theme/localization support.

## TL;DR (Run in 3 Steps)

```bash
git clone https://github.com/Forevernewvie/project-gtg-flutter.git
cd project-gtg-flutter
flutter pub get
flutter run -d emulator-5554 --debug
```

If `emulator-5554` is not available, run `flutter devices` and replace the device id.

## What This App Includes (v1.2.0 State)

- **Zero-Friction Logging**:
  - Android Home Screen 1-Tap Widget (`android/app/.../GtgWidgetProvider.kt`)
  - **Wear OS Sub-app** (`wear_app/`): Giant [+1] logging, haptic pulse, 7-day dot heatmap, Ambient Mode (AOD burn-in protection), and offline Data Layer sync.
- **Home Dashboard & Cyberpunk/Glassmorphism UI**:
  - Quick logging for Push-up / Pull-up / Dip with high dopamine neon animations
  - Adaptive GTG Coach card with real-time recovery and retention suggestions
  - Daily totals, active-day rhythm summary, and recent logs preview
- **Calendar & Consistency Tracking**:
  - Monthly activity heatmap & streak visualization
  - Selected-day timeline/details
- **Settings & Preferences**:
  - Theme mode selector: System / Light / Dark (High-contrast Cyberpunk / Neon Glass)
  - Customizable interval reminders with quiet hours and weekend skip
  - All logs inspection & CSV export
- **Serverless In-App Update Manifest**:
  - Zero-cost, 24/7 hosted update detection via GitHub Pages (`docs/version.json`)
- **Localization**:
  - Full Korean (`ko`) and Global English (`en`) fallback support

## Navigation Structure

- `/home`
- `/calendar`
- `/settings`
  - `/settings/reminders`
  - `/settings/logs`

Router lives in `/lib/app/router.dart` and uses `go_router` with `StatefulShellRoute`.

## Tech Stack

- **Framework**: Flutter (Dart 3.x)
- **Wear OS**: Flutter Wear OS Sub-app (`wear_app/`), `watch_connectivity`, `wearable_rotary`, `wear`
- **State Management**: `flutter_riverpod`
- **Navigation**: `go_router`
- **Persistence**: `isar_community` (High-performance local NoSQL)
- **Notifications & Widgets**: `flutter_local_notifications`, Android AppWidget Provider
- **Monetization**: `google_mobile_ads`
- **Localization**: Flutter ARB (`app_en.arb`, `app_ko.arb`)
- **CI/CD & Update Hosting**: GitHub Actions + GitHub Pages (`pages.yml`, `docs/version.json`)

## Project Layout

```text
lib/
  app/          # app root, router, shell, overlays
  core/         # theme, models, env, shared utils
  data/         # persistence layer (Isar + JSON)
  features/     # onboarding, workout, calendar, reminders, settings
  l10n/         # ARB + generated localization files

test/            # unit/widget/layout tests
integration_test/# flow-level integration tests
tool/            # gate/release/security helper scripts
```

## Theme System (GTG Light/Dark)

- Theme definitions: `/lib/core/gtg_theme.dart`
- Color tokens: `/lib/core/gtg_colors.dart`
- Gradients: `/lib/core/gtg_gradients.dart`
- App wiring: `/lib/app/gtg_app.dart`
- Settings selector: `/lib/features/settings/settings_screen.dart`
- Persistence controller: `/lib/features/settings/state/theme_preference_controller.dart`

Theme choice is persisted and restored on next app launch.

## Localization

Source ARB files:
- `/lib/l10n/app_en.arb`
- `/lib/l10n/app_ko.arb`

After editing ARB files:

```bash
flutter gen-l10n
```

## Local Quality Gates (Same Intent as CI)

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test -d emulator-5554
```

One-shot gate script:

```bash
./tool/gate.sh
```

## Build & Install

### Debug APK

```bash
flutter build apk --debug
flutter install -d emulator-5554 --debug \
  --use-application-binary build/app/outputs/flutter-apk/app-debug.apk
```

### Android Release AAB

Recommended script:

```bash
./tool/release_android.sh
```

Release prerequisites are validated by the script, including:
- `android/key.properties`
- keystore file path
- ad-related env vars (when ads are enabled)

Direct build command (if your release env is already set):

```bash
flutter build appbundle --release
```

## Security & Secrets Basics

- Do not commit `.env*`, keystore files, or signing secrets.
- Keep `android/key.properties` local-only (gitignored).
- Use `/tool/security/` scripts and CI secret scanning before release.

## Recommended Git Workflow

```bash
git switch main
git pull --ff-only
git switch -c codex/<task-name>

# make changes

dart format --set-exit-if-changed .
flutter analyze
flutter test

# optional integration test
flutter test integration_test -d emulator-5554

git add <files>
git commit -m "type(scope): summary"
git push -u origin codex/<task-name>
```

Then open a PR to `main`.

## Troubleshooting

### Build cache / dependency issues

```bash
flutter clean
flutter pub get
```

### iOS CocoaPods issues

```bash
cd ios
pod install
cd ..
```

### Device not detected

```bash
flutter devices
```

### Reinstall app on emulator

```bash
flutter install -d emulator-5554 --debug --uninstall-only
flutter install -d emulator-5554 --debug
```

## License

Internal/private project (`publish_to: none`).
