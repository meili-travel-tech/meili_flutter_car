package com.flutter.meili

import com.meili.travel.api.AdditionalParams
import com.meili.travel.api.AvailParams
import com.meili.travel.api.DevelopmentEnvironment
import com.meili.travel.api.MeiliEnvironment
import com.meili.travel.api.MeiliFlow
import com.meili.travel.api.PreProductionEnvironment
import com.meili.travel.api.ProductionEnvironment
import com.meili.travel.api.UatEnvironment

internal fun parseEnv(envName: String?): MeiliEnvironment = when (envName?.lowercase()) {
    "prod", "production" -> ProductionEnvironment()
    "pre_prod", "preprod" -> PreProductionEnvironment()
    "uat" -> UatEnvironment()
    else -> DevelopmentEnvironment()
}

internal fun parseFlow(flowName: String?): MeiliFlow = when (flowName?.lowercase()) {
    "bookingmanager" -> MeiliFlow.BookingManager
    else -> MeiliFlow.Direct
}

internal fun parseAvailParams(map: Map<*, *>?): AvailParams? {
    map ?: return null
    return AvailParams(
        pickupLocation = map["pickupLocation"] as? String,
        dropoffLocation = map["dropoffLocation"] as? String,
        pickupDate = map["pickupDate"] as? String,
        pickupTime = map["pickupTime"] as? String,
        dropoffDate = map["dropoffDate"] as? String,
        dropoffTime = map["dropoffTime"] as? String,
        driverAge = (map["driverAge"] as? Number)?.toInt(),
        currencyCode = map["currencyCode"] as? String,
        residency = map["residency"] as? String,
        discountRequested = map["discountRequested"] as? Boolean,
        partnerLoyaltyAccountTier = map["partnerLoyaltyAccountTier"] as? String,
    )
}

@Suppress("UNCHECKED_CAST")
internal fun parseAdditionalParams(map: Map<*, *>?): AdditionalParams? {
    map ?: return null
    val supplierAccounts = map["supplierLoyaltyAccounts"] as? List<*>
    return AdditionalParams(
        passengerNameRecord = map["passengerNameRecord"] as? String,
        partnerLoyaltyAccount = map["partnerLoyaltyAccount"] as? String,
        partnerLoyaltyAccountTier = map["partnerLoyaltyAccountTier"] as? String,
        numberOfPassengers = (map["numberOfPassengers"] as? Number)?.toInt(),
        customerPartnerCode = map["customerPartnerCode"] as? String,
        flightNumber = map["flightNumber"] as? String,
        superPassengerNameRecord = map["superPassengerNameRecord"] as? String,
        infant = (map["infant"] as? Number)?.toInt(),
        child = (map["child"] as? Number)?.toInt(),
        teenager = (map["teenager"] as? Number)?.toInt(),
        supplierLoyaltyAccount = supplierAccounts?.firstOrNull()?.toString(),
        fareTypeAndFlex = map["fareTypeAndFlex"] as? String,
        departureAirport = map["departureAirport"] as? String,
        arrivalAirport = map["arrivalAirport"] as? String,
        ancillaryActivity = map["ancillaryActivity"] as? String,
        airlineFareAmount = (map["airlineFareAmount"] as? Number)?.toDouble(),
        airlineFareCurrency = map["airlineFareCurrency"] as? String,
        partnerCustomerID = map["partnerCustomerID"] as? String,
        firstName = map["firstName"] as? String,
        lastName = map["lastName"] as? String,
        email = map["email"] as? String,
        phoneNumbers = (map["phoneNumbers"] as? List<*>)?.map { it.toString() },
        companyName = map["companyName"] as? String,
        addressLine1 = map["addressLine1"] as? String,
        postCode = map["postCode"] as? String,
        city = map["city"] as? String,
        state = map["state"] as? String,
        confirmationId = map["confirmationId"] as? String,
        prefillOnly = map["prefillOnly"] as? Boolean,
        givenName = map["givenName"] as? String,
    )
}
