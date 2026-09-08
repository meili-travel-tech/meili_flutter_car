import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meili_flutter/meili_flutter.dart';
import 'package:meili_flutter_example/meili_settings.dart';
import 'package:meili_flutter_example/settings_repository.dart';

/// Owns the editable launch [MeiliSettings], persists every change, drives the
/// SDK launch, and surfaces one-shot toast messages (MVVM, per the project's
/// Flutter architecture skill).
class LaunchViewModel extends ChangeNotifier {
  /// Creates the view model, loading the persisted settings synchronously.
  ///
  /// [events] is injectable for testing; it defaults to [Meili.events].
  LaunchViewModel({
    required SettingsRepository repository,
    Stream<MeiliEvent>? events,
  })  : _repository = repository,
        _settings = repository.load() {
    _subscription = (events ?? Meili.events).listen(_onEvent);
  }

  final SettingsRepository _repository;
  late final StreamSubscription<MeiliEvent> _subscription;
  final StreamController<String> _toasts = StreamController<String>.broadcast();

  MeiliSettings _settings;
  bool _isLaunching = false;

  /// The current (persisted) settings snapshot.
  MeiliSettings get settings => _settings;

  /// Whether a launch is in flight (the launch button is disabled meanwhile).
  bool get isLaunching => _isLaunching;

  /// One-shot toast messages: booking notifications and launch errors.
  Stream<String> get toasts => _toasts.stream;

  /// Applies [settings] in memory and persists them.
  void update(MeiliSettings settings) {
    _settings = settings;
    notifyListeners();
    unawaited(_repository.save(settings));
  }

  /// Restores the iOS-matching defaults.
  void resetToDefaults() => update(const MeiliSettings());

  /// Launches the Meili SDK modally with the current settings.
  Future<void> launch() async {
    if (_isLaunching) {
      return;
    }
    _isLaunching = true;
    notifyListeners();
    try {
      await Meili.openMeiliView(_settings.toMeiliParams());
    } on Object catch (error) {
      _toasts.add('Failed to open Meili: $error');
    } finally {
      _isLaunching = false;
      notifyListeners();
    }
  }

  void _onEvent(MeiliEvent event) {
    if (event is MeiliBookingFlowEnded && _settings.showBookingToast) {
      _toasts.add('Booking flow ended');
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _toasts.close();
    super.dispose();
  }
}
