import 'package:flutter_test/flutter_test.dart';
import 'package:meili_flutter_car_platform_interface/meili_flutter_car_platform_interface.dart';

void main() {
  group('MeiliCarEvent.fromMap', () {
    test('parses flowDismissed', () {
      expect(
        MeiliCarEvent.fromMap({'type': 'flowDismissed'}),
        isA<MeiliCarFlowDismissed>(),
      );
    });

    test('parses bookingFlowEnded', () {
      expect(
        MeiliCarEvent.fromMap({'type': 'bookingFlowEnded'}),
        isA<MeiliCarBookingFlowEnded>(),
      );
    });

    test('parses analytics with name and properties', () {
      final event = MeiliCarEvent.fromMap({
        'type': 'analytics',
        'name': 'screen_viewed',
        'properties': {'screen_name': 'home'},
      });
      expect(event, isA<MeiliCarAnalyticsEvent>());
      final analytics = event as MeiliCarAnalyticsEvent;
      expect(analytics.name, 'screen_viewed');
      expect(analytics.properties['screen_name'], 'home');
    });

    test('analytics defaults properties to empty when missing', () {
      final event = MeiliCarEvent.fromMap({'type': 'analytics', 'name': 'x'})
          as MeiliCarAnalyticsEvent;
      expect(event.properties, isEmpty);
    });

    test('well-formed unknown type becomes MeiliCarUnknownEvent', () {
      final event = MeiliCarEvent.fromMap({'type': 'somethingNew', 'foo': 1});
      expect(event, isA<MeiliCarUnknownEvent>());
      final unknown = event as MeiliCarUnknownEvent;
      expect(unknown.type, 'somethingNew');
      expect(unknown.raw['foo'], 1);
    });

    test('analytics without a name falls back to unknown', () {
      expect(
        MeiliCarEvent.fromMap({'type': 'analytics'}),
        isA<MeiliCarUnknownEvent>(),
      );
    });

    test('missing type throws FormatException', () {
      expect(
        () => MeiliCarEvent.fromMap({'foo': 'bar'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('MeiliCarEvent.toMap', () {
    test('round-trips each variant', () {
      expect(const MeiliCarFlowDismissed().toMap(), {'type': 'flowDismissed'});
      expect(
        const MeiliCarBookingFlowEnded().toMap(),
        {'type': 'bookingFlowEnded'},
      );
      expect(
        const MeiliCarAnalyticsEvent(name: 'e', properties: {'a': 1}).toMap(),
        {
          'type': 'analytics',
          'name': 'e',
          'properties': {'a': 1},
        },
      );
    });
  });
}
