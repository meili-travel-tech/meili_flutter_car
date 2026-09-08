import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meili_flutter/meili_flutter.dart';
import 'package:meili_flutter_example/events_view_model.dart';
import 'package:meili_flutter_example/widgets/events_panel.dart';

void main() {
  testWidgets('EventsPanel renders events from the view model', (tester) async {
    final controller = StreamController<MeiliEvent>.broadcast();
    addTearDown(controller.close);
    final viewModel = EventsViewModel(events: controller.stream);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EventsPanel(viewModel: viewModel)),
      ),
    );

    expect(find.textContaining('No Meili events yet'), findsOneWidget);

    controller.add(
      const MeiliAnalyticsEvent(
        name: 'screen_viewed',
        properties: {'screen_name': 'home'},
      ),
    );
    await tester.pump();
    expect(find.textContaining('Analytics · screen_viewed'), findsOneWidget);

    controller.add(const MeiliFlowDismissed());
    await tester.pump();
    expect(find.text('Flow dismissed'), findsOneWidget);
  });
}
