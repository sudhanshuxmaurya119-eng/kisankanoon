# Agri-Shield

Agri-Shield is a farmer support application built with Flutter. It brings important farmer-facing services into one mobile app, including weather updates, document scanning and storage, government scheme access, official website links, helpline numbers, language support, and Firebase-backed authentication.

This repository contains the complete final project workspace:

- `kisankanoon/` - Flutter mobile and web app
- `server/` - optional Node.js + MongoDB backend APIs
- `.github/workflows/` - GitHub Actions for Shorebird OTA patching and Android release builds
- `docs/` - supporting project documentation

## Project Highlights

- Farmer-friendly mobile UI with Hindi-first support and multiple language options
- Light mode and dark mode support
- Weather by device location
- Scanned and uploaded document management
- Government website directory for farmers and land records
- Organized helpline section with actionable call entries
- Firebase authentication and Firestore integration
- Shorebird setup for Android OTA Dart-only updates
- Vercel-ready Flutter web deployment support

## Tech Stack

- Flutter
- Firebase Auth
- Cloud Firestore
- Shared Preferences
- Shorebird
- GitHub Actions
- Node.js
- Express
- MongoDB
- Cloudinary

## Repository Structure

```text
Farmer Idea/
|-- .github/
|   `-- workflows/
|-- docs/
|   `-- shorebird-ota.md
|-- kisankanoon/
|   |-- lib/
|   |-- android/
|   |-- ios/
|   |-- web/
|   `-- pubspec.yaml
|-- server/
|   |-- models/
|   |-- routes/
|   |-- index.js
|   `-- package.json
|-- .firebaserc
|-- firebase.json
`-- README.md
```

## Getting Started

### Prerequisites

- Flutter `3.41.x` recommended
- Dart SDK compatible with the Flutter version above
- Java `17`
- Node.js `18+`
- Firebase project configured for the Flutter app

### Run the Flutter App

```bash
cd kisankanoon
flutter pub get
flutter run
```

### Run the Flutter Web Build

```bash
cd kisankanoon
flutter build web
```

### Run the Backend API

```bash
cd server
npm install
cp .env.example .env
npm run dev
```

## Environment Setup

### Flutter / Firebase

The Flutter app expects Firebase to be configured for the target platform. Important project files include:

- `kisankanoon/lib/firebase_options.dart`
- `firebase.json`
- `.firebaserc`

### Backend

The backend uses environment variables for MongoDB, JWT, and Cloudinary. A starter template is included in:

- `server/.env.example`

## CI/CD

This repository includes GitHub workflows for Android delivery:

- `build_apk.yml` - Shorebird Android base release workflow
- `shorebird_patch.yml` - Shorebird Android OTA patch workflow for Dart-only changes

Important note:

- Native code changes, dependency changes, and asset changes require a new base release.
- Dart-only changes inside `kisankanoon/lib/` can go through Shorebird OTA patching.

More detail is documented in:

- `docs/shorebird-ota.md`

## Quality Checks

Recommended commands before pushing changes:

```bash
cd kisankanoon
flutter analyze
flutter test
```

## Final Submission Notes

This repository is organized as a complete final-round project submission with:

- application source code
- backend API source code
- Firebase project configuration files
- GitHub Actions workflows
- OTA update documentation
- repository-level onboarding documentation

## Author

Sudhanshu Maurya
