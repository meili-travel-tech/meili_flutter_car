import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meili_flutter_example/main.dart' as app;

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
      expect(find.textContaining('No Meili events yet'), findsOneWidget);
    });
  });
}
