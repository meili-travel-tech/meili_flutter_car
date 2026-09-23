# meili_flutter_car – Claude Code Instructions

Purpose: Federated Flutter plugin wrapping the Meili native Car SDKs.

Packages
- meili_flutter_car: app-facing Dart API and widgets.
- meili_flutter_car_ios: iOS implementation (Swift, uses MeiliCarSDK + SwiftUI).
- meili_flutter_car_android: Android implementation (Kotlin, uses
  com.meili.travel:meili-car-sdk + Jetpack Compose).
- meili_flutter_car_platform_interface: shared platform interface used by
  meili_flutter_car.

Key channels and views
- MethodChannel: `meili_flutter_car`.
- EventChannel: `meili_flutter_car/events`.
- Presentation: `MeiliCar.open()` presents the SDK UI modally (no inline
  platform view).

iOS requirements
- `meili_flutter_car_ios.podspec` depends on `MeiliCarSDK` from the
  meili-ios-pods spec repo; SwiftPM path depends on `MeiliCarSDK` via the
  ux-native-ios binary package. Both channels pin the same version; read it from the podspec and Package.swift.
- iOS 15.0 floor (both channels).

Android requirements
- AGP 8.3+, Kotlin 2.1.0, Gradle 8.2+, JDK 17.
- `minSdk 24`, `compileSdk 35`.
- SDK dependency `com.meili.travel:meili-car-sdk` (version in android/build.gradle) from GitHub Pages
  (public Maven, no credentials required). Plugin Kotlin package is
  `com.meili.travel.flutter.car`.

Notes
- `MeiliCar.open()` presents the SDK UI modally; there is no inline widget.
- `MeiliCar.events` forwards lifecycle events (`MeiliCarFlowDismissed`,
  `MeiliCarBookingFlowEnded`) on both platforms. Forwarded analytics events
  (`MeiliCarAnalyticsEvent`) are iOS-only for now.

Package notes
@meili_flutter_car/AI.md
@meili_flutter_car_ios/AI.md
@meili_flutter_car_android/AI.md
@meili_flutter_car_platform_interface/AI.md

Skills
- Repo skills live in `.agents/skills/`, each linked from `.claude/skills/` so
  Claude Code loads it.

## Agent skills

### Issue tracker

Local markdown in `.scratch/<JIRA-KEY>/` (gitignored); Jira holds the tickets. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` at the repo root, created when the first term or decision is resolved. See `docs/agents/domain.md`.
