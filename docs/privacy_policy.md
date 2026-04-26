---
title: 개인정보 처리방침
---

# 개인정보 처리방침 (PROJECT GTG)

시행일: 2026-03-08  
최종 업데이트: 2026-04-26

PROJECT GTG(이하 "앱")는 푸쉬업, 풀업, 딥스 중심의 GTG(Grease The Groove) 운동 기록과 리마인더 기능을 제공하는 로컬 기반 모바일 앱입니다.  
본 개인정보 처리방침은 앱에서 어떤 정보를 처리하는지, 어떤 외부 서비스가 관여하는지, 사용자가 어떤 선택권을 가지는지 설명합니다.

## 1. 개인정보처리방침 적용 범위

본 방침은 아래 범위에 적용됩니다.

- Android 및 iOS용 PROJECT GTG 앱
- 앱 설정 화면에서 열리는 개인정보 처리방침 링크
- 앱에 포함될 수 있는 제3자 서비스 SDK(예: 광고 SDK)

본 방침은 앱 외부의 제3자 웹사이트나 서비스에 직접 적용되지 않습니다. 해당 서비스에는 각 서비스 제공자의 정책이 적용됩니다.

## 2. 앱이 처리하는 정보

### 2-1. 사용자가 앱에 직접 입력하거나 설정하는 정보

앱은 다음과 같은 정보를 사용자 기기 내부에 저장할 수 있습니다.

- 운동 기록 정보
  - 운동 종류(푸쉬업, 풀업, 딥스)
  - 반복 횟수
  - 기록 시각
- 온보딩 설정 정보
  - 사용자가 선택한 대표 운동 종목
- 리마인더 설정 정보
  - 알림 활성화 여부
  - 반복 주기
  - 하루 최대 알림 수
  - 조용한 시간
  - 주말 건너뛰기 여부
- 앱 설정 정보
  - 테마 설정(System, Light, Dark)

위 정보는 기본적으로 **사용자의 기기 내부에만 저장**되며, 앱 개발자가 운영하는 별도 서버로 전송하지 않습니다.

### 2-2. 광고 제공 과정에서 처리될 수 있는 정보

앱은 광고 표시를 위해 Google AdMob SDK를 사용할 수 있습니다. 현재 광고 기능은 **Android 버전에서만 활성화될 수 있으며**, 설정 화면과 전체 기록 화면 하단 배너 영역에서 제한적으로 노출됩니다. 이 경우 Google은 광고 제공, 측정, 품질 개선, 부정 클릭 방지 등을 위해 다음과 같은 정보를 처리할 수 있습니다.

- 광고 식별자(예: Advertising ID)
- IP 주소
- 기기 및 앱 정보
- 진단 정보
- 기기 또는 기타 식별자(예: 기기 식별자, 계정 수준 식별자, SDK가 처리하는 기타 식별자)
- 광고 상호작용 정보 및 앱 내 광고 관련 활동 정보

이 정보의 구체적인 처리 범위와 보관 방식은 Google 정책 및 사용자 기기 설정에 따라 달라질 수 있습니다.

