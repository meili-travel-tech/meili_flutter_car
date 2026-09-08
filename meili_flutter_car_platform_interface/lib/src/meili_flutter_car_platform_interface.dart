import 'package:meili_flutter_car_platform_interface/src/model/meili_car_event.dart';
import 'package:meili_flutter_car_platform_interface/src/model/meili_car_params.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_meili_car_flutter.dart';

abstract class MeiliCarFlutterPlatform extends PlatformInterface {
  MeiliCarFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static MeiliCarFlutterPlatform _instance = MethodChannelMeiliCarFlutter();

  static MeiliCarFlutterPlatform get instance => _instance;

  static set instance(MeiliCarFlutterPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Presents the MeiliCar UI modally.
  Future<void> open(MeiliCarParams params) {
    throw UnimplementedError('open() has not been implemented.');
  }

  /// A broadcast stream of [MeiliCarEvent]s emitted by the native SDK
  /// (lifecycle events plus forwarded analytics).
  Stream<MeiliCarEvent> get events {
    throw UnimplementedError('events has not been implemented.');
  }

  /// Invokes the SDK's retained `popToRoot` action, typically in response to a
  /// [MeiliCarBookingFlowEnded] event. No-op if there is nothing to pop.
  Future<void> popToRoot() {
    throw UnimplementedError('popToRoot() has not been implemented.');
  }
}
