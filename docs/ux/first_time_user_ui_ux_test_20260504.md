# First-Time User UI/UX Test

Date: 2026-05-04
Device: Android emulator (`emulator-5554`)
Build: `build/app/outputs/flutter-apk/app-debug.apk`
Scope: first launch after clearing app data, first workout log, Calendar, Settings.

## Objective
Test whether the current GTG UI/UX is usable for a first-time user.

## Success criteria
- A first-time user lands on the core workout surface without a blocking setup flow.
- The first useful action is visible above the fold and can be completed quickly.
- The first action gives immediate, understandable feedback.
- Navigation to Calendar and Settings is understandable and visibly stateful.
- Empty/early states explain what the user is seeing.
- Accessibility tree exposes meaningful labels for the main action, key content, and tabs.
- Settings does not expose removed Cloud Sync setup clutter.
- No crash occurs during the first-use path.

## Method
1. Cleared app data: `adb shell pm clear com.forevernewvie.projectgtg`.
2. Forced a fresh launcher start: `adb shell am start -S -W ... MainActivity`.
3. Captured screenshots and `uiautomator` accessibility XML.
4. Completed the primary first action by tapping `Log 10` once.
5. Navigated to Calendar and Settings.
6. Ran targeted widget tests for first-use navigation, quick logging, calendar, and settings.
7. Checked logcat for fatal Android runtime crashes.

## Artifacts
- Home fresh launch: `artifacts/first_user_ux/01_fresh_launch_after_clear.png`
- Home accessibility tree: `artifacts/first_user_ux/01_fresh_home_ready.xml`
- After first log: `artifacts/first_user_ux/02_after_first_log.png`
- After first log accessibility tree: `artifacts/first_user_ux/02_after_first_log.xml`
- Calendar after first log: `artifacts/first_user_ux/03_calendar_after_first_log.png`
- Calendar accessibility tree: `artifacts/first_user_ux/03_calendar_after_first_log.xml`
- Settings first-user state: `artifacts/first_user_ux/04_settings_first_user.png`
- Settings accessibility tree: `artifacts/first_user_ux/04_settings_first_user.xml`
- Logcat tail: `artifacts/first_user_ux/logcat_tail.txt`

## Evidence and findings

| Requirement | Evidence | Result |
|---|---|---|
| First user reaches the core workout surface | Fresh launch screenshot shows Home selected with `Today's Routine`, `Ready for today`, `Push-ups`, `0/8 sets`, and `Log 10`. | Pass |
| First useful action is visible above the fold | `Log 10` is visible in the hero card without scrolling. | Pass |
| First action can be completed quickly | One tap on `Log 10` changes the state to `10 reps`, `Active 1 days`, and `1/8 sets`. | Pass |
| Feedback is understandable | The hero changes from `Ready for today` to `10 reps`; set progress changes from `0/8 sets` to `1/8 sets`. | Pass |
| Navigation is understandable | Bottom nav exposes `Home`, `Calendar`, `Settings`; active tab is visually highlighted. | Pass |
| Early progress history is understandable | Calendar shows `Month total 10 reps`, `Active days 1 days`, and rhythm copy after one log. | Pass |
| Settings avoids non-core first-user clutter | Settings shows `GTG Coach`, `Reminders`, `All Logs`, `About / Privacy Policy`; no Cloud Sync section appears. | Pass |
| Accessibility tree exposes main content | `uiautomator` content descriptions include `Today's Routine`, `Log 10`, `GTG Coach`, `Quick Log`, and tab labels with tab positions. | Pass |
| App does not crash on first-use path | Logcat grep found no `FATAL EXCEPTION`, `E/AndroidRuntime`, or app process crash entries. | Pass |

## UI/UX heuristic review

Used `ui-ux-pro-max` guidance for mobile fitness/habit tracking, Flutter accessibility, quick logging, onboarding, navigation, and empty/early states.

### Strengths
- **Clear first action:** The Home hero immediately tells the user what to do: start with push-ups and tap `Log 10`.
- **Low friction:** The first value-producing action is one tap from the fresh Home screen; no forced tutorial blocks progress.
- **Immediate progress feedback:** Reps, active days, and set count update after the first log.
- **Supportive next step:** `GTG Coach` explains why adding max reps improves suggestions without blocking the first log.
- **Useful early history:** Calendar is not blank after the first action and explains darker heatmap cells.
- **Reduced settings noise:** Cloud Sync setup copy is absent from Settings.
- **Accessible labels:** Main sections and bottom tabs are represented in the Android accessibility tree.

### Minor non-blocking observations
- The debug build reported `am start -W` timeout before the first frame completed, then rendered successfully. This looks like debug/Isar cold-start overhead, not a UI flow blocker; production/profile startup should be checked separately before release.
- Quick Log starts below the fold on the emulator after the hero and Coach card, but the primary mission action is already above the fold, so this is acceptable for first use.
- The current first-use path skips onboarding entirely. This is good for speed, but if product strategy later wants more personalization before first log, it should remain optional/skippable.

## Test commands run

```bash
flutter test test/app_smoke_test.dart \
  test/root_overlays_widget_test.dart \
  test/dashboard_quick_log_widget_test.dart \
  test/calendar_heatmap_widget_test.dart \
  test/settings_screen_widget_test.dart
```

Result: `All tests passed!` (`+14`).

## Verdict
Pass. The current UI/UX is usable for a first-time user for the core GTG loop: launch, understand the daily mission, log a set, see progress, and find settings without Cloud Sync clutter.
