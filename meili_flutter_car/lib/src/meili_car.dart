import 'package:meili_flutter_car_platform_interface/meili_flutter_car_platform_interface.dart';

/// Entry point for driving the MeiliCar SDK and observing its events.
class MeiliCar {
  /// Presents the MeiliCar UI modally using [params].
  static Future<void> open(MeiliCarParams params) {
    return MeiliCarFlutterPlatform.instance.open(params);
  }

  /// A broadcast stream of [MeiliCarEvent]s emitted by the native SDK:
  /// lifecycle events ([MeiliCarFlowDismissed], [MeiliCarBookingFlowEnded]) and
  /// forwarded analytics ([MeiliCarAnalyticsEvent]).
  ///
  /// Events emitted before the first listener subscribes are dropped.
  /// Both platforms forward the lifecycle events; forwarded analytics
  /// events are currently iOS-only. [MeiliCarBookingFlowEnded] is a
  /// notification only — the SDK has already returned to its search panel
  /// and no host action is required.
  static Stream<MeiliCarEvent> get events =>
      MeiliCarFlutterPlatform.instance.events;

  /// No-op kept for source compatibility. The SDK returns to its search
  /// panel on its own; hosts no longer need to call this.
  @Deprecated(
    'The SDK returns to the search panel itself since '
    'meili_flutter_car_ios 0.6.0; this call is a no-op kept for '
    'compatibility',
  )
  static Future<void> popToRoot() =>
      MeiliCarFlutterPlatform.instance.popToRoot();
}
