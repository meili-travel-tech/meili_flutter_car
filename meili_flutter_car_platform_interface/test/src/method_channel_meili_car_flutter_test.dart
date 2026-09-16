import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meili_flutter_car_platform_interface/meili_flutter_car_platform_interface.dart';
import 'package:meili_flutter_car_platform_interface/src/method_channel_meili_car_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('meili_flutter_car');

  group('MethodChannelMeiliCarFlutter', () {
    final impl = MethodChannelMeiliCarFlutter();
    final log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
        log.add(methodCall);
        return null;
      });
    });

    tearDown(log.clear);

    test('open invokes openMeiliViewController with params', () async {
      await impl.open(
        MeiliCarParams(ptid: '100.9', flow: FlowType.direct, env: 'dev'),
      );
      expect(log, hasLength(1));
      expect(log.single.method, 'openMeiliViewController');
      final args = log.single.arguments as Map;
      expect(args['ptid'], '100.9');
      expect(args['flow'], 'direct');
      expect(args['env'], 'dev');
    });

    test('popToRoot invokes the popToRoot method', () async {
      await impl.popToRoot();
      expect(log, hasLength(1));
      expect(log.single.method, 'popToRoot');
    });
  });
}
