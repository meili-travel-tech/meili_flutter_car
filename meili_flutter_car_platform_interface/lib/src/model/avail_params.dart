/// Search criteria to prefill the MeiliCar Direct flow. Every field is optional;
/// anything left out keeps the funnel's own default.
class AvailParams {
  AvailParams({
    this.pickupLocation,
    this.dropoffLocation,
    this.pickupDate,
    this.pickupTime,
    this.dropoffDate,
    this.dropoffTime,
    this.driverAge,
    this.currencyCode,
    this.residency,
    this.pickupDateTime,
    this.dropoffDateTime,
    this.discountRequested,
    this.partnerLoyaltyAccountTier,
  });

  final String? pickupLocation;
  final String? dropoffLocation;
  final String? pickupDate;
  final String? pickupTime;
  final String? dropoffDate;
  final String? dropoffTime;
  final DateTime? pickupDateTime;
  final DateTime? dropoffDateTime;
  final int? driverAge;
  final String? currencyCode;
  final String? residency;

  /// Pre-ticks the partner discount checkbox on the search panel, when the
  /// partner has one configured.
  final bool? discountRequested;

  /// Pre-ticks the partner loyalty card checkbox on the search panel, when the
  /// partner declares a single loyalty tier. Pass the tier value itself, for
  /// example `CARD`.
  final String? partnerLoyaltyAccountTier;

  Map<String, dynamic> toMap() {
    return {
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'pickupDate': pickupDate,
      'pickupTime': pickupTime,
      'dropoffDate': dropoffDate,
      'dropoffTime': dropoffTime,
      'pickupDateTime': pickupDateTime?.toIso8601String(),
      'dropoffDateTime': dropoffDateTime?.toIso8601String(),
      'driverAge': driverAge,
      'currencyCode': currencyCode,
      'residency': residency,
      'discountRequested': discountRequested,
      'partnerLoyaltyAccountTier': partnerLoyaltyAccountTier,
    };
  }
}
