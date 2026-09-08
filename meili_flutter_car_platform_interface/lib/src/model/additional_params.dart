// ignore_for_file: deprecated_member_use_from_same_package

class AdditionalParams {
  AdditionalParams({
    this.partnerLoyaltyAccount,
    this.partnerLoyaltyAccountTier,
    this.numberOfPassengers,
    this.customerPartnerCode,
    this.flightNumber,
    this.passengerNameRecord,
    this.superPassengerNameRecord,
    this.infant,
    this.child,
    this.teenager,
    this.supplierLoyaltyAccounts,
    this.fareTypeAndFlex,
    this.departureAirport,
    this.arrivalAirport,
    this.ancillaryActivity,
    this.airlineFareAmount,
    this.airlineFareCurrency,
    this.partnerCustomerID,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumbers,
    this.companyName,
    this.addressLine1,
    this.postCode,
    this.city,
    this.state,
    this.confirmationId,
    this.prefillOnly,
  });

  String? partnerLoyaltyAccount;
  String? partnerLoyaltyAccountTier;
  int? numberOfPassengers;
  String? customerPartnerCode;
  String? flightNumber;
  String? passengerNameRecord;
  String? superPassengerNameRecord;
  int? infant;
  int? child;
  int? teenager;
  List<String>? supplierLoyaltyAccounts;
  String? fareTypeAndFlex;
  String? departureAirport;
  String? arrivalAirport;
  String? ancillaryActivity;
  double? airlineFareAmount;
  String? airlineFareCurrency;
  String? partnerCustomerID;
  String? firstName;
  String? lastName;
  String? email;
  List<int>? phoneNumbers;
  String? companyName;
  String? addressLine1;
  String? postCode;
  String? city;
  String? state;
  String? confirmationId;
  bool? prefillOnly;

  Map<String, dynamic> toMap() {
    return {
      'partnerLoyaltyAccount': partnerLoyaltyAccount,
      'partnerLoyaltyAccountTier': partnerLoyaltyAccountTier,
      'numberOfPassengers': numberOfPassengers,
      'customerPartnerCode': customerPartnerCode,
      'flightNumber': flightNumber,
      'passengerNameRecord': passengerNameRecord,
      'superPassengerNameRecord': superPassengerNameRecord,
      'infant': infant,
      'child': child,
      'teenager': teenager,
      'supplierLoyaltyAccounts': supplierLoyaltyAccounts,
      'fareTypeAndFlex': fareTypeAndFlex,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'ancillaryActivity': ancillaryActivity,
      'airlineFareAmount': airlineFareAmount,
      'airlineFareCurrency': airlineFareCurrency,
      'partnerCustomerID': partnerCustomerID,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumbers': phoneNumbers,
      'companyName': companyName,
      'addressLine1': addressLine1,
      'postCode': postCode,
      'city': city,
      'state': state,
      'confirmationId': confirmationId,
      'prefillOnly': prefillOnly,
    };
  }
}

@Deprecated('Renamed to AdditionalParams. Will be removed in 0.4.0.')
typedef BookingParams = AdditionalParams;
