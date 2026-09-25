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

  /// Kept for older app packages that still call it. A no-op from
  /// MeiliCarSDK 1.13.0, which resets itself to its search panel on its own.
  Future<void> popToRoot() {
    throw UnimplementedError('popToRoot() has not been implemented.');
  }
}
