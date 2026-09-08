# MeiliCar Flutter Plugin

[![pub package](https://img.shields.io/pub/v/meili_flutter_car.svg)](https://pub.dev/packages/meili_flutter_car)

The MeiliCar Flutter Plugin allows you to integrate the MeiliCar car rental experience into your Flutter applications on both iOS and Android.

## Overview

`meili_flutter_car` is a federated Flutter plugin that wraps the native Meili UX SDKs:

- **Android** native SDK: hosted as a Maven artifact on GitHub Packages at `meili-travel-tech/ux-native-android-sdk` (requires auth).
- **iOS** native SDK: distributed as a CocoaPod (`MeiliCarSDK`) via a private spec repo at `meili-travel-tech/meili-ios-pods` (requires SSH/HTTPS access).

---

## Prerequisites

| Requirement | Why |
|---|---|
| Flutter SDK `>=3.4.0` | Minimum required by the plugin. |
| Android Studio / Xcode CLI tools | Needed for native builds. |
| CocoaPods (`gem install cocoapods`) | iOS dependency manager. |
| GitHub Personal Access Token with `read:packages` scope | Downloads the Android AAR from GitHub Packages. |
| Membership in the `meili-travel-tech` GitHub org | Both the iOS spec repo and Android Maven artifacts are under this org. Contact Meili to get access. |

---

## 1. Dart / pubspec setup

```yaml
dependencies:
  meili_flutter_car: ^0.8.0
```

```bash
flutter pub get
```

This resolves the federated sub-packages automatically — you do not need to add `meili_flutter_car_android` or `meili_flutter_car_ios` manually.

---

## 2. Android setup

### 2.1 Declare the Maven repository

The Android SDK is served from a public Maven repository over GitHub Pages, so **no credentials are required**. Add it to your project-level `android/build.gradle.kts`:

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://meili-travel-tech.github.io/ux-native-android/") }
    }
}
```

### 2.2 `android/app/build.gradle.kts` — NDK, minSdk + desugaring

```kotlin
android {
    ndkVersion = "27.0.12077973"
    defaultConfig {
        minSdk = 24
    }
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

- `ndkVersion` must be pinned exactly — using `flutter.ndkVersion` may cause a linker error.
- `minSdk = 24` is the floor required by the Meili Android SDK.
- **Core library desugaring is required.** The Meili Android SDK's date and calendar logic uses
  `java.time`, which is only native from API 26, so every consuming app must enable it. Without it
  the build fails with `Dependency 'com.meili.travel:meili-car-sdk' requires core library
  desugaring to be enabled`.

#### Android 7 to 9 (API 24 to 28): supply a TLS 1.3 provider

MeiliCar's endpoints accept TLS 1.3 only, and Android only added TLS 1.3 in Android 10 (API 29). On
Android 7, 8 and 9 the SDK cannot connect and the funnel opens on a blank screen, with
`SSLHandshakeException: Handshake failed` in logcat. If your `minSdk` is 29 or higher, skip this.

Add Conscrypt and register it as the first security provider in an `Application` subclass:

```kotlin
dependencies {
    implementation("org.conscrypt:conscrypt-android:2.5.3")
}
```

```kotlin
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Security.insertProviderAt(Conscrypt.newProvider(), 1)
    }
}
```

and point `<application android:name=".MainApplication">` at it in `AndroidManifest.xml`. The
example app does exactly this. Conscrypt adds about 2 MB on arm64 and works without Google Play
services; Play services' `ProviderInstaller` is an alternative for devices that have them.

### 2.3 `android/settings.gradle.kts` — Kotlin Compose plugin

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.1.0" apply false  // add this
}
```

### 2.4 `MainActivity.kt`

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

> If you leave `FlutterActivity` here you will get an `IllegalStateException` at runtime when opening the MeiliCar view.

---

## 3. iOS setup

### 3.1 `ios/Podfile`

```ruby
platform :ios, '16.0'

source 'https://cdn.cocoapods.org/'
source 'git@github.com:meili-travel-tech/meili-ios-pods.git'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# ... rest of the standard Flutter Podfile unchanged
```

> If you use a multi-account SSH setup, replace `git@github.com:` with your Host alias e.g. `git@github.com-meili:`.

### 3.2 iOS deployment target

Set `IPHONEOS_DEPLOYMENT_TARGET = 16.0` in three places in `ios/Runner.xcodeproj/project.pbxproj` (Debug, Release, Profile), or via Xcode under **Runner target → General → Minimum Deployments → iOS**.

### 3.3 `ios/Flutter/AppFrameworkInfo.plist`

```xml
<key>MinimumOSVersion</key>
<string>16.0</string>
```

### 3.4 Install pods

```bash
cd ios && pod install --repo-update && cd ..
```

`--repo-update` is needed the first time to clone the private spec repo. Plain `pod install` is sufficient on subsequent runs.

---

## 4. Usage

### Full-screen modal (iOS and Android)

This is the only supported way to present the booking flow. It opens as a
modal over the current screen and works identically on both platforms.

```dart
import 'package:meili_flutter_car/meili_flutter_car.dart';

await MeiliCar.open(MeiliCarParams(
  ptid: 'your-ptid',
  env: 'prod',
  flow: FlowType.direct,
));
```

### Booking Manager

```dart
await MeiliCar.open(MeiliCarParams(
  ptid: 'your-ptid',
  env: 'prod',
  flow: FlowType.bookingManager,
  additionalParams: AdditionalParams(
    confirmationId: '1234ABCD',
    lastName: 'Doe',
  ),
));
```

---

## 5. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Could not find ... .aar` during Gradle | Maven repo URL missing, or the version isn't published yet | Check the `build.gradle.kts` repo block points to the public Pages URL and that the version exists. |
| `Unable to find a specification for MeiliCarSDK` | Missing `source` line in Podfile | Add the private spec repo URL. |
| `pod install` hangs on first run | First-time SSH clone of spec repo | Confirm SSH key: `ssh -T git@github.com`. |
| `IllegalStateException ... requires FragmentActivity` | `MainActivity` still extends `FlutterActivity` | Change to `FlutterFragmentActivity`. |
| NDK strip / linker errors | NDK version mismatch | Pin `ndkVersion = "27.0.12077973"`. |
| Env vars set in terminal but not in Android Studio | macOS GUI apps don't load `~/.zshrc` | Move env vars to `~/.zshenv`, relaunch Android Studio. |

---

## Migrating from `meili_flutter`

`meili_flutter` is renamed to `meili_flutter_car`. `meili_flutter` 0.7.x stays
published and frozen, so an existing pin keeps resolving until you move. The
move is three edits: the dependency name (`meili_flutter` → `meili_flutter_car`),
the import path (`package:meili_flutter/meili_flutter.dart` →
`package:meili_flutter_car/meili_flutter_car.dart`), and the call sites
(`Meili.openMeiliView(MeiliParams(...))` → `MeiliCar.open(MeiliCarParams(...))`).
See `CHANGELOG.md` for the full symbol rename table.

## Platform Support

| Platform | Supported |
|---|---|
| Android | ✅ |
| iOS | ✅ |

## Contributing

Open issues or pull requests at [github.com/meili-travel-tech/flutter_meili](https://github.com/meili-travel-tech/flutter_meili).
