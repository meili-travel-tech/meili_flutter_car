# meili_flutter_car AI Notes

Purpose: App-facing Dart package for the Meili Flutter Car plugin.

Key APIs
- `MeiliCar.open(MeiliCarParams)` calls through to the shared
  `MethodChannelMeiliCarFlutter` (channel `meili_flutter_car`) in
  `meili_flutter_car_platform_interface`; both platform packages contribute
  native code only, no per-platform Dart override.
- `MeiliCar.events` is a broadcast `Stream<MeiliCarEvent>` sourced from the
  `meili_flutter_car/events` EventChannel — lifecycle events
  (`MeiliCarFlowDismissed`, `MeiliCarBookingFlowEnded`) plus forwarded
  analytics (`MeiliCarAnalyticsEvent`). Both platforms forward the lifecycle
  events; forwarded analytics events are iOS-only for now — see
  `meili_flutter_car_android/AI.md`.
- `MeiliCar.popToRoot()` is deprecated and a no-op on both platforms: the
  SDK resets itself to its search panel on its own after
  `MeiliCarBookingFlowEnded`.

Models (`meili_flutter_car_platform_interface`)
- `MeiliCarParams`: ptid, flow (`FlowType`), env, availParams, additionalParams.
- `AvailParams`: pickup/dropoff info, dates/times, driverAge, currency, residency — every field optional.
- `AdditionalParams`: booking/customer details (`BookingParams` is a deprecated alias).
- `MeiliCarEvent`: sealed hierarchy — `MeiliCarFlowDismissed`, `MeiliCarBookingFlowEnded`, `MeiliCarAnalyticsEvent`, `MeiliCarUnknownEvent`.
