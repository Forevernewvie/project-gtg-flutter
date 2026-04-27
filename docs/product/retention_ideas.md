# PROJECT GTG Retention / Session-Length Ideas

## Product prompt used

> You are a product trio for PROJECT GTG, a local-first Flutter app for Grease The Groove training. The app supports push-up, pull-up, dip logging, GTG Coach, reminders, calendar heatmap, all logs, onboarding, Korean/English localization, and theme settings. Brainstorm product ideas that increase meaningful in-app time without violating GTG's low-friction philosophy. Avoid addictive dark patterns. Optimize for: more frequent daily check-ins, more reflection after sets, more coach trust, and repeat weekly use. Generate ideas from PM, Designer, and Engineer perspectives, then prioritize the top 5 with assumptions to validate.

## Opportunity

PROJECT GTG is intentionally quick: users should log a set and leave. So the goal should not be raw screen time for its own sake. The better retention goal is **more meaningful micro-sessions per day** and **slightly richer reflection moments after each set**.

North-star candidate:
- Weekly active training days with at least 2 logged micro-sessions

Input metrics:
- Sets logged per active day
- Reminder-to-log conversion rate
- Coach card opens per week
- Calendar review opens per week
- Users with baseline max reps set
- 7-day / 28-day retention

## Product Manager ideas

1. **Daily GTG Plan Card** — turn GTG Coach into a daily plan with target sets, recommended reps, and remaining sets.
2. **Micro-session Streaks** — track consistency as “active training days” and “sets completed today,” not infinite streak pressure.
3. **Weekly Review** — every Sunday, show a short recap: best day, total reps, most consistent move, and next week suggestion.
4. **Retest Reminder Loop** — prompt users to retest max reps after a safe interval when coach data gets stale.
5. **Goal Mode** — let users pick a simple goal: strength base, habit building, pull-up focus, push-up volume, or dip support.

## Designer ideas

1. **Post-log Celebration Sheet** — after recording a set, show a compact confirmation with today progress, next suggested window, and undo/edit.
2. **Rhythm Calendar 2.0** — make the heatmap tappable with richer day stories: when sets happened, best exercise, and mini insight.
3. **Coach Conversation Cards** — short, friendly explanations: “Why 6 reps?” “Why rest?” “When should I retest?”
4. **Home Progress Ring** — visual progress toward today’s target sets, visible without scrolling.
5. **Gentle Empty States** — make no-data screens suggest one clear next action instead of only stating emptiness.

## Engineer ideas

1. **Local Insight Engine** — derive trend insights from existing logs without backend: active days, best windows, fatigue risk, missed reminders.
2. **Reminder Optimization** — learn which reminder windows convert to logs and suggest better intervals locally.
3. **Session Timeline Model** — group logs into micro-sessions based on time gaps, enabling richer analytics without manual session starts.
4. **Coach Recommendation History** — store recommendation snapshots so users can see how plan changes over time.
5. **Notification Action Logging** — Android notification action buttons: +recommended reps, snooze, skip.

## Prioritized top 5

### 1. Daily GTG Plan Card

One-sentence description: Upgrade the home coach card into a daily plan showing recommended reps, target sets, completed sets, remaining sets, and next suggested set timing.

Why selected:
- Strong alignment with GTG behavior.
- Increases repeated daily check-ins without adding heavy workflows.
- Uses existing coach, logs, and dashboard surfaces.

Key assumptions:
- Users want guidance, not just raw logging.
- A visible “remaining sets” indicator increases return visits.
- The plan does not feel like pressure or punishment.

Validation:
- A/B compare current coach card vs daily plan card.
- Measure daily sets/user, coach card taps, 7-day retention.

### 2. Post-log Celebration Sheet

One-sentence description: After a set is recorded, show a lightweight bottom sheet with confirmation, progress toward today’s plan, undo/edit, and next set suggestion.

Why selected:
- Adds a meaningful 5–10 second moment after the core action.
- Reinforces progress immediately.
- Can reduce accidental logs through undo/edit.

Key assumptions:
- A post-log sheet does not slow down quick logging too much.
- Users find next-set guidance helpful.
- Micro-celebration improves perceived reward.

Validation:
- Track sheet dismissal time, undo usage, second-set conversion, user complaints.

### 3. Weekly Review

One-sentence description: Add a weekly recap screen/card summarizing reps, active days, strongest pattern, missed rhythm, and a one-line next-week suggestion.

Why selected:
- Creates a natural weekly return loop.
- Makes calendar/log data emotionally useful.
- Encourages reflection without social or competitive pressure.

Key assumptions:
- Users care about weekly progress summaries.
- A short recap is enough; charts should stay simple.
- Review nudges users to set a baseline or improve reminders.

Validation:
- Measure weekly review opens, next-week active days, calendar opens after review.

### 4. Local Insight Engine

One-sentence description: Generate small personalized insights from local logs, such as “You usually complete sets before lunch” or “Pull-ups are most consistent on weekdays.”

Why selected:
- Differentiates the app without backend complexity.
- Makes data feel alive.
- Powers plan card, calendar, reminders, and weekly review.

Key assumptions:
- Existing logs are enough to produce useful insights.
- Users trust simple transparent insights.
- Insights increase return intent.

Validation:
- Start with deterministic rules and test comprehension in-app.
- Track insight card taps and downstream actions.

### 5. Reminder Optimization

One-sentence description: Let reminders adapt gently based on local behavior, suggesting better intervals or quiet windows when the user repeatedly ignores reminders.

Why selected:
- Reminders are already in scope.
- Better timing can increase micro-sessions per day.
- Supports retention while respecting user control.

Key assumptions:
- Reminder timing is a major barrier to consistency.
- Users accept suggestions if they remain optional.
- Local-only optimization is sufficient.

Validation:
- Track reminder-to-log conversion before/after suggestion.
- Measure opt-in rate for suggested timing changes.

## Recommended MVP sequence

1. Daily GTG Plan Card
2. Post-log Celebration Sheet
3. Local Insight Engine v1 with deterministic rules
4. Weekly Review
5. Reminder Optimization

## Suggested implementation slices

### Slice 1: Daily Plan Card
- Extend existing coach summary to expose daily target, completed, remaining, progress, recommendation.
- Redesign dashboard coach card around the plan.
- Add tests for progress calculation and dashboard rendering.

### Slice 2: Post-log Sheet
- After quick log success, show bottom sheet/snackbar hybrid.
- Include undo/edit later; MVP can show progress + next suggestion only.
- Test no duplicate log on rapid taps.

### Slice 3: Insight Engine
- Create pure service from `List<ExerciseLog>` to `List<GtgInsight>`.
- Start with 3 insights: best active day, common time window, stale baseline/retest due.
- Use in dashboard and weekly review.

## Guardrails

- Do not optimize for endless scrolling.
- Do not use guilt-heavy streak loss messaging.
- Keep the primary log action one tap away.
- Make all suggestions dismissible and user-controlled.
- Maintain local-first privacy positioning.
