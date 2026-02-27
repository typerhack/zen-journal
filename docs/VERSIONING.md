# Zen Journal — Versioning & Release Numbering

## Policy

Zen Journal uses **Semantic Versioning** with git tags:

- `vMAJOR.MINOR.PATCH` (stable releases)
- Optional pre-releases: `vMAJOR.MINOR.PATCH-rc.N`

Examples:
- `v0.1.2`
- `v0.1.1`
- `v0.2.0-rc.1`

## Source of truth

1. `pubspec.yaml` controls app version metadata:
   - `version: MAJOR.MINOR.PATCH+BUILD`
2. Git tag controls release publishing:
   - `.github/workflows/release.yml` triggers on `v*.*.*`

For stable releases, keep `pubspec.yaml` and tag aligned:
- `pubspec.yaml`: `0.1.2+102`
- git tag: `v0.1.2`

## Files to update before a release

1. `/Users/daniel/Documents/Projects/zen-journal-app/pubspec.yaml`
   - bump `version:`
2. `/Users/daniel/Documents/Projects/zen-journal-app/README.md`
   - update release notes/feature references if needed
3. Tag in git:
   - `git tag vX.Y.Z`
   - `git push origin vX.Y.Z`

## Android update rules (critical)

For users to install updates over existing Android installs without uninstalling:

1. `applicationId` must stay the same
   - `com.zenjournal.zen_journal`
2. App must be signed with the **same release keystore**
3. `versionCode` must strictly increase

Release workflow enforces this with:
- `ZEN_ANDROID_VERSION_NAME` and `ZEN_ANDROID_VERSION_CODE`
- `ZEN_REQUIRE_RELEASE_SIGNING=true`

`ZEN_ANDROID_VERSION_CODE` is derived from the tag:
- formula: `major * 10000 + minor * 100 + patch`
- `v0.1.0` -> `100`
- `v0.1.5` -> `105`
- `v0.1.2` -> `102`
- `v0.2.0` -> `200`

## Android signing files and secrets

### Local development (optional)

- Copy `/Users/daniel/Documents/Projects/zen-journal-app/android/key.properties.example`
  to `/Users/daniel/Documents/Projects/zen-journal-app/android/key.properties`
- Set real values:
  - `storeFile`
  - `storePassword`
  - `keyAlias`
  - `keyPassword`

### GitHub Actions (required for release)

Configure repository secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Release workflow decodes the keystore and writes `android/key.properties` during the run.

## Release asset naming

All published release files include the app version in filename:

- `zen-journal-{version}-android.apk`
- `zen-journal-{version}-android.aab`
- `zen-journal-{version}-ios.zip`
- `zen-journal-{version}-macos-arm64.zip`
- `zen-journal-{version}-macos-intel.zip`
- `zen-journal-{version}-windows-x64.zip`
- `zen-journal-{version}-windows-arm64.zip`
- `zen-journal-{version}-linux-amd64.deb`
- `zen-journal-{version}-linux-x86_64.rpm`
- `zen-journal-{version}-linux-x86_64.AppImage`
- `zen-journal-{version}-linux-arm64.deb`
- `zen-journal-{version}-linux-aarch64.rpm`
- `zen-journal-{version}-linux-aarch64.AppImage`
