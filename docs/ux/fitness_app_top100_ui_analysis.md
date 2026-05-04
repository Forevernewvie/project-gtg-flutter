# GTG UI/UX Redesign Input: Top 100 Fitness App Pattern Analysis

Date: 2026-05-04
Scope: AppBrain US Health & Fitness top-free rank pages for Google Play and Apple App Store, ranks 1-100, plus UI Pro Max Flutter guidance.

## Sources checked
- Google Play Health & Fitness / United States / Top Free: https://www.appbrain.com/stats/google-play-rankings/top_free/health_fitness/us
  - Page states rankings are refreshed daily from Google Play and was last updated on 2026-05-04.
  - The page exposes rank 1 through rank 100 on the first page.
- Apple App Store Health & Fitness / United States / Top Free: https://www.appbrain.com/stats/appstore-rankings/top_free/health_and_fitness/us
  - The page exposes rank 1 through rank 100 on the first page.
- UI Pro Max design-system query: `mobile fitness workout tracker beginner calisthenics --design-system --stack flutter`.

## What appeared across ranks 1-100

### 1. The top 100 is broader than “workout apps”
The ranking mixes gym/workout apps, calorie and food scanners, step counters, outdoor activity trackers, insurance/clinic portals, mental wellness, sleep, period tracking, device companion apps, and body/heart monitoring.

Implication for GTG: do not imitate a single vertical. GTG should stay narrowly focused: quick calisthenics logging, consistency, calendar progress, and reminders.

### 2. Repeated UI patterns worth using
- **One clear daily next action**: leading apps push a single “today” action before deeper analytics.
- **Large progress signal above the fold**: today total, goal ring, streak, or daily completion state.
- **Fast logging or scan entry**: the main action is reachable without reading long instructions.
- **Calendar/streak visualization**: activity history is made visual, not only tabular.
- **Coach-like setup copy**: beginner flows use short choices and optional personalization.
- **Device/gym/wellness apps separate settings from action**: settings exist, but do not block the core task.

### 3. Patterns intentionally not copied
- No branded competitor palettes, logos, or screenshots.
- No subscription/paywall-first onboarding.
- No social feed, gamified pet, or insurance/clinic portal IA.
- No direct clone of Strava, MyFitnessPal, Fitbit, AllTrails, Planet Fitness, Fitbod, Ladder, or Hevy flows.

## GTG-specific redesign decisions

| Requirement | Decision |
|---|---|
| First-time users should understand the app quickly | Home now leads with a daily mission hero, Quick Log says “Adjust reps, then tap Record,” Calendar explains darker heatmap cells, and onboarding says the primary move appears first on Home. |
| Existing features must remain | Existing routes stay: Home, Calendar, Settings, GTG Coach, Reminders, All Logs. Quick log, clear/reset, calendar details, reminders, privacy links, and ads remain intact. The Settings Cloud Sync card was removed as non-core setup clutter while the underlying sync infrastructure remains available. |
| Pull-up / push-up / dips icons should be GPT-image based | Three GPT-generated raster icon assets are stored under `assets/exercise_icons/` and consumed through `ExerciseUiStyle.assetPath` / `ExerciseUiStyle.glyph`, with the previous CustomPaint glyph retained as a fallback. |
| Avoid obvious copying | The icon style is original GPT-generated blue glass/athletic artwork. The app uses GTG-specific mission/reps language and a compact calisthenics IA rather than competitor screen layouts. |
| Flutter accessibility | Shared components keep Semantics where needed, large-text responsive layouts, minimum tap targets, and error/fallback paths for image assets. |


## Autopilot application decisions (2026-05-04)

| Pattern / pruning point | Applied decision | App touchpoint |
|---|---|---|
| Mimic: one obvious daily action | Keep the Home daily mission hero as the first workout action. | `DashboardScreen` mission card |
| Mimic: fast entry | Keep Quick Log and prevent rapid taps from over-logging beyond the mission target. | `dashboard.missionLogButton`, `dashboard_quick_log_widget_test.dart` |
| Mimic: recognizable workout visuals | Use original GPT-generated exercise assets with code-drawn fallbacks. | `assets/exercise_icons/`, `ExerciseUiStyle` |
| Mimic: visual progress history | Keep calendar/rhythm/streak feedback instead of adding a feed or leaderboard. | Calendar and Home progress sections |
| Remove: non-core setup clutter | Remove the Settings Cloud Sync card and Cloud Sync localization strings from the user-facing settings surface. | `SettingsScreen`, `app_en.arb`, `app_ko.arb` |
| Avoid: broad top-100 app bloat | Do not add paywalls, social feeds, insurance/clinic IA, device companion flows, or competitor-like branded layouts. | Product scope guardrail |
| Keep: compliance/support controls | Keep privacy/ad controls, About, Coach, Reminders, and All Logs because they support the workout loop or compliance. | Settings action/about sections |

## Artifact map
- `assets/exercise_icons/pull_up.png`
- `assets/exercise_icons/push_up.png`
- `assets/exercise_icons/dips.png`
- `lib/features/workout/presentation/exercise_ui_style.dart`
- `lib/features/workout/presentation/screens/dashboard_screen.dart`
- `lib/features/workout/presentation/workout_log_row.dart`
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ko.arb`
- `test/dashboard_quick_log_widget_test.dart`
- `test/settings_screen_widget_test.dart`
- `test/exercise_icon_assets_test.dart`

## Validation checklist
- [x] `dart format --set-exit-if-changed .`
- [x] `flutter analyze`
- [x] `flutter test test/exercise_icon_assets_test.dart`
- [x] `flutter test`
