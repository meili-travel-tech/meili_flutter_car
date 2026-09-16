import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meili_flutter_car/meili_flutter_car.dart';
import 'package:meili_flutter_car_platform_interface/meili_flutter_car_platform_interface.dart';

class MockMeiliCarPlatform extends MeiliCarFlutterPlatform {
  MeiliCarParams? lastParams;
  Object? errorToThrow;

  @override
  Future<void> open(MeiliCarParams params) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastParams = params;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMeiliCarPlatform mock;

  setUp(() {
    mock = MockMeiliCarPlatform();
    MeiliCarFlutterPlatform.instance = mock;
  });

  final params = MeiliCarParams(
    ptid: '100.10',
    flow: FlowType.direct,
    env: 'dev',
  );

  test('open delegates to platform instance', () async {
    await MeiliCar.open(params);
    expect(mock.lastParams, params);
  });

  test('open propagates PlatformException from native side', () {
    mock.errorToThrow =
        PlatformException(code: 'ERROR', message: 'native fail');
    expect(
      () => MeiliCar.open(params),
      throwsA(isA<PlatformException>()),
    );
  });

  test('unregistered platform throws MissingPluginException', () {
    MeiliCarFlutterPlatform.instance = MethodChannelMeiliCarFlutter();
    expect(
      () => MeiliCar.open(params),
      throwsA(isA<MissingPluginException>()),
    );
  });
}
