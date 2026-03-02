You are a Senior Mobile UX Researcher and Product UX Writer.

Goal:
Evaluate this Flutter app as if you know nothing about its features, then improve first-time usability without changing business logic.

Repository:
- /Users/jaebinchoi/Desktop/project-gtg-flutter

Hard constraints:
- Keep existing feature logic and navigation intact.
- Prefer copy/IA/hint-level UX improvements first.
- If UI changes are required, keep them minimal and test-safe.
- Do not remove screens or controls.

Audit scope:
- Onboarding, Home, Calendar, Reminder, History(All Logs), Settings
- First-time comprehension in under 60 seconds
- Task discoverability: “log my first set”, “check today”, “set reminders”, “switch theme”
- Clarity of labels, subtitles, and section intent
- Error-prevention and affordance of primary actions
- One-hand usability and visual hierarchy under larger text scales

Execution steps:
1) Read current copy and screen structure from source.
2) Run a first-time-user heuristic review using:
   - Learnability
   - Discoverability
   - Information scent
   - Consistency
   - Error prevention
3) Produce findings table with severity: Critical/High/Medium/Low.
4) Propose minimal UX fixes (copy first, then tiny layout/spacing changes if needed).
5) Apply fixes directly.
6) Re-run quality gates:
   - flutter pub get
   - dart format --set-exit-if-changed .
   - flutter analyze
   - flutter test
7) Output concise report:
   - Naturalness verdict: PASS/WARN/FAIL
   - Top confusion points (before -> after)
   - Files changed
   - Verification results
   - Remaining UX risks

Definition of “natural UX” for this task:
- A new user can identify primary action and complete first log within 10–20 seconds.
- Section names are self-explanatory without prior GTG knowledge.
- Settings options communicate effect clearly.
- No dead-end language or ambiguous CTA wording.
