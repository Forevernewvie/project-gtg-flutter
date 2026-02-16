# PROJECT GTG (Flutter iOS/Android)

GTG(Grease the Groove) 스타일의 푸쉬업/풀업/딥스 루틴을 “자주, 한 세트씩” 기록하고, 일/주/월 통계와 캘린더 히트맵으로 확인하는 모바일 로컬 전용 앱입니다. (iOS/Android)

## 목적

- 운동을 “계획”보다 “실행”으로 연결한다: 홈에서 바로 기록, 바로 누적 확인
- 하루/주/월 추세를 빠르게 보여준다: 숫자 + 캘린더(월간 히트맵)
- 백엔드 없이도 신뢰 가능한 로컬 저장(Atomic write + 손상 파일 격리)
- 서버/계정 없이 가볍게 사용한다: 앱 삭제 시 로컬 기록도 함께 삭제됨

## 주요 기능 (MVP)

- 빠른 기록: 종목별 반복 횟수 +/- 후 `기록` 한 번으로 저장
- 통계: 오늘 누적(총합 + 종목별)
- 캘린더: 월간 히트맵 + 날짜 탭 시 상세(하루 누적/종목별/기록 리스트)
- 로컬 알림: 반복 주기, 조용한 시간, 주말 쉬기, 하루 최대 예약 개수
- 설정: 리마인더 / 전체 기록
- 온보딩: 주 종목 선택(첫 실행 시)
- 스플래시: 네이티브 런치 + 인앱 2초 오버레이(탭 스킵)
- Android 릴리즈: AAB 서명 빌드 스크립트 제공

## Badges

추후 CI를 붙이면 여기에 빌드/테스트/릴리즈 배지를 추가합니다.

## 데모 / 스크린샷

`docs/screenshots/` 참고:

- `docs/screenshots/splash.png`
- `docs/screenshots/home.png`

## 기술 스택

- Flutter: stable
- Language: Dart
- State: `flutter_riverpod` (no codegen)
- Routing: `go_router`
- Local storage: JSON file (atomic write + corrupted quarantine)
- Testing: `flutter_test` (unit + widget), iOS smoke(스크립트)
- Ads: `google_mobile_ads` (배너, 로컬/릴리즈 분리 설정)

## 프로젝트 구조

```text
lib/
  app/                 # router, app shell, app entry
  core/                # shared utilities (theme, colors, date, clock, models)
  data/                # persistence (json file store)
  features/
    workout/           # dashboard quick log + stats providers
    calendar/          # month heatmap + day detail
    settings/          # settings + reminders + all logs
docs/
  adr/                 # decision records
  screenshots/         # iOS simulator screenshots (gate에서 갱신)
tool/
  gate.sh              # verify worktree gate runner
  smoke_ios.sh         # iOS simulator smoke + screenshots
  setup_android_signing.sh # 로컬 서명 파일 생성 (gitignored)
  setup_release_env.sh     # 로컬 릴리즈 env 생성 (gitignored)
  release_android.sh       # Android AAB 릴리즈 빌드
test/
  *_test.dart          # unit/widget tests
```

## 시작하기 (Getting Started)

### 사전 요구사항

- Flutter SDK (stable)
- Xcode (iOS 빌드/시뮬레이터)
- Android Studio + Android SDK (Android 빌드/에뮬레이터)
- CocoaPods (권장: 최신 버전)

### 설치

```bash
flutter pub get
```

### 실행 (iOS)

```bash
flutter run -d "iPhone 16"
```

### 실행 (Android)

```bash
flutter run -d emulator-5554
```

### 환경 변수 / 플래그

권한 팝업/OS 호출을 막기 위한 테스트 플래그:

```bash
flutter run --dart-define=UI_TESTING=true
```

## 데이터 저장 정책

- 운동 기록/설정은 디바이스 로컬에 저장됩니다.
- 서버 동기화는 제공하지 않습니다.
- 앱 삭제 시 로컬 데이터는 삭제될 수 있습니다.

## 사용 방법

### 홈 (빠른 기록)

1. 홈에서 종목별 횟수를 +/-로 조정
2. `기록`을 누르면 즉시 저장되고 오늘 누적이 업데이트됩니다.

### 캘린더

1. 하단 탭에서 `캘린더`
2. 달력의 날짜를 탭하면 해당 날짜 상세(하루 누적/종목별/리스트)가 바로 표시됩니다.

## 개발자 온보딩 (Contributing)

### 기본 규칙

- `main`에서 직접 작업하지 않습니다.
- 모든 작업은 `codex/...` 브랜치에서 진행합니다.
- 각 Step은 `동작 확인 + 테스트 + 커밋`까지 완료합니다.
- 시크릿/토큰/개인정보는 로그/README/커밋에 절대 남기지 않습니다.

### Git Worktree 운영 규칙 (필수)

Worktree로 Dev/Verify를 분리합니다.

- Main worktree(기준 레포): `../project-gtg-flutter`
- Dev worktree: `../project-gtg-flutter-wt-dev` (브랜치: `codex/feature/mvp`)
- Verify worktree: `../project-gtg-flutter-wt-verify` (브랜치: `codex/verify/gate`)

원칙:

- 개발은 Dev에서만
- Gate는 Verify에서만
- Gate 통과 후에만 main을 fast-forward merge

### Gate 실행 (Verify worktree)

```bash
cd ../project-gtg-flutter-wt-verify
./tool/gate.sh
```

Gate 내용:

1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze`
4. `flutter test`
5. iOS simulator smoke + 스크린샷 2장 저장

### iOS Smoke만 실행

```bash
cd ../project-gtg-flutter-wt-verify
./tool/smoke_ios.sh
```

스크린샷은 `docs/screenshots/`에 저장되며, Gate 통과 시 커밋됩니다.

### Android 릴리즈(AAB) 빌드

1) 서명 파일 생성(최초 1회):

```bash
./tool/setup_android_signing.sh
```

2) 광고 포함 릴리즈를 사용할 경우 로컬 env 설정:

```bash
./tool/setup_release_env.sh
```

3) 릴리즈 빌드:

```bash
ADS_ENABLED=false ./tool/release_android.sh
```

성공 산출물:

- `build/app/outputs/bundle/release/app-release.aab`

주의:

- `android/key.properties`, `~/.project-gtg/*`, `.env.local`은 시크릿 파일이며 커밋 금지입니다.

### XcodeGen 규칙

현재 프로젝트는 XcodeGen을 사용하지 않습니다. (추가할 경우 이 섹션을 업데이트합니다.)

## 주요 결정 기록 (ADR)

- `docs/adr/0001-tech-choices.md`

## 라이선스

TBD
