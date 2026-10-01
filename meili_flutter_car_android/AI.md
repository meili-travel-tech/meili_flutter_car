# meili_flutter_car_android AI Notes

Purpose: Android implementation of the Meili Flutter Car plugin.

## Key code

- `MeiliFlutterPlugin.kt` (package `com.meili.travel.flutter.car`): MethodChannel
  `meili_flutter_car`, EventChannel `meili_flutter_car/events`, implements `ActivityAware`.
  `openMeiliViewController` launches the SDK's `com.meili.travel.car.api.MeiliCarActivity` with the
  full parsed params (ptid, env, flow, availParams, additionalParams) and a
  `MeiliCarComposeListener` — `onBack`/`onEndBookingFlow`/`onError` push
  `flowDismissed`/`bookingFlowEnded`/`error` onto the event sink.
- `MeiliParamsParser.kt`: maps the Dart method-call argument maps to `AvailParams`/
  `AdditionalParams`/`MeiliCarEnvironment`/`MeiliCarFlow`.
- The plugin's package is product-scoped (`com.meili.travel.flutter.car`) so a second Meili
  Flutter plugin in the same host app cannot collide on `MeiliFlutterPlugin`.

## Dependencies

- `com.meili.travel:meili-car-sdk` from GitHub Pages (public Maven, no credentials required).
  Version pinned directly in `android/build.gradle`.

## Build requirements

- AGP 8.3+, Kotlin 2.1.0, Gradle 8.2+, JDK 17.
- `minSdk 24`, `compileSdk 35`.

## Events

`flowDismissed`, `bookingFlowEnded` and SDK errors (`onError`, sent as type `error`) are forwarded
through the `MeiliCarComposeListener`. Analytics events (`MeiliCarAnalyticsEvent` on the Dart side) are **not**
forwarded on Android — there is no Android equivalent yet of iOS's
`MeiliFlutterAnalyticsProvider`/`MeiliCarAnalytics.shared.addProvider(_:)` wiring.
