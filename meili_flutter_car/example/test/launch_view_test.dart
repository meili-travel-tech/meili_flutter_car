import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meili_flutter/meili_flutter.dart';
import 'package:meili_flutter_example/launch_view_model.dart';
import 'package:meili_flutter_example/settings_repository.dart';
import 'package:meili_flutter_example/widgets/launch_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LaunchViewModel> buildViewModel(
    StreamController<MeiliEvent> events,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final repository =
        SettingsRepository(await SharedPreferences.getInstance());
    return LaunchViewModel(repository: repository, events: events.stream);
  }

  testWidgets('renders inline settings and reveals the currency field',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final events = StreamController<MeiliEvent>.broadcast();
    addTearDown(events.close);
    final viewModel = await buildViewModel(events);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LaunchView(viewModel: viewModel)),
    );

    // Settings and the launch button share the one screen.
    expect(find.text('PTID'), findsOneWidget);
    expect(find.text('Launch Meili'), findsOneWidget);

    // Booking Manager fields are hidden for the default Direct flow, so only
    // PTID shows; enabling currency override adds the Currency field.
    expect(find.byType(TextField), findsNWidgets(1));
    viewModel.update(viewModel.settings.copyWith(overrideCurrency: true));
    await tester.pump();
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('Manage My Booking shows only for the Booking Manager flow',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final events = StreamController<MeiliEvent>.broadcast();
    addTearDown(events.close);
    final viewModel = await buildViewModel(events);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LaunchView(viewModel: viewModel)),
    );

    // Hidden for the default Direct flow.
    expect(find.text('Manage My Booking'), findsNothing);
    expect(find.text('Confirmation Id'), findsNothing);

    viewModel.update(
      viewModel.settings.copyWith(flow: FlowType.bookingManager),
    );
    await tester.pump();

    expect(find.text('Manage My Booking'), findsOneWidget);
    expect(find.text('Confirmation Id'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
  });

  testWidgets('Reset restores the default PTID in the text field',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final events = StreamController<MeiliEvent>.broadcast();
    addTearDown(events.close);
    final viewModel = await buildViewModel(events);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LaunchView(viewModel: viewModel)),
    );

    await tester.enterText(find.byType(TextField).first, '55');
    await tester.pump();
    expect(viewModel.settings.ptid, '55');

    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(viewModel.settings.ptid, '100.9');
    expect(find.text('100.9'), findsWidgets);
  });
}
