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
  meili_flutter_car: ^0.11.0
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
  env: MeiliCarEnv.prod,
  flow: FlowType.direct,
));
```

### Booking Manager flow

```dart
await MeiliCar.open(MeiliCarParams(
  ptid: 'your-ptid',
  env: MeiliCarEnv.prod,
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
  env: MeiliCarEnv.prod,
  flow: FlowType.direct,
  availParams: AvailParams(
    pickupLocation: 'LHR',
    dropoffLocation: 'LHR',
    pickupDateTime: DateTime(2025, 6, 1, 10),
    dropoffDateTime: DateTime(2025, 6, 8, 10),
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

Pass the pickup and drop-off as a `DateTime`, or as `pickupDate` (`yyyy-MM-dd`) and
`pickupTime` (`HH:mm`) strings, never both: setting a `DateTime` together with its
strings is an assertion error. See [Avail params](#avail-params) for what reaches the SDKs.

### Listening for events

```dart
import 'dart:developer';

import 'package:meili_flutter_car/meili_flutter_car.dart';

class MyPage extends StatefulWidget { ... }

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    MeiliCar.events.listen((event) {
      switch (event) {
        case MeiliCarFlowDismissed():
          // User closed the MeiliCar flow
          Navigator.of(context).pop();
        case MeiliCarBookingFlowEnded():
          // Booking complete; the SDK returns to its search panel right after this
          break;
        case MeiliCarBookingSucceeded(:final reservation):
          // A reservation was just made (record the conversion)
          log('Booked ${reservation['confirmationId']}');
        case MeiliCarErrorEvent(:final area, :final kind, :final message):
          // An SDK-internal failure occurred (log it, report to analytics, etc.)
          log('MeiliCar error: $area/$kind — $message');
        case _:
          break;
      }
    });
  }
}
```

| Event | When it fires | Platforms |
|-------|---------------|-----------|
| `MeiliCarFlowDismissed` | The user closed the MeiliCar UI | iOS, Android |
| `MeiliCarBookingSucceeded` | Right after a reservation succeeds, once per booking | iOS, Android |
| `MeiliCarBookingFlowEnded` | The booking flow reached its end | iOS, Android |
| `MeiliCarErrorEvent` | An SDK-internal request failed | iOS, Android |
| `MeiliCarAnalyticsEvent` | The SDK tracked an analytics event | iOS only, see [Known limitations](#known-limitations) |
| `MeiliCarUnknownEvent` | An event type this plugin version does not model | iOS, Android |

`MeiliCarBookingSucceeded.reservation` is the raw reservation response from the booking API,
decoded from JSON, plus a top-level `meiliSessionId`. It has the same keys on iOS and
Android, includes the traveller's contact details, and fires as soon as the reservation
succeeds, before the confirmation screen appears, like the web app's booking success event.
If the native payload cannot be decoded, `reservation` is an empty map.

`MeiliCarBookingFlowEnded` is informational: the SDK resets itself to its own
search panel immediately after this event; no host action is required. Hosts
that want to close their modal when a booking completes can do so from this
listener.

## Flows

| Flow | Description |
|------|-------------|
| `FlowType.direct` | Search and book a car rental |
| `FlowType.bookingManager` | View and manage an existing booking |

## Environments

`MeiliCarParams.env` takes a `MeiliCarEnv`:

| Value | Description |
|-------|-------------|
| `MeiliCarEnv.prod` | Production |
| `MeiliCarEnv.preProd` | Pre-production |
| `MeiliCarEnv.uat` | UAT |
| `MeiliCarEnv.dev` | Development |

The enum name is what reaches the native SDKs. A value they do not accept
fails `MeiliCar.open` with a `PlatformException` (`INVALID_ARGUMENT`) instead of opening dev.

## Avail params

`AvailParams` keys reach both SDKs one-to-one, with the same name on the iOS and Android
`AvailParams`:

| Dart key | iOS `AvailParams` field | Android `AvailParams` field |
|----------|-------------------------|-----------------------------|
| `pickupLocation` | `pickupLocation` | `pickupLocation` |
| `dropoffLocation` | `dropoffLocation` | `dropoffLocation` |
| `pickupDate` | `pickupDate` | `pickupDate` |
| `pickupTime` | `pickupTime` | `pickupTime` |
| `dropoffDate` | `dropoffDate` | `dropoffDate` |
| `dropoffTime` | `dropoffTime` | `dropoffTime` |
| `pickupDateTime` | `pickupDate` + `pickupTime` | `pickupDate` + `pickupTime` |
| `dropoffDateTime` | `dropoffDate` + `dropoffTime` | `dropoffDate` + `dropoffTime` |
| `driverAge` | `driverAge` | `driverAge` |
| `currencyCode` | `currencyCode` | `currencyCode` |
| `residency` | `residency` | `residency` |
| `discountRequested` | `discountRequested` | `discountRequested` |
| `partnerLoyaltyAccountTier` | `partnerLoyaltyAccountTier` | `partnerLoyaltyAccountTier` |

- `pickupDateTime` and `dropoffDateTime` are split in Dart and never cross the channel: the
  plugin sends `pickupDate` as `yyyy-MM-dd` and `pickupTime` as `HH:mm` (and the same for
  drop-off) from the `DateTime`'s own fields, with no time-zone conversion.
- A `null` field is left out of the map. Everything else is passed through as given: the
  SDKs treat blank strings (empty or whitespace only) and a `driverAge` of 0 or less as unset,
  so the plugin does not normalise them.

## Additional params

`AdditionalParams` reaches both SDKs key for key, with the SDKs' own names and types.

| Dart key | iOS `AdditionalParams` field | Android `AdditionalParams` field |
|----------|------------------------------|----------------------------------|
| `supplierLoyaltyAccounts` (`List<SupplierLoyaltyAccount>`) | `supplierLoyaltyAccounts: [SupplierLoyaltyAccount]` | `supplierLoyaltyAccounts: List<SupplierLoyaltyAccount>` |
| `phoneNumbers` (`List<String>`, international format with a leading `+`) | `phoneNumbers: [String]` | `phoneNumbers: List<String>` |
| `givenName` | `givenName` | `givenName` |
| `corporateCode` | `corporateCode` | `corporateCode` |
| `partnerLoyaltyAccount` | `partnerLoyaltyAccount` | `partnerLoyaltyAccount` |
| `partnerLoyaltyAccountTier` | `partnerLoyaltyAccountTier` | `partnerLoyaltyAccountTier` |
| `numberOfPassengers` | `numberOfPassengers` | `numberOfPassengers` |
| `customerPartnerCode` | `customerPartnerCode` | `customerPartnerCode` |
| `flightNumber` | `flightNumber` | `flightNumber` |
| `passengerNameRecord` | `passengerNameRecord` | `passengerNameRecord` |
| `superPassengerNameRecord` | `superPassengerNameRecord` | `superPassengerNameRecord` |
| `infant` | `infant` | `infant` |
| `child` | `child` | `child` |
| `teenager` | `teenager` | `teenager` |
| `fareTypeAndFlex` | `fareTypeAndFlex` | `fareTypeAndFlex` |
| `departureAirport` | `departureAirport` | `departureAirport` |
| `arrivalAirport` | `arrivalAirport` | `arrivalAirport` |
| `ancillaryActivity` | `ancillaryActivity` | `ancillaryActivity` |
| `airlineFareAmount` | `airlineFareAmount` | `airlineFareAmount` |
| `airlineFareCurrency` | `airlineFareCurrency` | `airlineFareCurrency` |
| `partnerCustomerID` | `partnerCustomerID` | `partnerCustomerID` |
| `firstName` | `firstName` | `firstName` |
| `lastName` | `lastName` | `lastName` |
| `email` | `email` | `email` |
| `companyName` | `companyName` | `companyName` |
| `addressLine1` | `addressLine1` | `addressLine1` |
| `postCode` | `postCode` | `postCode` |
| `city` | `city` | `city` |
| `state` | `state` | `state` |
| `confirmationId` | `confirmationId` | `confirmationId` |
| `prefillOnly` | `prefillOnly` | `prefillOnly` |

`SupplierLoyaltyAccount(customerAccount: ..., supplierName: ...)` has the same name and fields
on both SDKs; `supplierName` is optional. An element without a `String` `customerAccount`, or
that is not a map, is skipped on both platforms.

```dart
additionalParams: AdditionalParams(
  supplierLoyaltyAccounts: [
    SupplierLoyaltyAccount(customerAccount: '123456', supplierName: 'Hertz'),
    SupplierLoyaltyAccount(customerAccount: '789012'),
  ],
  phoneNumbers: ['+353871234567'],
  givenName: 'Ada',
  corporateCode: 'ACME-42',
),
```

## Known limitations

- **Android analytics:** `MeiliCarAnalyticsEvent` is only sent on iOS. Android forwarding arrives
  in a later 0.10.x release, after the Android SDK exposes a public analytics API (MPD-7113).
- **iOS 15:** the funnel is not available natively, so the SDK opens its web fallback. The
  fallback sends no `MeiliCarBookingSucceeded`, and it receives the params only through its query.

## Migrating from `meili_flutter`

See [Migrating from `meili_flutter`](meili_flutter_car/README.md#migrating-from-meili_flutter)
in the `meili_flutter_car` README for the full migration steps.

## Contributing

Open issues or pull requests at [github.com/meili-travel-tech/meili_flutter_car](https://github.com/meili-travel-tech/meili_flutter_car).
