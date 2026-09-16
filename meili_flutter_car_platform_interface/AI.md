# meili_flutter_car_platform_interface AI Notes

Purpose: Platform interface package for the federated `meili_flutter_car` plugin.

Notes
- Both `meili_flutter_car_ios` and `meili_flutter_car_android` contribute native code only; the
  default `MethodChannelMeiliCarFlutter` implementation here (channel `meili_flutter_car`, event
  channel `meili_flutter_car/events`) is shared by both platforms.
- Models: `MeiliCarParams`, `AvailParams`, `AdditionalParams` (`BookingParams` is a deprecated
  alias), `FlowType`, `MeiliCarEvent` and its subclasses.
