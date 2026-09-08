import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meili_flutter/meili_flutter.dart';
import 'package:meili_flutter_example/launch_view_model.dart';
import 'package:meili_flutter_example/meili_settings.dart';
import 'package:meili_flutter_example/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MeiliSettings', () {
    test('defaults match the iOS Sample App', () {
      const settings = MeiliSettings();
      expect(settings.ptid, '100.9');
      expect(settings.env, MeiliEnv.dev);
      expect(settings.flow, FlowType.direct);
      expect(settings.overrideCurrency, isFalse);
      expect(settings.currency, 'EUR');
      expect(settings.showBookingToast, isFalse);
    });

    test('toMeiliParams maps core fields and omits empty extras', () {
      const settings = MeiliSettings(env: MeiliEnv.prod);
      final params = settings.toMeiliParams();
      expect(params.ptid, '100.9');
      expect(params.env, 'prod');
      expect(params.flow, FlowType.direct);
      expect(params.availParams, isNull);
      expect(params.additionalParams, isNull);
    });

    test('toMeiliParams includes booking + currency when set', () {
      const settings = MeiliSettings(
        flow: FlowType.bookingManager,
        overrideCurrency: true,
        currency: 'USD',
        confirmationId: 'ABC123',
        lastName: 'Doe',
        prefillOnly: true,
      );
      final params = settings.toMeiliParams();
      expect(params.flow, FlowType.bookingManager);
      expect(params.availParams?.currencyCode, 'USD');
      expect(params.additionalParams?.confirmationId, 'ABC123');
      expect(params.additionalParams?.lastName, 'Doe');
      expect(params.additionalParams?.prefillOnly, isTrue);
    });

    test('round-trips through JSON', () {
      const settings = MeiliSettings(
        ptid: '42',
        env: MeiliEnv.uat,
        flow: FlowType.bookingManager,
        overrideCurrency: true,
        currency: 'GBP',
        confirmationId: 'X1',
        lastName: 'Smith',
        prefillOnly: true,
        showBookingToast: true,
      );
      final restored = MeiliSettings.fromJson(settings.toJson());
      expect(restored.toJson(), settings.toJson());
    });
  });

  group('SettingsRepository', () {
    test('returns defaults when nothing is stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = SettingsRepository(
        await SharedPreferences.getInstance(),
      );
      expect(repository.load().toJson(), const MeiliSettings().toJson());
    });

    test('persists and reloads settings', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = SettingsRepository(
        await SharedPreferences.getInstance(),
      );
      const settings = MeiliSettings(ptid: '7', env: MeiliEnv.prod);
      await repository.save(settings);
      expect(repository.load().toJson(), settings.toJson());
    });
  });

  group('LaunchViewModel', () {
    late SettingsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      repository = SettingsRepository(await SharedPreferences.getInstance());
    });

    test('update persists and resetToDefaults restores', () {
      final events = StreamController<MeiliEvent>.broadcast();
      addTearDown(events.close);
      final viewModel = LaunchViewModel(
        repository: repository,
        events: events.stream,
      );
      addTearDown(viewModel.dispose);

      viewModel.update(const MeiliSettings(ptid: '999'));
      expect(viewModel.settings.ptid, '999');
      expect(repository.load().ptid, '999');

      viewModel.resetToDefaults();
      expect(viewModel.settings.ptid, '100.9');
    });

    test('emits a booking toast only when enabled', () async {
      final events = StreamController<MeiliEvent>.broadcast();
      addTearDown(events.close);
      final viewModel = LaunchViewModel(
        repository: repository,
        events: events.stream,
      );
      addTearDown(viewModel.dispose);

      final toasts = <String>[];
      final subscription = viewModel.toasts.listen(toasts.add);
      addTearDown(subscription.cancel);

      // Disabled by default: no toast.
      events.add(const MeiliBookingFlowEnded());
      await Future<void>.delayed(Duration.zero);
      expect(toasts, isEmpty);

      // Enabled: toast emitted.
      viewModel.update(const MeiliSettings(showBookingToast: true));
      events.add(const MeiliBookingFlowEnded());
      await Future<void>.delayed(Duration.zero);
      expect(toasts, <String>['Booking flow ended']);
    });
  });
}
