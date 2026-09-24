# Changelog

## Unreleased

- **New:** `MeiliCarErrorEvent`, a `MeiliCarEvent` variant forwarding SDK-internal failures
  (config, availability, costs, checkout, reservation, partner-content requests) from a new
  native `onError` callback. Carries `area` (`MeiliCarErrorArea`), `kind` (`MeiliCarErrorKind`),
  an optional `httpCode`, and a release-safe `message` (MPD-10790).

  ```dart
  MeiliCar.events.listen((event) {
    switch (event) {
      case MeiliCarErrorEvent(:final area, :final kind, :final message):
        log('MeiliCar error: $area/$kind — $message');
      // ...
    }
  });
  ```

  Depends on unreleased native SDKs (`MeiliCarSDK` and `com.meili.travel:meili-car-sdk`), so no
  events are emitted yet on either platform.

## 0.8.0

- **BREAKING: `meili_flutter` is renamed to `meili_flutter_car`**, part of Meili's product-scoped
  SDK naming (MPD-11470) — a future hotel product gets its own `meili_flutter_hotel` plugin instead
  of sharing this one. `meili_flutter` 0.7.x stays published and frozen, so an existing pin keeps
  resolving until you move. The move is three edits:
  1. Dependency name: `meili_flutter: ^0.7.0` → `meili_flutter_car: ^0.8.0`.
  2. Import path: `package:meili_flutter/meili_flutter.dart` → `package:meili_flutter_car/meili_flutter_car.dart`.
  3. Call sites: `Meili.` → `MeiliCar.`, and `Meili.openMeiliView(MeiliParams(...))` → `MeiliCar.open(MeiliCarParams(...))`.
- Renamed types: `Meili` → `MeiliCar`, `MeiliParams` → `MeiliCarParams`, `MeiliEvent` →
  `MeiliCarEvent`, `MeiliFlowDismissed` → `MeiliCarFlowDismissed`, `MeiliBookingFlowEnded` →
  `MeiliCarBookingFlowEnded`, `MeiliAnalyticsEvent` → `MeiliCarAnalyticsEvent`, `MeiliUnknownEvent`
  → `MeiliCarUnknownEvent`. `AvailParams`, `AdditionalParams`, `BookingParams` and `FlowType` are
  unchanged.
- `meili_flutter_ios`, `meili_flutter_android` and `meili_flutter_platform_interface` are renamed
  to `meili_flutter_car_ios` (`^0.5.0`), `meili_flutter_car_android` (`^0.5.0`) and
  `meili_flutter_car_platform_interface` (`^0.5.0`) respectively.
- Native pins: iOS `MeiliCarSDK` `1.12.0` (was `MeiliSDK` `1.11.1`); Android
  `com.meili.travel:meili-car-sdk` `1.11.0` (was `meili.travel:ux-native-android-sdk` `1.10.1`).
- Method and event channel names change internally (`meili_flutter` → `meili_flutter_car`,
  `meili_flutter/events` → `meili_flutter_car/events`); these are plugin-internal and require no
  host action.
- No behavioural change.

## 0.7.0

- Bumped `meili_flutter_ios` to `^0.4.8` (MeiliSDK `1.11.1`), `meili_flutter_android` to `^0.4.10`
  and `meili_flutter_platform_interface` to `^0.4.1`.
- Fixes partner loyalty details being dropped when a search is re-run from the results screen on
  iOS, which returned prices without the partner discount applied (MPD-11030).
- **New:** `AvailParams` gains `discountRequested` and `partnerLoyaltyAccountTier`, which pre-tick
  the partner discount and loyalty card checkboxes on the search panel. Both native SDKs have
  accepted these since MeiliSDK `1.11.0` / Meili Android SDK `1.10.0`, but Flutter hosts had no way
  to pass them. Both fields are optional, so existing code is unaffected.

  ```dart
  AvailParams(
    pickupLocation: 'NTE',
    discountRequested: true,
    partnerLoyaltyAccountTier: 'CARD',
  )
  ```

  This is a minor rather than a patch release because it adds public API.

## 0.6.0

- Bumped `meili_flutter_ios` to `^0.4.7` (MeiliSDK `1.11.0`) and `meili_flutter_android` to `^0.4.9`
  (Meili Android SDK `1.10.1`).
