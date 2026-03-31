# Shorebird OTA Workflow

This project now uses Shorebird for Android over-the-air Dart updates.

## First install

Users must install a Shorebird base release APK once. That APK is created by the `Shorebird Android Release` workflow.

## After that

Dart-only changes under `kisankanoon/lib/` are published through the `Shorebird Android Patch` workflow and do not require a new APK install.

## Still needs a new base release

These changes are not patchable and should use the release workflow instead:

- `android/` or `ios/` native code
- `pubspec.yaml` or dependency changes
- assets such as images, fonts, and icons
- Flutter version changes

## GitHub secrets

Required:

- `SHOREBIRD_TOKEN`
- `GOOGLE_SERVICES_JSON`

Recommended for stable Android signing:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

If the Android signing secrets are missing, the workflows fall back to a temporary CI keystore. That is enough to create a working build, but it is not ideal for long-term APK upgrade continuity.
