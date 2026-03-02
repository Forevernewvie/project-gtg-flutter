# First-Time UX Naturalness Audit (Executed)

## Verdict
- **WARN**: overall usable, but not fully natural for users with zero GTG context.

## Key Findings (Executed Review)
| Severity | Area | Finding | Why it can confuse first-time users |
|---|---|---|---|
| High | Home | Primary next-step guidance is implicit (quick log control is clear but not explicitly guided) | Users may understand controls but hesitate on “what to do first” |
| High | Calendar | Heatmap concept relies on user interpretation | New users may not immediately map color depth to reps intensity |
| Medium | Settings | Reminder and All Logs are nested under Settings (not top-level nav) | Users may search in Home/Calendar first |
| Medium | Onboarding | GTG concept tone is motivational but can be abstract without concrete action hint | Some users may not know what “focus move” implies operationally |
| Low | Theme | Theme section is clear; immediate effect is documented well | Minor only |

## What was done in this execution
- Performed source-based heuristic audit against first-time-user criteria.
- Confirmed current copy baseline in:
  - `lib/l10n/app_en.arb`
  - `lib/l10n/app_ko.arb`
- Confirmed current screen IA in:
  - `lib/features/workout/dashboard_screen.dart`
  - `lib/features/settings/settings_screen.dart`
  - `lib/features/calendar/calendar_screen.dart`

## Recommended minimal UX fixes (next patch)
1. Add one short helper line in Home Quick Log header:
   - EN: “Adjust reps, then tap Record.”
   - KO: “횟수를 조정한 뒤 기록을 누르세요.”
2. Add one short helper line near Calendar heatmap title:
   - EN: “Darker cells mean more reps.”
   - KO: “색이 진할수록 횟수가 많습니다.”
3. Keep Settings card labels but add stronger action phrasing for reminder subtitle:
   - EN: “Set interval, quiet hours, and weekends off.”
   - KO: “반복 주기, 방해 금지 시간, 주말 제외를 설정합니다.”

## Quality state at audit time
- Local gates currently pass after overflow hardening branch merge:
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`

## Remaining UX risk
- First-time comprehension depends on subtle text cues; one extra instructional hint on Home and Calendar would reduce hesitation significantly.
