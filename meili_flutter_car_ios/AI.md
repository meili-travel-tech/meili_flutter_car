# meili_flutter_ios AI Notes

Purpose: iOS implementation of the Meili Flutter plugin.

Key code
- FlutterMethodChannel: `meili_flutter_ios` in `MeiliFlutterPlugin`.
- Platform view factory: `MeiliViewFactory` registering `flutter_meili/meili_view`.
- UIKit wrapper: `MeiliViewController` embeds SwiftUI `MeiliView` from MeiliSDK.
- Swift sources live in `ios/meili_flutter_ios/Sources/meili_flutter_ios/`
  (was `ios/Classes/`). Both build systems compile this one copy.

Build systems (both supported; additive, not a cutover)
- CocoaPods: `ios/meili_flutter_ios.podspec` (default path). `source_files`
  points at the shared `Sources/` dir; depends on MeiliSDK from the
  meili-ios-pods spec repo.
- SwiftPM: `ios/meili_flutter_ios/Package.swift` (used when the host app runs
  `flutter config --enable-swift-package-manager`). Depends on MeiliSDK via the
  `ux-native-ios` binary package. `Flutter` is injected by Flutter tooling and is
  NOT declared as a SwiftPM dependency.
- Both channels pin the SAME version and resolve the SAME
  `MeiliSDK.xcframework.zip` (the meili-ios-pods podspec sources the ux-native-ios
  release zip). Read the current version off the two files rather than from this
  doc, and keep the two pins in lockstep when bumping — the podspec pins exactly
  (`'1.11.1'`) while `Package.swift` uses `from:`, so they can silently diverge.
- iOS 15.0 floor (both channels).
