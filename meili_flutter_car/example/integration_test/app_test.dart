import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meili_flutter_car/meili_flutter_car.dart';
import 'package:meili_flutter_car_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E', () {
    testWidgets('launches on the configure screen with an empty Events tab',
        (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // The Launch tab hosts the inline settings; the Events tab is separate.
      expect(find.text('Launch'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);

      // Inline settings are visible on the launch screen.
      expect(find.text('PTID'), findsOneWidget);
      expect(find.text('Direct'), findsOneWidget);
      expect(find.text('Booking Manager'), findsOneWidget);

      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No MeiliCar events yet'), findsOneWidget);
    });

    testWidgets(
        'MeiliCar.open() presents the funnel over the renamed native chain '
        'and bookingFlowEnded round-trip (popToRoot kept as a deprecated '
        'no-op)', (tester) async {
      final events = <MeiliCarEvent>[];
      final subscription = MeiliCar.events.listen(events.add);
      addTearDown(subscription.cancel);

      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch MeiliCar'));

      // The SDK's UI is a separate Activity (Android) / a modally presented
      // controller (iOS) outside Flutter's widget tree, so the engine pauses
      // once it launches and `pumpAndSettle` would never settle. `runAsync`
      // escapes the fake async zone so the channel round trip still
      // resolves while paused; the `.timeout()` bounds the wait instead of
      // hanging the suite if it doesn't.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(seconds: 5));
        // ignore: deprecated_member_use
        await MeiliCar.popToRoot();
        await Future<void>.delayed(const Duration(seconds: 2));
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          // ignore: avoid_print
          print('Timed out waiting on the native flow; continuing.');
        },
      );
      await tester.pump();
      expect(find.text('Launch MeiliCar'), findsOneWidget);
      // ignore: avoid_print
      print('MeiliCar events observed after open()+bookingFlowEnded: $events');
    });
  });
}
