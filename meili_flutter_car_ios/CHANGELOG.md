# Changelog

## 0.4.8

- Pinned MeiliSDK `1.11.1` in both the podspec and `Package.swift`.
- Fixes the loyalty tier, the discount flag and the ticket number being dropped when a search is
  re-run from the results screen. Ticking "I have an eligible SNCF card", searching, then editing
  the search and searching again sent no `partnerParams` at all, so results came back without the
  partner discount applied. The same loss affected the currency switcher, the failure retry and
  the map depot picker (MPD-11030).
- An empty ticket number is now omitted from `partnerParams` rather than sent as `""`, matching the
  web app and the Android SDK (MPD-11030).
- Passes the new `AvailParams.discountRequested` and `AvailParams.partnerLoyaltyAccountTier` through
  to the iOS SDK. Requires `meili_flutter_platform_interface` `^0.4.1`.

## 0.4.7

- Pinned MeiliSDK `1.11.0` in both the podspec and `Package.swift`.
- Requires `meili_flutter_platform_interface` `^0.4.0`, in which every `AvailParams` field is optional.
- **`availParams` now reach the native SDK.** The plugin previously required every field, including
  `pickupDateTime` and `dropoffDateTime`, which the Dart model leaves optional, so any `availParams`
  without them were silently dropped and the funnel opened as if none had been passed. Each field is
  now passed through individually, and the `""` / `0` placeholders the Dart model forces for unused
  fields are treated as unset.
- Fixed a crash when `additionalParams` omitted `lastName` or `confirmationId`; both are optional in
  Dart but were force-unwrapped on iOS.
- Partner theme and partner config now load from the Meili content CDN instead of the static CDN,
  so partner theming resolves in uat and pre-production for the first time — previously those
  environments silently fell back to the default theme (MPD-11293).
- The terms and conditions and privacy policy links now follow the configured environment. They
  were previously pinned to the development CDN in every build, production included (MPD-11293).
- Funnel analytics report through the tagging endpoint, and requests move to the car-api gateway
  (MPD-11045).
- Single-tier loyalty programmes now render a checkbox rather than a tier picker, and a deeplinked
  discount code or tier is carried into the funnel (MPD-11030).
- No plugin API change.

## 0.4.6

- Pinned MeiliSDK `1.10.0` in both the podspec and `Package.swift`, which adds support for a partner
  brand using a separate heading typeface alongside its body typeface (MPD-11080).
- No plugin API change. Which typefaces a funnel uses is partner configuration resolved inside the
  native SDK. If a brand font is not already on the device, the **host app** registers the files as
  it would for its own screens — add them to the Runner target and list them in `UIAppFonts`. A font
  declared only under `fonts:` in `pubspec.yaml` is not visible to the native funnel.

## 0.4.5

Stable release of the `0.4.5-beta.x` line.

- Lowered the deployment target from iOS 16.0 to **iOS 15.0** in both the podspec and `Package.swift` (MPD-11195). A host app only inherits this after lowering its own `IPHONEOS_DEPLOYMENT_TARGET`; the plugin permitting 15.0 is not sufficient on its own.
- On iOS 15 the native funnel cannot render, so `openMeiliView()` presents the web funnel instead. This is automatic and needs no host code. The hosting controller is presented full-screen and unanimated in that case, so the traveller sees one transition rather than an empty card followed by Safari.
- Bumped `MeiliSDK` to `1.9.3` (podspec and SwiftPM). Resolves the display language from the device rather than the host app's declared localisations, so a stock Flutter project no longer forces English, and splits date parsing from locale-aware display (MPD-11229).

## 0.4.5-beta.4

- Removed the `nativeFunnelAvailable` method-channel handler, added in `0.4.5-beta.3`, alongside the Dart API it served. The internal `MeiliSupport.isNativeFunnelAvailable` branch that selects full-screen unanimated presentation on iOS 15 is unchanged.

## 0.4.5-beta.3

- Bumped `MeiliSDK` to `1.9.3` (CocoaPods podspec and SwiftPM `Package.swift`). Resolves the display language from the device rather than the host app's declared localisations, and splits date parsing from locale-aware display (MPD-11229).

## 0.4.5-beta.2

- Bumped `MeiliSDK` to `1.9.2` (CocoaPods podspec and SwiftPM `Package.swift`).

## 0.4.5-beta.1

- Bumped `MeiliSDK` to `1.8.0` (CocoaPods podspec and SwiftPM `Package.swift`).

## 0.4.4

- BREAKING: removed the `MeiliView` embedded-widget platform view (`MeiliViewFactory`, `MeiliUIView`, `MeiliPlatformView`) and its `flutter_meili/meili_view` registration. `Meili.openMeiliView()` is now the only entry point on both platforms, matching Android since `meili_flutter_android 0.4.5-beta.2`.

## 0.4.3

- Bumped `MeiliSDK` to `1.7.2` (CocoaPods podspec and SwiftPM `Package.swift`).

## 0.4.2

- Bumped `MeiliSDK` to `1.7.1` (CocoaPods podspec and SwiftPM `Package.swift`).

## 0.4.1

- Point the SwiftPM `Package.swift` at the stable `ux-native-ios` 1.7.0 (was the 1.6.3 alpha), aligning the SwiftPM channel with the CocoaPods podspec.

## 0.4.0

- Stable release. Bumped `MeiliSDK` to `1.7.0`.

## 0.3.1-beta.4

- Bumped `MeiliSDK` to `1.6.3-alpha.10` on both channels (SwiftPM `ux-native-ios` pin and CocoaPods podspec).

## 0.3.1-beta.3

- Updated `meili_flutter_platform_interface` constraint to `^0.3.0`.

## 0.3.1-beta.2

- Updated license to proprietary.

## 0.3.1-beta.1

- Implemented `MeiliFlutterIos` with `registerWith()` for federated plugin registration.
- Unified method channel name to `meili_flutter`.
- Added `dartPluginClass` to pubspec for automatic platform registration.

## [0.1.0+1] - 2024-08-01

### Added

## [0.1.1] - 2024-08-01

### Added

## [0.1.2] - 2024-08-01

### Added
