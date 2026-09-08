import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meili_flutter_car_platform_interface/meili_flutter_car_platform_interface.dart';

class _MockMeiliFlutter extends MeiliCarFlutterPlatform {
  bool opened = false;
  bool poppedToRoot = false;
  final StreamController<MeiliCarEvent> controller =
      StreamController<MeiliCarEvent>.broadcast();

  @override
  Future<void> open(MeiliCarParams params) async {
    opened = true;
  }

  @override
  Stream<MeiliCarEvent> get events => controller.stream;

  @override
  Future<void> popToRoot() async {
    poppedToRoot = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MeiliCarFlutterPlatform', () {
    late _MockMeiliFlutter mock;

    setUp(() {
      mock = _MockMeiliFlutter();
      MeiliCarFlutterPlatform.instance = mock;
    });

    test('open delegates to the instance', () async {
      await MeiliCarFlutterPlatform.instance.open(
        MeiliCarParams(ptid: '1', flow: FlowType.direct, env: 'dev'),
      );
      expect(mock.opened, isTrue);
    });

    test('popToRoot delegates to the instance', () async {
      await MeiliCarFlutterPlatform.instance.popToRoot();
      expect(mock.poppedToRoot, isTrue);
    });

    test('events surfaces emitted MeiliEvents', () {
      expect(
        MeiliCarFlutterPlatform.instance.events,
        emitsInOrder(<Matcher>[
          isA<MeiliCarFlowDismissed>(),
          isA<MeiliCarAnalyticsEvent>(),
        ]),
      );
      mock.controller
        ..add(const MeiliCarFlowDismissed())
        ..add(const MeiliCarAnalyticsEvent(name: 'screen_viewed'));
    });
  });
}
