import 'package:flutter_test/flutter_test.dart';
import 'package:meili_flutter_car_platform_interface/meili_flutter_car_platform_interface.dart';

void main() {
  group('MeiliCarEvent.fromMap', () {
    test('error tolerates a non-int httpCode', () {
      final fractional = MeiliCarEvent.fromMap({
        'type': 'error',
        'area': 'costs',
        'kind': 'http',
        'httpCode': 503.0,
        'message': 'costs request failed: HTTP 503',
      }) as MeiliCarErrorEvent;
      expect(fractional.httpCode, 503);

      final textual = MeiliCarEvent.fromMap({
        'type': 'error',
        'area': 'costs',
        'kind': 'http',
        'httpCode': '503',
        'message': 'costs request failed: HTTP 503',
      }) as MeiliCarErrorEvent;
      expect(textual.httpCode, isNull);
    });

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

    test('parses a full error event', () {
      final event = MeiliCarEvent.fromMap({
        'type': 'error',
        'area': 'checkout',
        'kind': 'http',
        'httpCode': 502,
        'message': 'checkout request failed: HTTP 502',
      });
      expect(event, isA<MeiliCarErrorEvent>());
      final error = event as MeiliCarErrorEvent;
      expect(error.area, MeiliCarErrorArea.checkout);
      expect(error.kind, MeiliCarErrorKind.http);
      expect(error.httpCode, 502);
      expect(error.message, 'checkout request failed: HTTP 502');
    });

    test('parses an error event with a null httpCode', () {
      final event = MeiliCarEvent.fromMap({
        'type': 'error',
        'area': 'availability',
        'kind': 'network',
        'httpCode': null,
        'message': 'no connectivity',
      }) as MeiliCarErrorEvent;
      expect(event.httpCode, isNull);
    });

    test('parses an error event with a missing httpCode', () {
      final event = MeiliCarEvent.fromMap({
        'type': 'error',
        'area': 'config',
        'kind': 'decode',
        'message': 'malformed config response',
      }) as MeiliCarErrorEvent;
      expect(event.httpCode, isNull);
    });

    test('parses every error area and kind', () {
      const areas = {
        'config': MeiliCarErrorArea.config,
        'availability': MeiliCarErrorArea.availability,
        'costs': MeiliCarErrorArea.costs,
        'checkout': MeiliCarErrorArea.checkout,
        'reservation': MeiliCarErrorArea.reservation,
        'partnerContent': MeiliCarErrorArea.partnerContent,
      };
      const kinds = {
        'network': MeiliCarErrorKind.network,
        'http': MeiliCarErrorKind.http,
        'decode': MeiliCarErrorKind.decode,
        'unexpected': MeiliCarErrorKind.unexpected,
      };
      for (final areaEntry in areas.entries) {
        for (final kindEntry in kinds.entries) {
          final event = MeiliCarEvent.fromMap({
            'type': 'error',
            'area': areaEntry.key,
            'kind': kindEntry.key,
            'message': 'm',
          }) as MeiliCarErrorEvent;
          expect(event.area, areaEntry.value);
          expect(event.kind, kindEntry.value);
        }
      }
    });

    test('an unrecognised error area falls back to unknown', () {
      final event = MeiliCarEvent.fromMap({
        'type': 'error',
        'area': 'somethingNew',
        'kind': 'network',
        'message': 'm',
      }) as MeiliCarErrorEvent;
      expect(event.area, MeiliCarErrorArea.unknown);
    });

    test('an unrecognised error kind falls back to unknown', () {
      final event = MeiliCarEvent.fromMap({
        'type': 'error',
        'area': 'config',
        'kind': 'somethingNew',
        'message': 'm',
      }) as MeiliCarErrorEvent;
      expect(event.kind, MeiliCarErrorKind.unknown);
    });

    test('error event without area/kind/message falls back to unknown', () {
      expect(
        MeiliCarEvent.fromMap({'type': 'error'}),
        isA<MeiliCarUnknownEvent>(),
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
      expect(
        const MeiliCarErrorEvent(
          area: MeiliCarErrorArea.checkout,
          kind: MeiliCarErrorKind.http,
          httpCode: 502,
          message: 'm',
        ).toMap(),
        {
          'type': 'error',
          'area': 'checkout',
          'kind': 'http',
          'httpCode': 502,
          'message': 'm',
        },
      );
    });
  });
}
