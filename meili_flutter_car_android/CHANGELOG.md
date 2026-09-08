# Changelog

## 0.4.10

- Passes the new `AvailParams.discountRequested` and `AvailParams.partnerLoyaltyAccountTier` through
  to the Android SDK. Requires `meili_flutter_platform_interface` `^0.4.1`.
- No Meili Android SDK bump; still `1.10.1`, which already accepts both fields.

## 0.4.9

- Pinned Meili Android SDK `1.10.1`. It fixes a Search button that silently did nothing, or crashed, when a
  host passed placeholder values (`""`, `0`) in `availParams`, and a crash on 12-hour devices when the
  pick-up date was today.
- Requires `meili_flutter_platform_interface` `^0.4.0`, in which every `AvailParams` field is optional.
- **Action required: your app must enable core library desugaring.** The Meili Android SDK's date
  and calendar logic uses `java.time`, native only from API 26, so every consuming app must add
  `isCoreLibraryDesugaringEnabled = true` and `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`.
  Without it the Android build fails with an explicit Gradle error naming the missing flag (MPD-11288).
- **`minSdk` lowered from 27 to 24.** A host app on API 24-26 can now integrate the funnel; if your
  app declares `minSdk 27` only because Meili required it, you can lower it (MPD-11288).
  **Android 7, 8 and 9 additionally need a TLS 1.3 security provider.** Meili's endpoints are TLS 1.3
  only and Android gained TLS 1.3 in API 29, so on API 24 to 28 the funnel opens blank unless the host
  registers one (for example Conscrypt) in `Application.onCreate`. See the installation guide. Verified
  on an Android 7.0 emulator: without a provider every request fails the handshake; with Conscrypt the
  funnel renders fully.
- Partner theme and partner config now load from the Meili content CDN instead of the static CDN,
  so partner theming resolves in uat and pre-production for the first time — previously those
  environments silently fell back to the default theme (MPD-11293).
- Funnel analytics report through the tagging endpoint, and requests move to the car-api gateway
  (MPD-10768).
- Single-tier loyalty programmes now render a checkbox rather than a tier picker on the search
  panel (MPD-11031).
- Request failures are logged from the view models, and the error-state guard is locked down
  (MPD-10739).
- No plugin API change.

## 0.4.8

- Bumped the Meili Android SDK to `1.9.0`, which adds support for a partner brand using a separate
  heading typeface alongside its body typeface, and honours the theme's heading font style for the
  first time (MPD-11080).
- No plugin API change. Which typefaces a funnel uses is partner configuration resolved inside the
  native SDK. If a brand font is not already on the device, the **host app** supplies the files by
  dropping them into `android/app/src/main/assets/meili/fonts/`, named so the weight is the last part
  of the filename (`YourBrand-Bold.ttf`). A font declared only under `fonts:` in `pubspec.yaml` is not
  visible to the native funnel. Use static faces rather than a variable font: a variable font carries
  no weight in its name, so it would be used at regular for every weight.

## 0.4.7

Stable release of the `0.4.7-beta.x` line.

- Updated Meili Android SDK dependency to 1.8.1.

## 0.4.7-beta.2

- Updated Meili Android SDK dependency to 1.8.1.

## 0.4.7-beta.1

- Updated Meili Android SDK dependency to 1.8.0.

## 0.4.6

- Removed the slide-up entrance transition added in `0.4.5-beta.1`. In practice it produced a black flash on some devices (the revealed/covered host activity surface isn't always redrawn in time around the transition) and interacted badly with back-press timing. `Meili.openMeiliView()` now opens with the plain system default transition; the flow itself is otherwise unaffected.

## 0.4.5-beta.2

- BREAKING: removed the Android platform view behind the retired `MeiliView` widget; `Meili.openMeiliView()` is the only Android entry point.
- Updated Meili Android SDK dependency to 1.7.2, which centralizes back handling: dismissing the flow via the system back button/gesture at the flow root now reliably invokes the dismiss callback, so `flowDismissed` is delivered for every back affordance (previously it was silently missed on system back — the root cause of the blank-host-page report in MPD-10997).

## 0.4.5-beta.1

- MPD-10997: present the Meili booking flow as a modal with a slide-up entrance, approximating iOS's page-sheet presentation. The host screen stays visible beneath the transition.
- Forward `bookingFlowEnded` through the `meili_flutter/events` channel (previously iOS-only).

## 0.4.3

- Updated Meili Android SDK dependency to 1.7.1. `1.7.0` was published from a commit that predated the material3 fix and did not actually contain it; `1.7.1` is the correct, verified fix — tested against host apps on Compose BOM 2026.01.01 (material3 1.4.0, compose-ui/foundation 1.10.2) with no `NoSuchMethodError`.

## 0.4.2

- Updated Meili Android SDK dependency to 1.7.0, fixing a `NoSuchMethodError` crash (`TopAppBarColors.copy`) on host apps resolving `androidx.compose.material3:material3` 1.4.0+. Built and tested against Compose BOM 2025.11.01 (material3 1.4.0, compose-ui 1.10.6).

## 0.4.0

- Stable release. Updated Meili Android SDK dependency to 1.6.9 (via public Maven repository).

## 0.3.0-beta.5

- Made the Android Gradle build compatible with Android Gradle Plugin 9 (new DSL) while keeping AGP 8 support, using property-assignment syntax (`compileSdk`, `minSdk`, `compose`, `namespace`) and the `packaging { jniLibs { pickFirsts } }` block.
- Bundled the Compose compiler plugin (`compose-compiler-gradle-plugin`) so host apps no longer need to declare `org.jetbrains.kotlin.plugin.compose` themselves.
- Stopped pinning the Android Gradle Plugin in the plugin buildscript; it is now inherited from the host app, which avoids AGP version conflicts on AGP 9 hosts.
- Resolve the Meili Android SDK from the public GitHub Pages Maven repository (`https://meili-travel-tech.github.io/ux-native-android/`); host apps no longer need GitHub Packages credentials (`MEILI_GITHUB_USERNAME` / `MEILI_GITHUB_TOKEN`).
- Updated the Meili Android SDK dependency to 1.6.8.

## 0.3.0-beta.3

- Updated Android SDK dependency to 1.6.1.
- Switched to public `com.meili.travel.api` imports for `AvailParams`, `AdditionalParams`, and `MeiliComposeListener`.
- Replaced direct `MeiliCompose` usage in `MeiliPlatformView` with `MeiliActivity.start()` to work with the published SDK.
- Fixed nullable `AvailParams` handling when calling `MeiliActivity.start()`.
- Removed `mavenLocal()` from Gradle repositories.

## 0.3.0-beta.2

- Updated license to proprietary.

## 0.3.0-beta.1

- Implemented `MeiliFlutterAndroid` with `registerWith()` for federated plugin registration.
- Unified method channel name to `meili_flutter`.
- Added `dartPluginClass` to pubspec for automatic platform registration.

## [0.1.0+1] - 2024-08-01

### Added

## [0.1.1] - 2024-08-02

### Added