- **Action required on Android: enable core library desugaring.** The Meili Android SDK now uses
  `java.time`, which is native only from API 26, so every host app must add this to
  `android/app/build.gradle.kts`:

  ```kotlin
  android {
      compileOptions {
          isCoreLibraryDesugaringEnabled = true
      }
  }

  dependencies {
      coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
  }
  ```

  Without it the Android build fails with `Dependency 'meili.travel:ux-native-android-sdk' requires
  core library desugaring to be enabled`. See the
  [installation guide](https://docs.meili.travel/native/flutter/installation) (MPD-11288).
- **Android `minSdk` is now 24, down from 27.** If your app sets `minSdk = 27` only to satisfy Meili,
  you can lower it to 24 — see the [installation guide](https://docs.meili.travel/native/flutter/installation).
  iOS is unchanged at a 15.0 integration floor with the native funnel on 16.0+.
  **Android 7, 8 and 9 additionally need a TLS 1.3 security provider.** Meili's endpoints are TLS 1.3
  only and Android gained TLS 1.3 in API 29, so on API 24 to 28 the funnel opens blank unless the host
  registers one (for example Conscrypt) in `Application.onCreate`. See the installation guide. Verified
  on an Android 7.0 emulator: without a provider every request fails the handshake; with Conscrypt the
  funnel renders fully.
- Partner theming and partner configuration now resolve correctly in **uat and pre-production**. Both
  SDKs previously fetched them from a host that only answered in dev and production, so those two
  environments silently fell back to the default theme and configuration (MPD-11293).
- On iOS, the terms and conditions and privacy policy shown in the funnel now come from the
  environment the build targets. They were previously served from the development CDN in every
  build, production included (MPD-11293).
- Funnel analytics now report through the tagging endpoint on both platforms, and requests move to
  the car-api gateway (MPD-11045 on iOS, MPD-10768 on Android).
- Single-tier loyalty programmes render a checkbox instead of a tier picker (MPD-11030 / MPD-11031).
- **iOS: `availParams` now reach the native SDK.** They were silently dropped unless `pickupDateTime`
  and `dropoffDateTime` were also set, so currency overrides and deeplinks had no effect on iOS. The
  `""` / `0` placeholders for unused fields are now treated as unset on both platforms. Also fixed an
  iOS crash when `additionalParams` omitted `lastName` or `confirmationId`.
- **`AvailParams` fields are all optional now** (`meili_flutter_platform_interface` 0.4.0). Pass only what
  you want to prefill, for example `AvailParams(currencyCode: 'EUR')`. Code that passes every field is
  unchanged. If you were passing `''` or `0` as placeholders, remove them.

## 0.5.0

- Bumped `meili_flutter_ios` to `^0.4.6` (MeiliSDK `1.10.0`) and `meili_flutter_android` to `^0.4.8`
  (Meili Android SDK `1.9.0`). Together these let a partner brand use a separate heading typeface
  alongside its body typeface, with prices and numeric text staying on the body typeface (MPD-11080).
- No Dart API change, and nothing to configure in code. If a brand font is not already on the device,
  the host app supplies the files in its **platform projects** — `UIAppFonts` in `ios/Runner`, and
  `android/app/src/main/assets/meili/fonts/` on Android. A font declared only under `fonts:` in
  `pubspec.yaml` registers with the Flutter engine and is **not** visible to the native funnel. See the
  [installation guide](https://docs.meili.travel/native/flutter/installation#4-custom-fonts-only-if-you-need-one).

## 0.4.8

Stable release of the `0.4.8-beta.x` line.

- **iOS 15 is now supported.** `meili_flutter_ios` lowers its deployment target to 15.0 (MPD-11195). A host app must also lower its own `IPHONEOS_DEPLOYMENT_TARGET` to 15.0 to inherit this. On iOS 15 the native funnel cannot render, so `Meili.openMeiliView()` presents the web funnel automatically — no host code required, and `Meili.events` still delivers analytics and `MeiliFlowDismissed` as usual. Android and iOS 16+ are unaffected.
- Bumped `meili_flutter_ios` to `^0.4.5` (MeiliSDK 1.9.3) and `meili_flutter_android` to `^0.4.7` (Meili Android SDK 1.8.1).
- The iOS funnel now takes its display language from the device instead of the host app's declared localisations, so a stock Flutter project no longer forces English (MPD-11229).

## 0.4.8-beta.4

- Removed `Meili.nativeFunnelAvailable()`, added in `0.4.8-beta.3`. It shipped against a `meili_flutter_platform_interface` change that was never published, so `0.4.8-beta.3` fails to compile for every consumer. The API was informational only — `openMeiliView()` already falls back to the web funnel on iOS 15 on its own, so nothing about the fallback changes. Hosts that want to vary their own UI on iOS 15 can check the OS version directly.
- Bumped `meili_flutter_ios` dependency to `^0.4.5-beta.4`.

## 0.4.8-beta.3

- Bumped `meili_flutter_ios` dependency to `^0.4.5-beta.3` (MeiliSDK 1.9.3). The iOS funnel now takes its display language from the device instead of the host app's declared localisations, so a stock Flutter project no longer forces English (MPD-11229).

## 0.4.8-beta.2

- Bumped `meili_flutter_android` dependency to `^0.4.7-beta.2` (Meili Android SDK 1.8.1) and `meili_flutter_ios` dependency to `^0.4.5-beta.2` (MeiliSDK 1.9.2).

## 0.4.8-beta.1

- Bumped `meili_flutter_android` dependency to `^0.4.7-beta.1` (Meili Android SDK 1.8.0) and `meili_flutter_ios` dependency to `^0.4.5-beta.1` (MeiliSDK 1.8.0).

## 0.4.7

- BREAKING: the `MeiliView` embedded-widget class is removed from the public API entirely (bumped `meili_flutter_ios` dependency to `^0.4.4`). `Meili.openMeiliView()` is now the only way to present the booking flow on both platforms. Android already threw `UnsupportedError` for `MeiliView` since `0.4.5-beta.2`; iOS's previously-working inline embedding is retired for API symmetry and to keep a single, documented integration path (MPD-10997).
- README updated: the "Embedded widget" section is removed; "Full-screen modal" is now the only usage section.

## 0.4.6

- Bumped `meili_flutter_android` dependency to `^0.4.6`, which removes the slide-up entrance transition on Android (it caused a black flash on some devices). `Meili.openMeiliView()` now opens with the plain system default transition.

## 0.4.5-beta.2

- BREAKING (Android): the `MeiliView` widget now throws `UnsupportedError` on Android with migration guidance. It never rendered inline there — it launched the full-screen flow as a side effect and left a blank host page on return. Use `Meili.openMeiliView()` from your UI action instead. iOS behaviour unchanged.
- MPD-10997: via `meili_flutter_android` `0.4.5-beta.2` (Meili Android SDK 1.7.2), dismissing the flow from every back affordance (app-bar chevron, back button, back gesture) now reliably emits `MeiliFlowDismissed` on `Meili.events`. Previously the system back button at the flow root dismissed silently.

## 0.4.5-beta.1

- MPD-10997: `Meili.openMeiliView()` on Android presents the booking flow as a slide-up modal over the current screen.
- `bookingFlowEnded` is now delivered on `Meili.events` on Android as well as iOS.

## 0.4.4

- Bumped `meili_flutter_ios` dependency to `^0.4.3` (MeiliSDK 1.7.2).

## 0.4.3

- Bumped `meili_flutter_android` dependency to `^0.4.3`. `0.4.2` referenced Android SDK `1.7.0`, which was published from a stale commit and did not actually contain the material3 fix; `0.4.3` pulls in the verified `1.7.1`.

## 0.4.2

- Bumped `meili_flutter_android` dependency to `^0.4.2`, fixing a `NoSuchMethodError` crash on host apps resolving `androidx.compose.material3:material3` 1.4.0+.

- Bumped `meili_flutter_ios` dependency to `^0.4.2` (MeiliSDK 1.7.1).


## 0.4.1

- Bumped `meili_flutter_ios` dependency to `^0.4.0`.

## 0.4.0

- Stable release. Bumped `meili_flutter_android` dependency to `^0.4.0` and `meili_flutter_ios` dependency to `^0.4.0`.

## 0.3.1-beta.5

- Bumped `meili_flutter_android` dependency to `^0.3.0-beta.5` (Android Gradle Plugin 9 compatibility and a bundled Compose compiler plugin).

## 0.3.1-beta.4

- Bumped `meili_flutter_android` dependency to `^0.3.0-beta.3`.

## 0.3.1-beta.3

- Migrated to federated plugin architecture using `meili_flutter_platform_interface`.
- `Meili.openMeiliView()` now delegates to the platform interface instance.
- Exported `MeiliParams`, `AvailParams`, `BookingParams`, `FlowType` from the platform interface.

## [0.1.0+1] - 2024-08-01

### Added

## [0.1.1] - 2024-08-02

### Added

## [0.1.2] - 2024-08-02

### Added

## [0.2.0] - 2024-10-30

### Added

## [0.3.0] - 2024-10-30

### Added
