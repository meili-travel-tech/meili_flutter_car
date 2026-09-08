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
  analytics (`MeiliCarAnalyticsEvent`). Currently sourced from iOS only; see
  `meili_flutter_car_android/AI.md`.
- `MeiliCar.popToRoot()` invokes the SDK's retained `popToRoot` action,
  typically in response to a `MeiliCarBookingFlowEnded` event.

Models (`meili_flutter_car_platform_interface`)
- `MeiliCarParams`: ptid, flow (`FlowType`), env, availParams, additionalParams.
- `AvailParams`: pickup/dropoff info, dates/times, driverAge, currency, residency — every field optional.
- `AdditionalParams`: booking/customer details (`BookingParams` is a deprecated alias).
- `MeiliCarEvent`: sealed hierarchy — `MeiliCarFlowDismissed`, `MeiliCarBookingFlowEnded`, `MeiliCarAnalyticsEvent`, `MeiliCarUnknownEvent`.
