import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meili_flutter_car/meili_flutter_car.dart';

/// A single received event tagged with a stable id (for list keys).
typedef EventRecord = ({int id, MeiliCarEvent event});

/// Subscribes to [MeiliCar.events] and exposes the received events as immutable
/// state for the UI (MVVM, per the project's Flutter architecture skill).
class EventsViewModel extends ChangeNotifier {
  /// Creates the view model and begins listening.
  ///
  /// [events] is injectable for testing; it defaults to [MeiliCar.events].
  EventsViewModel({Stream<MeiliCarEvent>? events}) {
    _subscription = (events ?? MeiliCar.events).listen(_onEvent);
  }

  late final StreamSubscription<MeiliCarEvent> _subscription;
  final List<EventRecord> _records = <EventRecord>[];
  int _nextId = 0;

  /// The received events, newest first. Immutable snapshot.
  List<EventRecord> get records => List<EventRecord>.unmodifiable(_records);

  void _onEvent(MeiliCarEvent event) {
    _records.insert(0, (id: _nextId++, event: event));
    notifyListeners();
  }

  /// Clears the received events.
  void clear() {
    _records.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
