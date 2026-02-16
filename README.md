# PROJECT GTG (Flutter iOS + Android)

[![CI](https://github.com/Forevernewvie/project-gtg-flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/Forevernewvie/project-gtg-flutter/actions/workflows/ci.yml)

GTG(Grease the Groove) 방식으로 `Push-ups / Pull-ups / Dips`를 자주 기록하고, 일/주/월 통계와 캘린더 히트맵으로 확인하는 로컬 기반 모바일 앱입니다.

백엔드 서버 없이 동작하며, 데이터는 기기에만 저장됩니다.

## 목적

- 운동 루틴을 계획보다 실행 중심으로 만든다.
- 홈 화면에서 오늘 누적/빠른 입력/최근 기록을 즉시 확인한다.
- 월간 흐름을 캘린더 히트맵으로 직관적으로 파악한다.
- 로컬 저장 신뢰성을 보장한다(atomic write + corrupted file quarantine).

## 주요 기능

- 빠른 기록: 종목별 기본 세트값에 대해 `- / + / Log`로 즉시 저장
- 통계: 오늘/주간/월간 합계와 종목별 분포
- 캘린더: 월간 히트맵 + 날짜 선택 상세
- 리마인더: 간격, 조용한 시간, 주말 제외, 하루 최대 예약 수
- 온보딩: 주 종목 선택
- 스플래시: 네이티브 런치 + 인앱 2초 오버레이(탭 스킵)
- 다국어: 한국어/영어 자동 전환(gen-l10n)
- 광고(AdMob): Android 배너만 노출(Settings, All Logs)

## 스크린샷

- `docs/screenshots/splash.png`
- `docs/screenshots/home.png`

## 기술 스택

- Flutter (stable), Dart
- 상태관리: `flutter_riverpod`
- 라우팅: `go_router`
- 로컬 저장소: JSON 파일(`path_provider`, `dart:io`)
- 알림: `flutter_local_notifications`, `timezone`
- 광고: `google_mobile_ads` (Android banner only)
- 로컬라이징: `flutter_localizations`, `intl`, `gen-l10n`
- 테스트: `flutter_test` (unit + widget) + iOS smoke script
- 품질: `flutter_lints` + strict analyzer 옵션

## 아키텍처 요약

- `feature-first` 구조로 UI/상태/데이터 경계를 분리
- 도메인 로직은 가능한 순수 Dart로 구성
- OS 종속(알림 권한/스케줄링/광고 SDK)은 abstraction 뒤로 캡슐화
- 테스트/스모크 환경에서는 `UI_TESTING=true`로 OS 팝업/실광고 호출 차단

## 프로젝트 구조

```text
lib/
  app/                     # app entry, router, shell, root overlays
  core/                    # env, models, ads, date/l10n utils, theme/colors
  data/                    # json persistence (atomic write + recovery)
  features/
    onboarding/
    workout/
    calendar/
    reminders/
    settings/
  l10n/                    # app_en.arb, app_ko.arb, generated localizations
docs/
  adr/
  screenshots/
  store/
  privacy_policy.md
tool/
  gate.sh
  smoke_ios.sh
  release_android.sh
  setup_release_env.sh
  setup_android_signing.sh
  setup_android_release_prereqs.sh
  print_pages_privacy_url.sh
  check_pages_privacy_url.sh
  generate_app_icon.py
.github/workflows/
  ci.yml
```

## 시작하기

### 사전 요구사항

- Flutter SDK (stable)
- Xcode + iOS Simulator (iOS 개발 시)
- Android SDK/Emulator (Android 개발 시)
- Ruby/CocoaPods (iOS 빌드 환경)

### 설치

```bash
flutter pub get
```

### 실행

iOS:

```bash
flutter run -d "iPhone 16"
```

Android:

```bash
flutter run -d emulator-5554
```

### 기본 검증

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --dart-define=UI_TESTING=true
```

## 런타임 플래그 / 환경변수

`dart-define`:

- `UI_TESTING=true`: 권한 요청/알림/광고 초기화를 fake로 전환
- `SMOKE_SCREENSHOTS=true`: smoke 스크린샷 시 splash를 강제 표시
- `ADS_ENABLED=false`: 광고 전체 비활성화
- `ADMOB_BANNER_AD_UNIT_ID_ANDROID=<id>`: Android 배너 유닛 ID 주입
- `PRIVACY_POLICY_URL=<url>`: 앱 내 개인정보처리방침 링크 변경

환경변수(Gradle/release):

- `ADMOB_APP_ID_ANDROID=<id>`: AndroidManifest placeholder 주입용 App ID

## AdMob 정책

- 현재 광고는 Android에서만 활성화됩니다.
- 광고 포맷은 배너 1종만 사용합니다.
- 노출 위치는 `Settings`와 `All Logs` 화면 하단입니다.
- Debug 빌드는 Google test ID를 사용합니다.
- Release 빌드는 실 ID 주입이 없으면 실패하도록 가드되어 있습니다.

## Android 릴리즈(AAB)

### 1) 선행 설정(로컬 전용, 1회)

```bash
./tool/setup_android_release_prereqs.sh
```

이 스크립트는 아래를 준비합니다.

- `~/.project-gtg/release.env` (AdMob 릴리즈 값)
- `~/.project-gtg/upload-keystore.jks` (업로드 키)
- `android/key.properties` (gitignored)

### 2) 릴리즈 빌드

```bash
./tool/release_android.sh
```

산출물:

- `build/app/outputs/bundle/release/app-release.aab`

## 로컬라이징(KO/EN)

- ARB: `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb`
- 생성 설정: `l10n.yaml`
- 앱은 디바이스 언어를 따라 자동 전환됩니다.

ARB 수정 후:

```bash
flutter gen-l10n
```

## 문서

- ADR: `docs/adr/0001-tech-choices.md`
- 개인정보처리방침: `docs/privacy_policy.md`
- Play listing: `docs/store/play_listing_ko.md`, `docs/store/play_listing_en.md`
- Play 체크리스트: `docs/store/play_console_checklist.md`

GitHub Pages URL 확인 스크립트:

```bash
./tool/print_pages_privacy_url.sh
./tool/check_pages_privacy_url.sh
```

## 개발 워크플로우 (Worktree + Gate)

기본 원칙:

- `main` 직접 작업 금지
- `codex/*` 브랜치에서 개발
- `verify` worktree에서 gate 통과 후 fast-forward merge

권장 worktree:

- main: `../project-gtg-flutter`
- dev: `../project-gtg-flutter-wt-dev`
- verify: `../project-gtg-flutter-wt-verify`

Gate 실행:

```bash
cd ../project-gtg-flutter-wt-verify
./tool/gate.sh
```

`gate.sh` 단계:

1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze`
4. `flutter test --dart-define=UI_TESTING=true`
5. `./tool/smoke_ios.sh`
6. `flutter build apk --debug`

CI:

- GitHub Actions: `.github/workflows/ci.yml`

## 보안 규칙

- 시크릿/토큰/비밀번호는 저장소에 커밋하지 않습니다.
- `android/key.properties`는 반드시 gitignored 상태를 유지합니다.
- 릴리즈 민감 정보는 `~/.project-gtg/` 또는 로컬 env 파일로만 관리합니다.

## 트러블슈팅

- 광고가 안 보일 때:
  - iOS에서는 기본적으로 광고 비활성(Android only)
  - `UI_TESTING=true`이면 광고 비활성
  - 네트워크/AdMob 설정 점검 필요
- 아이콘이 즉시 안 바뀔 때:
  - 앱 삭제 후 재설치(시뮬레이터 캐시 이슈)
- 릴리즈 빌드 실패:
  - `android/key.properties`, keystore, `ADMOB_APP_ID_ANDROID` 누락 여부 확인

## 라이선스

TBD
