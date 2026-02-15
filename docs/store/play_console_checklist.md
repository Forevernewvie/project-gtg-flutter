# Google Play Console 제출 체크리스트 (PROJECT GTG)

목표: PROJECT GTG를 Google Play에 “거절 없이” 올릴 수 있도록, 콘솔 입력/정책 항목을 빠짐없이 정리합니다.

## 1) 기본 정보
- 앱 이름: PROJECT GTG
- 카테고리(추천): Health & Fitness
- 언어: 한국어(필요 시 영어 추가)
- 릴리즈 형식: Android App Bundle(AAB)
- 버전 정책:
  - `pubspec.yaml`의 `version: x.y.z+N`
  - Play 업로드마다 **N(versionCode)** 는 반드시 증가해야 합니다.

## 2) 타겟 연령(권장 기본값)
추천: **13+**
- 전연령(가족 정책 포함)으로 갈수록 요구사항/검증/광고 제약이 늘어납니다.
- “아동 대상”이 아니라면 13+가 MVP 출시 난이도가 낮습니다.

## 3) 광고(AdMob) 설정 체크
앱은 AdMob 배너 광고를 사용합니다.
- 노출 위치: **설정 화면**, **전체 기록 화면** 하단(홈/캘린더에는 노출하지 않음)
- 릴리즈 빌드에서 TEST ID 금지:
  - AdMob App ID/Ad Unit ID 모두 실제 값이어야 합니다.
  - 릴리즈 빌드 스크립트: `tool/release_android.sh`

### 릴리즈용 AdMob 값 주입(커밋 금지)
- `ADMOB_APP_ID_ANDROID`: Gradle manifestPlaceholder로 주입
- `ADMOB_BANNER_UNIT_ID_ANDROID`: Dart `--dart-define`로 주입

## 4) Data Safety(데이터 안전) 작성 가이드
중요: Google 정책/폼 구조는 변경될 수 있습니다. 제출 전 “현재 Play Console의 최신 문항”과 “Google Mobile Ads(AdMob) 문서”를 기준으로 최종 입력을 확정하세요.

### 앱 자체 데이터 처리(우리 앱의 핵심)
- 운동 기록/설정(종목/횟수/시간/리마인더/온보딩 선택)은 **사용자 기기 내부에만 저장**
- 개발자 서버로 전송하는 백엔드가 없음(로컬 only)

### 제3자 SDK(AdMob)로 인해 달라지는 부분
AdMob은 광고 제공/측정/부정클릭 방지 등을 위해 일부 데이터를 처리할 수 있습니다.
Play Console Data Safety에서는 “앱이 수집하는 데이터(제3자 SDK 포함)”를 기준으로 답해야 합니다.

권장 접근(실수 방지):
1) AdMob 콘솔/문서에서 “SDK가 수집할 수 있는 데이터 유형”을 확인
2) 앱에서 “실제로 광고를 켜는 화면/빌드”를 기준으로 수집/공유 여부를 체크
3) 아래 항목은 수집/공유 가능성이 높으므로 특히 주의해서 검증:
   - Device or other IDs(광고 식별자 등)
   - App activity(앱 내 상호작용/광고 상호작용 등)

### 사용자 요청에 의한 삭제/데이터 처리
- 앱 데이터는 로컬 저장이므로 “삭제”는 일반적으로 앱 삭제로 해결됩니다.
- 광고 관련 데이터는 Google 및 OS 설정에 따를 수 있습니다.

## 5) 개인정보처리방침(Privacy Policy) URL
Play Console에는 “URL”이 필요합니다.
- 레포 문서: `docs/privacy_policy.md`
- 권장: GitHub Pages로 HTML 형태로 게시 후 그 URL을 사용
- 최소안: GitHub raw 링크도 가능하나, 심사/표시 품질을 위해 Pages를 권장

앱 내에서도 Settings의 “개인정보 처리방침”에서 동일한 URL을 열 수 있도록 맞춥니다.

## 6) 권한/정책 관련 체크(앱 동작과 일치해야 함)
앱에서 사용하는/사용할 수 있는 권한:
- 알림 권한(POST_NOTIFICATIONS): 리마인더 “켜기” 시점에만 요청(첫 실행 강제 팝업 없음)
- 인터넷/네트워크 상태: 광고 로딩
- Advertising ID(AD_ID): AdMob 광고

Play Console의 “권한”/“개인정보” 설명과 앱 동작이 일치해야 합니다.

## 7) 제출 전 로컬 릴리즈 검증(필수)
1) 키/서명 준비(커밋 금지)
- `android/key.properties` (gitignored)
- 업로드 키스토어 파일 존재 확인
2) AdMob 릴리즈 값 주입(커밋 금지)
- `export ADMOB_APP_ID_ANDROID="..."`
- `export ADMOB_BANNER_UNIT_ID_ANDROID="..."`
3) AAB 빌드
- `./tool/release_android.sh`
4) 생성물 확인
- `build/app/outputs/bundle/release/app-release.aab`

## 8) 롤백 전략(거절/버그 발생 대비)
- 광고 문제로 심사/크래시 발생 시:
  - 릴리즈에서 임시로 `ADS_ENABLED=false`로 빌드해서 “광고 없는 버전”으로 먼저 통과 후,
  - 다음 버전에 광고를 재도입(정책/ID/노출 위치 재검증)

