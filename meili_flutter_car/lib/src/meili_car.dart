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
  /// events are currently iOS-only.
  static Stream<MeiliCarEvent> get events =>
      MeiliCarFlutterPlatform.instance.events;

  /// Invokes the SDK's retained `popToRoot` action — typically called by the
  /// host in response to a [MeiliCarBookingFlowEnded] event. No-op if there
  /// is nothing to pop.
  static Future<void> popToRoot() =>
      MeiliCarFlutterPlatform.instance.popToRoot();
}
