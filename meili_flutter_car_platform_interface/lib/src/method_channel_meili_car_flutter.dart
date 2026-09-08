import 'package:flutter/services.dart';

import 'meili_flutter_car_platform_interface.dart';
import 'model/meili_car_event.dart';
import 'model/meili_car_params.dart';

/// Default [MeiliCarFlutterPlatform] implementation, shared by all platforms
/// (iOS and Android use the same channel and method names). Platform packages
/// only provide native code; they do not override this Dart layer.
class MethodChannelMeiliCarFlutter extends MeiliCarFlutterPlatform {
  static const _channel = MethodChannel('meili_flutter_car');
  static const _eventChannel = EventChannel('meili_flutter_car/events');

  Stream<MeiliCarEvent>? _events;

  @override
  Future<void> open(MeiliCarParams params) {
    return _channel.invokeMethod('openMeiliViewController', params.toMap());
  }

  @override
  Stream<MeiliCarEvent> get events {
    return _events ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) =>
            MeiliCarEvent.fromMap(Map<String, dynamic>.from(event as Map)))
        .asBroadcastStream();
  }

  @override
  Future<void> popToRoot() {
    return _channel.invokeMethod('popToRoot');
  }
}
