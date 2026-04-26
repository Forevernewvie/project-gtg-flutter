# Hosted Update + Release Rollout Checklist

## Scope
This checklist covers:
- shipping a new Android release bundle
- updating the hosted `version.json`
- verifying the in-app update prompt path

## Before building
- [ ] `android/key.properties` exists locally
- [ ] release keystore file path in `android/key.properties` is valid
- [ ] `~/.project-gtg/release.env` has:
  - [ ] `ADMOB_APP_ID_ANDROID`
  - [ ] `ADMOB_BANNER_UNIT_ID_ANDROID`
- [ ] `docs/version.json` is updated for the intended release version
- [ ] `python3 tool/validate_hosted_update_manifest.py` passes

## Build and upload
- [ ] Build release AAB
- [ ] Confirm generated AAB path
- [ ] Confirm target `versionCode` is higher than the previous Play Console upload
- [ ] Upload AAB to Play Console internal testing first
- [ ] Add release notes in KO/EN

## Hosted update manifest
- [ ] Update `docs/version.json`
  - [ ] `latestVersionCode`
  - [ ] `latestVersionName`
  - [ ] `forceUpdate`
  - [ ] `message`
  - [ ] `storeUrl`
- [ ] Push branch / merge to `main`; the Pages workflow deploys `docs/` after CI succeeds
- [ ] Verify hosted file is reachable:
  - [ ] `https://forevernewvie.github.io/project-gtg-flutter/version.json`

## App behavior verification
- [ ] Debug build does **not** show update prompt automatically
- [ ] Release/profile build can fetch hosted manifest
- [ ] When hosted version is newer, update dialog appears
- [ ] "Later" dismisses correctly for non-forced updates
- [ ] "Update" opens Play Store URL
- [ ] Forced update keeps dialog non-dismissible except store action

## GTG feature smoke checks
- [ ] First-run onboarding appears
- [ ] Focus move selection works
- [ ] Optional max reps input works
- [ ] Home GTG Coach card appears
- [ ] Settings > GTG Coach opens

## Notes for next release
- Keep `docs/version.json` aligned with the latest store rollout and `pubspec.yaml` build number
- Do not ship a new Play version without also updating the hosted manifest
- Internal testing should verify cold start and update prompt behavior before production rollout
