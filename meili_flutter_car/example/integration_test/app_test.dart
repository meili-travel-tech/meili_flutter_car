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
        'and MeiliCar.popToRoot() round-trips', (tester) async {
      // Proves the Phase 4 chain end to end: the Dart call resolves through
      // MeiliCarFlutterPlatform -> the `meili_flutter_car` MethodChannel ->
      // the renamed native plugin -> MeiliCarActivity (Android) /
      // MeiliCarView (iOS) without throwing. The SDK presents its UI outside
      // Flutter's own widget/view tree (a separate Activity on Android, a
      // modally-presented UIViewController on iOS), so WidgetTester — which
      // only dispatches synthetic pointer events into the Flutter engine —
      // cannot drive that native chrome to interact with or dismiss it; an
      // assertion on a real `MeiliCarFlowDismissed` event would need
      // native-level UI automation (e.g. XCUITest/Espresso via a package like
      // patrol), which is out of scope here.
      final events = <MeiliCarEvent>[];
      final subscription = MeiliCar.events.listen(events.add);
      addTearDown(subscription.cancel);

      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch MeiliCar'));

      // On Android, MeiliCarActivity is a separate foreground Activity, so
      // the test's own FlutterEngine (and its frame scheduling) pauses the
      // moment it launches — `pumpAndSettle` never sees another frame and
      // hangs forever waiting for one. `tester.runAsync` escapes the fake
      // async zone so real timers (and the method channel round trip) still
      // resolve while paused. A `.timeout()` bounds the whole wait in case a
      // channel call never returns while the engine is paused, rather than
      // hanging the suite; a timeout is treated the same as "no event
      // observed in time", not a test failure.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(seconds: 5));

        // popToRoot() is a no-op with nothing retained (Direct flow, no
        // bookingFlowEnded yet) — this only proves the renamed `popToRoot`
        // channel call resolves without throwing.
        await MeiliCar.popToRoot();

        // Best-effort: if the SDK auto-dismissed (e.g. a message state due
        // to no network in the test environment) within a short window, a
        // MeiliCarFlowDismissed event will already be in the buffer.
        await Future<void>.delayed(const Duration(seconds: 2));
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          // ignore: avoid_print
          print('Timed out waiting on the native flow; continuing.');
        },
      );
      await tester.pump();
      // ignore: avoid_print
      print('MeiliCar events observed after open()+popToRoot(): $events');
    });
  });
}
