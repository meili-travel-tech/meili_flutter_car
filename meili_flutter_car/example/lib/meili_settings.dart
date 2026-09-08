import 'package:meili_flutter/meili_flutter.dart';

/// The API environment the sample app points the SDK at.
///
/// Mirrors the iOS Sample App's environment picker. [wireValue] is the raw
/// string passed to [MeiliParams.env]; [label] is what the picker shows.
enum MeiliEnv {
  dev('dev', 'Dev'),
  uat('uat', 'UAT'),
  preProd('preProd', 'Pre-Prod'),
  prod('prod', 'Prod');

  const MeiliEnv(this.wireValue, this.label);

  /// The value sent to the native SDK via [MeiliParams.env].
  final String wireValue;

  /// The human-readable label shown in the picker.
  final String label;

  /// Resolves a persisted [wireValue] back to an enum, defaulting to [dev].
  static MeiliEnv fromWire(String? value) => MeiliEnv.values.firstWhere(
        (env) => env.wireValue == value,
        orElse: () => MeiliEnv.dev,
      );
}

/// Immutable snapshot of every launch setting a tester can configure.
///
/// Defaults match the iOS Sample App (`SettingsViewModel`) so the two sample
/// apps behave the same out of the box.
class MeiliSettings {
  /// Creates a settings snapshot. All fields default to the iOS values.
  const MeiliSettings({
    this.ptid = '100.9',
    this.env = MeiliEnv.dev,
    this.flow = FlowType.direct,
    this.overrideCurrency = false,
    this.currency = 'EUR',
    this.confirmationId = '',
    this.lastName = '',
    this.prefillOnly = false,
    this.showBookingToast = false,
  });

  /// Rebuilds a snapshot from its [toJson] representation.
  factory MeiliSettings.fromJson(Map<String, dynamic> json) => MeiliSettings(
        ptid: json['ptid'] as String? ?? '100.9',
        env: MeiliEnv.fromWire(json['env'] as String?),
        flow: json['flow'] == 'bookingManager'
            ? FlowType.bookingManager
            : FlowType.direct,
        overrideCurrency: json['overrideCurrency'] as bool? ?? false,
        currency: json['currency'] as String? ?? 'EUR',
        confirmationId: json['confirmationId'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        prefillOnly: json['prefillOnly'] as bool? ?? false,
        showBookingToast: json['showBookingToast'] as bool? ?? false,
      );

  /// Partner / touchpoint id passed to [MeiliParams.ptid].
  final String ptid;

  /// Selected API environment.
  final MeiliEnv env;

  /// Selected booking flow.
  final FlowType flow;

  /// Whether to send a currency override via [AvailParams].
  final bool overrideCurrency;

  /// Currency code used when [overrideCurrency] is on.
  final String currency;

  /// Booking confirmation id for the Booking Manager flow.
  final String confirmationId;

  /// Customer last name for the Booking Manager flow.
  final String lastName;

  /// Whether the booking form should only be prefilled.
  final bool prefillOnly;

  /// Whether to show a toast when a booking flow ends.
  final bool showBookingToast;

  /// Returns a copy with the provided fields replaced.
  MeiliSettings copyWith({
    String? ptid,
    MeiliEnv? env,
    FlowType? flow,
    bool? overrideCurrency,
    String? currency,
    String? confirmationId,
    String? lastName,
    bool? prefillOnly,
    bool? showBookingToast,
  }) {
    return MeiliSettings(
      ptid: ptid ?? this.ptid,
      env: env ?? this.env,
      flow: flow ?? this.flow,
      overrideCurrency: overrideCurrency ?? this.overrideCurrency,
      currency: currency ?? this.currency,
      confirmationId: confirmationId ?? this.confirmationId,
      lastName: lastName ?? this.lastName,
      prefillOnly: prefillOnly ?? this.prefillOnly,
      showBookingToast: showBookingToast ?? this.showBookingToast,
    );
  }

  /// Serializes the settings for persistence.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'ptid': ptid,
        'env': env.wireValue,
        'flow': flow.name,
        'overrideCurrency': overrideCurrency,
        'currency': currency,
        'confirmationId': confirmationId,
        'lastName': lastName,
        'prefillOnly': prefillOnly,
        'showBookingToast': showBookingToast,
      };

  /// Builds the [MeiliParams] used to launch the SDK from these settings.
  MeiliParams toMeiliParams() {
    return MeiliParams(
      ptid: ptid,
      flow: flow,
      env: env.wireValue,
      availParams: overrideCurrency ? _currencyOnlyAvailParams() : null,
      additionalParams: _additionalParams(),
    );
  }

  /// Booking-manager params, or null when nothing meaningful is set.
  AdditionalParams? _additionalParams() {
    final hasConfirmation = confirmationId.isNotEmpty;
    final hasLastName = lastName.isNotEmpty;
    if (!hasConfirmation && !hasLastName && !prefillOnly) {
      return null;
    }
    return AdditionalParams(
      confirmationId: hasConfirmation ? confirmationId : null,
      lastName: hasLastName ? lastName : null,
      prefillOnly: prefillOnly,
    );
  }

  AvailParams _currencyOnlyAvailParams() => AvailParams(currencyCode: currency);
}
