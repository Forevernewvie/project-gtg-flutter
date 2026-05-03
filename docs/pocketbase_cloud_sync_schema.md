# PocketBase Cloud Sync Schema

This app keeps offline-first local persistence. PocketBase is optional and is enabled only when the app is built with all of these dart-defines:

```bash
--dart-define=GTG_POCKETBASE_URL=https://your-pocketbase.example.com \
--dart-define=GTG_POCKETBASE_EMAIL=user@example.com \
--dart-define=GTG_POCKETBASE_PASSWORD=secret \
--dart-define=GTG_POCKETBASE_DEVICE_ID=device-1
```

## Collections

### `users`
Use PocketBase's default auth collection.

### `gtg_workout_logs`
Fields:

| Field | Type | Notes |
| --- | --- | --- |
| `user` | relation -> users | owner |
| `clientId` | text | stable local `ExerciseLog.id`; should be unique per user |
| `exerciseType` | select/text | `pushUp`, `pullUp`, `dips` |
| `reps` | number | reps logged |
| `loggedAt` | date | log timestamp |
| `clientUpdatedAt` | date | last client mutation |
| `deviceId` | text | source device |
| `deleted` | bool | reserved for soft delete |

Suggested API rules:

```text
list/view/create/update/delete: user = @request.auth.id
```

For create, PocketBase evaluates after submitted data, so the client sends `user` as the authenticated record id.

### `gtg_user_preferences`
Fields:

| Field | Type | Notes |
| --- | --- | --- |
| `user` | relation -> users | owner |
| `hasCompletedOnboarding` | bool | onboarding flag |
| `primaryExercise` | select/text | `pushUp`, `pullUp`, `dips` |
| `primaryExerciseMaxReps` | number | GTG baseline |
| `primaryExerciseDailySetTarget` | number | target sets/day |
| `primaryExerciseLastMaxTestedAt` | date | last max test |
| `clientUpdatedAt` | date | last client mutation |
| `deviceId` | text | source device |

Suggested API rules:

```text
list/view/create/update/delete: user = @request.auth.id
```

### `gtg_coach_recommendations`
Fields:

| Field | Type | Notes |
| --- | --- | --- |
| `user` | relation -> users | owner |
| `date` | date | recommendation day |
| `exerciseType` | select/text | `pushUp`, `pullUp`, `dips` |
| `recommendedSets` | number | server target sets |
| `recommendedRepsPerSet` | number | server target reps/set |
| `intensity` | select/text | `recover`, `maintain`, `progress` |
| `message` | text | optional server copy |
| `reasonCode` | text | e.g. `restart_after_gap` |
| `generatedAt` | date | generation time |

Suggested API rules:

```text
list/view: user = @request.auth.id
create/update/delete: admin only or server hook only
```

## Server recommendation generation
PocketBase cron can generate `gtg_coach_recommendations` from recent `gtg_workout_logs` and `gtg_user_preferences`. The app already falls back to local rules when no remote recommendation exists.