- Google 개인정보처리방침: [https://policies.google.com/privacy](https://policies.google.com/privacy)
- Google 광고 정책 안내: [https://policies.google.com/technologies/ads](https://policies.google.com/technologies/ads)

## 3. 정보를 처리하는 목적

앱은 다음 목적 범위 안에서만 정보를 처리합니다.

- 운동 기록 저장 및 조회
- 홈 대시보드, 전체 기록, 캘린더 통계 제공
- 사용자가 설정한 로컬 리마인더 알림 제공
- 앱 테마 및 사용 환경 유지
- Android 버전 내 광고 제공 및 광고 품질/안정성 관리

## 4. 개발자 서버 전송 여부

PROJECT GTG는 현재 사용자 계정 시스템이나 자체 백엔드를 운영하지 않습니다.

- 운동 기록, 온보딩 선택, 리마인더 설정, 테마 설정은 기본적으로 로컬 저장됩니다.
- 앱 개발자가 운영하는 서버로 사용자의 운동 기록을 수집하거나 판매하지 않습니다.
- 단, 광고 SDK 사용 시 광고 제공 목적 범위에서 제3자(Google)가 일부 정보를 처리할 수 있습니다.

## 5. 제3자 제공 및 외부 처리

앱은 광고 기능 제공을 위해 Google AdMob SDK를 사용할 수 있으며, 이 경우 Google이 관련 정보를 처리할 수 있습니다. 현재 광고 SDK는 Android 버전에서만 활성화될 수 있습니다.

현재 확인된 주요 외부 처리 주체는 다음과 같습니다.

- Google AdMob / Google Mobile Ads SDK

앱 개발자는 운동 기록과 설정 데이터를 별도의 데이터 브로커나 마케팅 업체에 판매하지 않습니다.

## 6. 권한 사용 안내

앱은 기능 제공을 위해 아래 권한 또는 기능에 접근할 수 있습니다.

- 알림 권한
  - 리마인더 기능을 사용자가 직접 켜는 경우에만 요청합니다.
  - 첫 실행 시 강제로 요청하지 않습니다.
- 인터넷/네트워크 접근
  - 광고 로딩 및 외부 정책 페이지 열기에 사용될 수 있습니다.
- 광고 식별자 관련 권한(Android)
  - Google AdMob 동작 과정에서 사용될 수 있습니다.
- 기타 광고/진단 관련 정보
  - Google Mobile Ads SDK가 광고 요청 처리, 측정, 안정성 확인 과정에서 진단 정보와 식별자를 처리할 수 있습니다.

## 7. 데이터 보관 기간 및 삭제

### 7-1. 로컬 저장 데이터

- 운동 기록 및 설정 데이터는 사용자의 기기에 저장됩니다.
- 사용자가 앱 내 기능으로 데이터를 삭제하거나 앱을 삭제하는 경우, 일반적으로 해당 로컬 데이터는 제거됩니다.

### 7-2. 광고 관련 데이터

- 광고 관련 데이터는 Google 정책, Google 계정 설정, OS 설정에 따라 처리 및 보관될 수 있습니다.
- 해당 데이터의 삭제나 제한은 Google 또는 기기 운영체제에서 제공하는 설정을 통해 관리해야 할 수 있습니다.

## 8. 사용자의 선택권

사용자는 다음과 같은 선택을 할 수 있습니다.

- 리마인더 기능을 사용하지 않을 수 있습니다.
- 기기 설정에서 알림 권한을 철회할 수 있습니다.
- 광고 개인화 관련 설정을 Google 또는 기기 설정에서 변경할 수 있습니다.
- 앱을 삭제하여 로컬 저장 데이터를 제거할 수 있습니다.

## 9. 아동의 개인정보

앱은 특정 아동을 대상으로 설계된 서비스가 아닙니다.  
다만 앱은 전연령 사용 환경에서 설치될 수 있으며, 광고 노출 방식은 Google 정책, 계정 설정, 기기 설정에 따라 달라질 수 있습니다.

## 10. 보안에 관한 사항

앱은 기본적으로 사용자 데이터를 기기 내부에 저장하는 구조를 사용합니다.  
다만 모바일 기기 자체의 보안 상태, OS 취약점, 제3자 SDK 정책 변경 등 외부 요인으로 인해 모든 위험을 완전히 배제할 수는 없습니다.

앱 개발자는 다음 원칙을 따릅니다.

- 불필요한 서버 수집을 하지 않음
- 최소한의 권한만 사용함
- 정책 및 외부 SDK 변경 사항을 검토함

## 11. 해외 이전 가능성

광고 SDK 사용 시, Google이 제공하는 인프라 특성상 관련 데이터가 대한민국 외 지역에서 처리될 수 있습니다.  
이 경우 해당 처리는 Google의 정책과 국제 데이터 처리 기준을 따릅니다.

## 12. 문의 방법

문의, 제안, 삭제 요청은 아래 채널로 접수할 수 있습니다.

- GitHub Issues: [https://github.com/Forevernewvie/project-gtg-flutter/issues](https://github.com/Forevernewvie/project-gtg-flutter/issues)

## 13. 개인정보처리방침 변경

앱 기능, 광고 SDK 구성, 법적 요구사항, 스토어 정책이 변경될 경우 본 방침도 함께 수정될 수 있습니다.

- 중요한 변경이 있는 경우 시행일 또는 최종 업데이트 일자를 함께 갱신합니다.
- 최신 버전은 앱에서 연결되는 공개 문서 URL을 기준으로 확인할 수 있습니다.

---

# Privacy Policy (PROJECT GTG)

Effective date: 2026-03-08  
Last updated: 2026-04-26

PROJECT GTG ("the App") is a local-first mobile app for logging GTG (Grease The Groove) workouts focused on push-ups, pull-ups, and dips.  
This Privacy Policy explains what information the App processes, which third-party services may be involved, and what choices users have.

## 1. Scope of this Privacy Policy

This policy applies to:

- the PROJECT GTG app for Android and iOS
- the Privacy Policy link opened from the app's Settings screen
- third-party service SDKs that may be included in the app, such as advertising SDKs

This policy does not directly apply to third-party websites or services outside the app. Those services are governed by their own policies.

## 2. Information the App Processes

### 2-1. Information entered or configured by the user

The app may store the following information on the user's device:

- Workout log data
  - exercise type (push-ups, pull-ups, dips)
  - repetition count
  - time of the record
- Onboarding preferences
  - the user's selected primary exercise
- Reminder settings
  - whether reminders are enabled
  - reminder interval
  - maximum reminders per day
  - quiet hours
  - whether weekends are skipped
- App settings
  - theme preference (System, Light, Dark)

This information is stored locally on the user's device by default and is not transmitted to a server operated by the app developer.

### 2-2. Information that may be processed for advertising

The app may use the Google AdMob SDK to display ads. At this time, ads may only be enabled in the **Android version** of the app and are limited to banner placements at the bottom of the Settings screen and the All Logs screen. In that case, Google may process information such as the following for ad delivery, measurement, quality improvement, and invalid traffic prevention:

- advertising identifiers (for example, Advertising ID)
- IP address
- device and app information
- diagnostic information
- device or other identifiers (for example, device identifiers, account-level identifiers, or other identifiers processed by the SDK)
- ad interaction information and ad-related in-app activity

The exact scope and retention of this information may vary depending on Google policies and the user's device settings.

- Google Privacy Policy: [https://policies.google.com/privacy](https://policies.google.com/privacy)
- Google Ads Policy information: [https://policies.google.com/technologies/ads](https://policies.google.com/technologies/ads)

## 3. Purposes of Processing

The app processes information only for the following purposes:

- storing and displaying workout logs
- providing the Home dashboard, All Logs view, and calendar statistics
- sending local reminder notifications configured by the user
- maintaining app theme and usage preferences
- serving ads in the Android version and managing ad quality and stability

## 4. Whether Data Is Sent to Developer Servers

PROJECT GTG does not currently operate a user account system or its own backend service.

- workout logs, onboarding choices, reminder settings, and theme settings are stored locally by default
- the app developer does not collect or sell workout logs through a developer-operated server
- however, when the advertising SDK is used, a third party (Google) may process some information for advertising purposes

## 5. Third-Party Processing and Disclosure

The app may use the Google AdMob SDK to provide advertising features, in which case Google may process related information. The advertising SDK may currently be enabled only in the Android version.

The main third-party processor currently identified is:

- Google AdMob / Google Mobile Ads SDK

The app developer does not sell workout or settings data to data brokers or marketing companies.

## 6. Permissions and Device Access

The app may access the following permissions or device capabilities to provide its features:

- Notification permission
  - requested only if the user explicitly enables reminders
  - not forced on first launch
- Internet/network access
  - may be used for loading ads and opening external policy pages
- Advertising identifier-related permission (Android)
  - may be used as part of Google AdMob operation
- Other ad/diagnostic-related information
  - the Google Mobile Ads SDK may process diagnostic information and identifiers while handling ad requests, measurement, and stability checks

## 7. Data Retention and Deletion

### 7-1. Locally stored data

- Workout logs and settings are stored on the user's device.
- If the user deletes data through app features or uninstalls the app, that local data is generally removed.

### 7-2. Advertising-related data

- Advertising-related data may be processed and retained according to Google policies, Google account settings, and OS settings.
- Deletion or restriction of that data may need to be managed through Google or the device operating system settings.

## 8. User Choices

Users may choose to:

- not use the reminder feature
- revoke notification permission through device settings
- change ad personalization settings through Google or device settings
- remove locally stored data by uninstalling the app

## 9. Children's Privacy

The app is not designed specifically for children.  
However, it may be installed in environments used by people of all ages, and ad delivery may vary depending on Google policies, account settings, and device settings.

## 10. Security

The app primarily stores user data on the device itself.  
However, external factors such as the security condition of the mobile device, OS vulnerabilities, or policy changes by third-party SDK providers may still create risks that cannot be fully eliminated.

The app developer follows these principles:

- no unnecessary server-side collection
- use of the minimum permissions needed
- review of policy changes and third-party SDK changes

## 11. International Data Transfers

When the advertising SDK is used, related data may be processed outside the Republic of Korea due to the nature of Google's infrastructure. In that case, such processing is governed by Google's policies and international data processing standards.

## 12. Contact

Questions, suggestions, and deletion-related requests may be submitted through:

- GitHub Issues: [https://github.com/Forevernewvie/project-gtg-flutter/issues](https://github.com/Forevernewvie/project-gtg-flutter/issues)

## 13. Changes to this Privacy Policy

This policy may be updated if app features, advertising SDK configuration, legal requirements, or store policies change.

- If there is a material change, the effective date or last updated date will also be updated.
- The latest version can be checked through the public document URL linked from the app.
