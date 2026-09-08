# meili_flutter_car_ios AI Notes

Purpose: iOS implementation of the Meili Flutter Car plugin.

Key code
- FlutterMethodChannel: `meili_flutter_car` in `MeiliFlutterPlugin`. FlutterEventChannel:
  `meili_flutter_car/events` in `MeiliEventDispatcher`.
- UIKit wrapper: `MeiliViewController` embeds SwiftUI `MeiliCarView` from `MeiliCarSDK`, via the
  plugin-internal `MeiliWrapperView`.
- `MeiliFlutterAnalyticsProvider` registers with `MeiliCarAnalytics.shared.addProvider(_:)` and
  forwards every SDK analytics event to Dart through `MeiliEventDispatcher`.
- Swift sources live in `ios/meili_flutter_car_ios/Sources/meili_flutter_car_ios/`. Both build
  systems compile this one copy. Plugin-internal type names (`MeiliFlutterPlugin`,
  `MeiliViewController`, `MeiliEventChannel`/`MeiliEventDispatcher`, `MeiliFlutterAnalyticsProvider`,
  `MeiliParamsParser`, `MeiliWrapperView`) are unchanged; only the SDK module and its public types
  moved.

Build systems (both supported; additive, not a cutover)
- CocoaPods: `ios/meili_flutter_car_ios.podspec` (default path). `source_files`
  points at the shared `Sources/` dir; depends on `MeiliCarSDK` from the
  meili-ios-pods spec repo.
- SwiftPM: `ios/meili_flutter_car_ios/Package.swift` (used when the host app runs
  `flutter config --enable-swift-package-manager`). Depends on `MeiliCarSDK` via the
  `ux-native-ios` binary package. `Flutter` is injected by Flutter tooling and is
  NOT declared as a SwiftPM dependency.
- Both channels pin the SAME version and resolve the SAME
  `MeiliCarSDK.xcframework.zip` (the meili-ios-pods podspec sources the ux-native-ios
  release zip). Read the current version off the two files rather than from this
  doc, and keep the two pins in lockstep when bumping — the podspec pins exactly
  (`'1.12.0'`) while `Package.swift` uses `from:`, so they can silently diverge.
- iOS 15.0 floor (both channels).
