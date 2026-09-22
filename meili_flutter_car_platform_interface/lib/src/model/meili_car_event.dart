import 'package:flutter/foundation.dart';

/// Events emitted by the native MeiliCar SDK and surfaced to Dart through
/// `MeiliCarFlutterPlatform.events`.
///
/// This is a sealed hierarchy, so consumers can exhaustively handle every
/// variant with a `switch` expression:
///
/// ```dart
/// MeiliCar.events.listen((event) {
///   switch (event) {
///     case MeiliCarFlowDismissed():
///       // user closed the MeiliCar UI
///     case MeiliCarBookingFlowEnded():
///       // booking flow reached its end
///     case MeiliCarAnalyticsEvent(:final name):
///       // an analytics event was tracked
///     case MeiliCarUnknownEvent():
///       // a future event type; safe to ignore
///   }
/// });
/// ```
@immutable
sealed class MeiliCarEvent {
  /// Const base constructor.
  const MeiliCarEvent();

  /// Builds a [MeiliCarEvent] from a raw event map sent over the platform
  /// channel.
  ///
  /// A well-formed map with an unrecognised `type` becomes a
  /// [MeiliCarUnknownEvent] (forward-compatible) rather than throwing, so a
  /// newer native SDK emitting a new event type never breaks an older Dart
  /// consumer.
  /// A map missing a `String` `type` is malformed and throws a
  /// [FormatException].
  factory MeiliCarEvent.fromMap(Map<String, dynamic> map) {
    return switch (map) {
      {'type': 'flowDismissed'} => const MeiliCarFlowDismissed(),
      {'type': 'bookingFlowEnded'} => const MeiliCarBookingFlowEnded(),
      {'type': 'analytics', 'name': final String name} =>
        MeiliCarAnalyticsEvent(
          name: name,
          properties: _coerceProperties(map['properties']),
        ),
      {'type': final String type} => MeiliCarUnknownEvent(type: type, raw: map),
      _ => throw const FormatException(
          'Malformed MeiliCarEvent: missing or non-string "type"',
        ),
    };
  }

  /// Serialises this event back to its channel-map form. Inbound-only on the
  /// real channel path; provided for round-trip testing and symmetry.
  Map<String, dynamic> toMap();
}

Map<String, dynamic> _coerceProperties(Object? value) {
  if (value is Map) {
    return value.map((key, dynamic val) => MapEntry(key.toString(), val));
  }
  return const {};
}

/// The MeiliCar UI was dismissed (maps to the SDK's `dismissAction`).
final class MeiliCarFlowDismissed extends MeiliCarEvent {
  /// Creates a dismissed event.
  const MeiliCarFlowDismissed();

  @override
  Map<String, dynamic> toMap() => {'type': 'flowDismissed'};
}

/// The booking flow reached its end (maps to the SDK's `onEndBookingFlow`).
///
/// Informational only: the SDK has already returned to its search panel by
/// the time this event is emitted, so no host action is required.
final class MeiliCarBookingFlowEnded extends MeiliCarEvent {
  /// Creates a booking-flow-ended event.
  const MeiliCarBookingFlowEnded();

  @override
  Map<String, dynamic> toMap() => {'type': 'bookingFlowEnded'};
}

/// An analytics event tracked by the SDK (forwarded from a registered
/// analytics provider). Includes `screen_viewed` events, whose [properties]
/// carry a `screen_name`.
final class MeiliCarAnalyticsEvent extends MeiliCarEvent {
  /// Creates an analytics event with the given [name] and [properties].
  const MeiliCarAnalyticsEvent({
    required this.name,
    this.properties = const {},
  });

  /// The tracked event name (e.g. `screen_viewed`, `booking_confirmed`).
  final String name;

  /// Arbitrary event properties, forwarded verbatim from native.
  final Map<String, dynamic> properties;

  @override
  Map<String, dynamic> toMap() => {
        'type': 'analytics',
        'name': name,
        'properties': properties,
      };
}

/// A well-formed event whose `type` this version of the plugin does not yet
/// model. Lets consumers ignore or inspect future event types without the
/// stream erroring.
final class MeiliCarUnknownEvent extends MeiliCarEvent {
  /// Creates an unknown event preserving its [type] and [raw] map.
  const MeiliCarUnknownEvent({required this.type, required this.raw});

  /// The raw `type` discriminator that was not recognised.
  final String type;

  /// The full raw event map, for inspection.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toMap() => raw;
}
