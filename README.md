# PROJECT GTG (Flutter + Backend)

[![Google Play Store](https://img.shields.io/badge/Google_Play-414141?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.forevernewvie.projectgtg&hl=kr)
[![Server CI/CD](https://github.com/Forevernewvie/project-gtg-flutter/actions/workflows/server-ci.yml/badge.svg)](https://github.com/Forevernewvie/project-gtg-flutter/actions/workflows/server-ci.yml)

A local-first GTG (Grease The Groove) workout app focused on frequent, low-fatigue training.
The app currently targets Push-up, Pull-up, and Dip logging with calendar visibility, reminders, and theme/localization support.

Now upgraded with a **Node.js Express Backend Server** for real-time forced updates and maintenance management!

## 🚀 TL;DR (Run in 3 Steps)

### App (Flutter)
```bash
flutter pub get
flutter run -d emulator-5554 --debug
```

### Server (Node.js)
```bash
cd server/gtg-update-server
npm install
npm run dev
```

## 🌟 What This Project Includes (v1.3.0 State)

### 1. Flutter Mobile App (`lib/`)
- **Zero-Friction Logging**: Android Home Screen 1-Tap Widget & Wear OS Sub-app.
- **Home Dashboard & UI**: Quick logging with high dopamine neon animations & adaptive GTG Coach card.
- **Calendar & Consistency Tracking**: Monthly activity heatmap & streak visualization.
- **Settings & Preferences**: Theme mode selector (Cyberpunk/Neon Glass), customizable interval reminders.
- **Localization**: Full Korean (`ko`) and Global English (`en`) fallback support.

### 2. Node.js Update Backend (`server/gtg-update-server/`)
- **Real-time Force Update API**: Endpoint `/api/v1/check-update` to control critical force updates and maintenance mode.
- **Enterprise-grade Setup**: 
  - Express + TypeScript architecture.
  - Deployed 24/7 on a local Linux server using **PM2**.
  - Securely exposed to the internet via **Cloudflare Zero Trust Tunnel** (Anycast HTTPS).
- **CI/CD Integration**: Fully integrated with GitHub Actions (`server-ci.yml`) for automated build and Type Checking.

## 📂 Project Layout

```text
lib/
  app/          # app root, router, shell, overlays
  core/         # theme, models, env, shared utils
  data/         # persistence layer (Isar + JSON)
  features/     # onboarding, workout, calendar, reminders, settings
  l10n/         # ARB + generated localization files

server/
  gtg-update-server/  # Express + TS Backend Server 🚀
    src/
    data/       # versions.json (Control file)

wear_app/        # Wear OS Flutter Sub-app
test/            # unit/widget/layout tests
integration_test/# flow-level integration tests
.github/workflows/ # GitHub Actions CI/CD pipelines
```

## 🛠️ Tech Stack

### Frontend (App)
- **Framework**: Flutter (Dart 3.x)
- **State Management**: `flutter_riverpod`
- **Navigation**: `go_router`
- **Persistence**: `isar_community` (High-performance local NoSQL)
- **Localization**: Flutter ARB

### Backend (Server)
- **Runtime**: Node.js 20+
- **Framework**: Express & TypeScript
- **Daemon/Process Manager**: PM2
- **Networking**: Cloudflare Tunnel (cloudflared)
- **CI/CD**: GitHub Actions

## 🔒 Security & Secrets Basics

- Do not commit `.env*`, keystore files, or signing secrets.
- Keep `android/key.properties` local-only (gitignored).
- Use `/tool/security/` scripts and CI secret scanning before release.

## 🔄 Recommended Git Flow Workflow

```bash
git switch main
git pull --ff-only
git switch -c feature/<task-name>

# make changes (App or Server)

# If App:
dart format --set-exit-if-changed .
flutter analyze
flutter test

# If Server:
cd server/gtg-update-server
npm run build

git add .
git commit -m "feat: summary"
git push -u origin feature/<task-name>
```

Then open a PR to `main`. CI/CD will automatically verify the changes!

## 📜 License

Internal/private project (`publish_to: none`).
