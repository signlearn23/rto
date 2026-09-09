# RTO Exam App (Flutter)

Learning License exam preparation app — Question Bank, Practice Mode, Exam Mode (timed, ad-gated retries),
Result History, State + matching regional language selection, dark mode, driving-school contribution form.

## Requirements
- Flutter 3.19+ (Dart 3+)
- Android Studio / SDK, minSdkVersion 21 (Android 5.0 Lollipop and above)

## Setup
```bash
flutter pub get
flutter run
```

## Build release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## Structure
See `lib/` — organized as core / data / presentation.
- `lib/core` — theme, constants, state+language map, exam credit manager, shared widgets
- `lib/data` — models, Hive local storage, repositories (question bank, results, driving schools)
- `lib/presentation` — screens, providers (ChangeNotifier via `provider`), routes

## Before publishing
1. Replace `applicationId` in `android/app/build.gradle` with your own package name.
2. Replace AdMob App ID in `android/app/src/main/AndroidManifest.xml` and ad unit IDs in
   `lib/core/constants/app_constants.dart` with your real AdMob IDs (currently Google's public TEST IDs).
3. Wire `in_app_purchase` product ID (`remove_ads_39`) in your Play Console for the ₹39 non-consumable.
4. Add full question banks per state/language under `assets/question_bank/` (sample TN files included).
5. Generate a real app icon and splash/vehicle animation (Lottie) and drop into `assets/`.
6. Set up a real backend (Firestore or your API) for `DrivingSchoolRepository` — it currently stores
   contributed schools only in local Hive as a placeholder.

## CI
`.github/workflows/build.yml` builds a debug APK on every push/PR and uploads it as an artifact.
