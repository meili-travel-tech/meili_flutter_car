# meili_flutter_android AI Notes

Purpose: Android implementation of the Meili Flutter plugin.

## Key code

- `MeiliFlutterPlugin.kt`: MethodChannel `meili_flutter_android`, implements
  `ActivityAware`. `openMeiliViewController` launches the SDK's
  `com.meili.travel.api.MeiliActivity` with Intent extras `PTID` and `ENV`.
  Also registers the `flutter_meili/meili_view` PlatformView factory.
- `MeiliConnectViewFactory.kt`: `PlatformViewFactory` returning a placeholder
  `TextView`. The embedded Connect flow is not available until the SDK ships
  a properly-exposed API (see below).

## Dependencies

- `meili.travel:ux-native-android-sdk` from GitHub Packages. Version comes
  from the Gradle property `meiliSdkVersion` (default `1.1.0`).

No Compose/Activity-Compose dependencies are needed — the plugin only sends
an Intent to `MeiliActivity`.

## Build requirements

- AGP 8.3.2, Kotlin 2.0.21.
- `minSdk 24`, `compileSdk 34`, JVM target 17.
- Consumer apps must declare the GitHub Packages repo in their
  `settings.gradle` `dependencyResolutionManagement` block and supply
  `gpr.user` / `gpr.key` (or `USERNAME` / `TOKEN` env vars).

## Published SDK v1.1.0 limitations

The released `ux-native-android-sdk-1.1.0.aar` on GitHub Packages is
minified/obfuscated. Only the following symbols are reachable from consumer
Kotlin code:

- `com.meili.travel.api.MeiliActivity` — `ComponentActivity` that reads two
  Intent string extras: `PTID` and `ENV`.
- `com.meili.travel.api.MeiliEnvironment` and the four concrete environments
  (`Development`, `PreProduction`, `Uat`, `Production`).

The following are stripped or obfuscated and therefore unusable by this
plugin today:

- `MeiliFlow` / `AppFlow` — gone. Can't select Direct vs BookingManager vs
  Connect from Kotlin; the activity defaults are used.
- `MeiliComposeListener` — gone. No callbacks can be wired up for
  `newCarSelected`, `carRemoved`, `onEndBookingFlow`, etc.
- `ConnectScreen` — gone, so the embedded Connect widget can't be rendered.
- `MeiliCompose`'s `flow` parameter is the obfuscated type
  `com.meili.travel.internal.g`, which consumer code can't construct.
- `MeiliActivity.start(...)` — not present. Launch via raw Intent only.

What this means for the plugin today:

- `Meili.openMeiliView(MeiliParams)` only honours `ptid` and `env` on Android;
  `flow`, `availParams`, and `additionalParams` are logged and ignored.
- `MeiliConnectWidget` renders a placeholder banner on Android.

Notes
- No Meili SDK integration yet; openMeiliView is unsupported on Android.
- Android Gradle config uses older AGP/Kotlin versions; update with care.
