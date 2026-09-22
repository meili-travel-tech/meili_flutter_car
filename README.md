# Meili Flutter Car Plugin

[![pub package](https://img.shields.io/pub/v/meili_flutter_car.svg)](https://pub.dev/packages/meili_flutter_car)

The Meili Flutter Car Plugin allows you to integrate the Meili car rental booking experience into your Flutter applications on both iOS and Android.

## Features

- **Cross-platform**: Full support for iOS and Android
- **Two booking flows**: Direct (search & book) and Booking Manager (manage existing bookings)
- **Dismiss callback**: Listen for when the user closes the MeiliCar flow
- **Prefill support**: Pass availability and booking parameters to pre-populate the search

## Requirements

| Platform | Minimum version |
|----------|----------------|
| iOS      | 16.0           |
| Android  | API 24         |

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  meili_flutter_car: ^0.8.0
```

Run:
```bash
flutter pub get
```

### Android setup

The Android SDK is served from a public Maven repository over GitHub Pages, so **no credentials are required**. Add the repository to your **project-level** `android/build.gradle`:

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://meili-travel-tech.github.io/ux-native-android/") }
    }
}
```

### iOS setup

Add the Meili CocoaPods source to your `ios/Podfile`:

```ruby
source 'https://github.com/meili-travel-tech/meili-ios-pods'
source 'https://cdn.cocoapods.org/'

platform :ios, '16.0'
```

Then run:
```bash
cd ios && pod repo update && pod install
```

## Usage

### Open the MeiliCar flow

Open the MeiliCar flow imperatively (e.g. on button tap) — this is the only
supported way to present it, on both iOS and Android:

```dart
import 'package:meili_flutter_car/meili_flutter_car.dart';

await MeiliCar.open(MeiliCarParams(
  ptid: 'your-ptid',
  env: 'prod',
  flow: FlowType.direct,
));
```

### Booking Manager flow

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

### Prefill availability parameters

```dart
await MeiliCar.open(MeiliCarParams(
  ptid: 'your-ptid',
  env: 'prod',
  flow: FlowType.direct,
  availParams: AvailParams(
    pickupLocation: 'LHR',
    dropoffLocation: 'LHR',
    pickupDate: '2025-06-01',
    pickupTime: '10:00',
    dropoffDate: '2025-06-08',
    dropoffTime: '10:00',
    driverAge: 30,
    currencyCode: 'GBP',
    residency: 'GB',
  ),
));
```

Every `AvailParams` field is optional. Pass only what you want to prefill and the funnel keeps its own defaults for the rest, so setting just the currency is:

```dart
availParams: AvailParams(currencyCode: 'GBP'),
```

### Listening for events

```dart
import 'package:meili_flutter_car/meili_flutter_car.dart';

class MyPage extends StatefulWidget { ... }

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    MeiliCar.events.listen((event) {
      if (event is MeiliCarFlowDismissed) {
        // User closed the MeiliCar flow
        Navigator.of(context).pop();
      } else if (event is MeiliCarBookingFlowEnded) {
        // Booking complete; the SDK has returned to the search panel
      }
    });
  }
}
```

`MeiliCarBookingFlowEnded` is informational: the SDK has already returned to
its own search panel, and no action is required. Hosts that want to close
their modal when a booking completes can do so from this listener.

## Flows

| Flow | Description |
|------|-------------|
| `FlowType.direct` | Search and book a car rental |
| `FlowType.bookingManager` | View and manage an existing booking |

## Environments

| Value | Description |
|-------|-------------|
| `'prod'` | Production |
| `'pre_prod'` | Pre-production |
| `'uat'` | UAT |
| `'dev'` | Development |

## Migrating from `meili_flutter`

See [Migrating from `meili_flutter`](meili_flutter_car/README.md#migrating-from-meili_flutter)
in the `meili_flutter_car` README for the full migration steps.

## Contributing

Open issues or pull requests at [github.com/meili-travel-tech/meili_flutter_car](https://github.com/meili-travel-tech/meili_flutter_car).
