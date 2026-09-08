import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meili_flutter/meili_flutter.dart';

/// A single received event tagged with a stable id (for list keys).
typedef EventRecord = ({int id, MeiliEvent event});

/// Subscribes to [Meili.events] and exposes the received events as immutable
/// state for the UI (MVVM, per the project's Flutter architecture skill).
class EventsViewModel extends ChangeNotifier {
  /// Creates the view model and begins listening.
  ///
  /// [events] is injectable for testing; it defaults to [Meili.events].
  EventsViewModel({Stream<MeiliEvent>? events}) {
    _subscription = (events ?? Meili.events).listen(_onEvent);
  }

  late final StreamSubscription<MeiliEvent> _subscription;
  final List<EventRecord> _records = <EventRecord>[];
  int _nextId = 0;

  /// The received events, newest first. Immutable snapshot.
  List<EventRecord> get records => List<EventRecord>.unmodifiable(_records);

  void _onEvent(MeiliEvent event) {
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
