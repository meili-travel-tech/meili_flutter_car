import 'package:flutter_test/flutter_test.dart';
import 'package:meili_flutter_car_platform_interface/meili_flutter_car_platform_interface.dart';

void main() {
  test('a currency-only AvailParams sends null for everything else', () {
    final map = AvailParams(currencyCode: 'EUR').toMap();

    expect(map['currencyCode'], 'EUR');
    for (final key in [
      'pickupLocation',
      'dropoffLocation',
      'pickupDate',
      'pickupTime',
      'dropoffDate',
      'dropoffTime',
      'driverAge',
      'residency',
      'pickupDateTime',
      'dropoffDateTime',
      'discountRequested',
      'partnerLoyaltyAccountTier',
    ]) {
      expect(map[key], isNull, reason: key);
    }
  });

  test('every field is carried when supplied', () {
    final map = AvailParams(
      pickupLocation: 'DUB',
      dropoffLocation: 'DUB',
      pickupDate: '2026-10-05',
      pickupTime: '10:00',
      dropoffDate: '2026-10-09',
      dropoffTime: '10:00',
      driverAge: 30,
      currencyCode: 'EUR',
      residency: 'IE',
      pickupDateTime: DateTime.utc(2026, 10, 5, 10),
    ).toMap();

    expect(map['pickupLocation'], 'DUB');
    expect(map['driverAge'], 30);
    expect(map['residency'], 'IE');
    expect(map['pickupDateTime'], '2026-10-05T10:00:00.000Z');
    expect(map['dropoffDateTime'], isNull);
  });

  test('the loyalty prefill fields are carried when supplied', () {
    final map = AvailParams(
      discountRequested: true,
      partnerLoyaltyAccountTier: 'CARD',
    ).toMap();

    expect(map['discountRequested'], isTrue);
    expect(map['partnerLoyaltyAccountTier'], 'CARD');
  });

  test('discountRequested: false is carried, not dropped as if unset', () {
    final map = AvailParams(discountRequested: false).toMap();

    expect(map['discountRequested'], isFalse);
  });
}
