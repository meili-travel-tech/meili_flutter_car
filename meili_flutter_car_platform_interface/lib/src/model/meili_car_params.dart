import 'additional_params.dart';
import 'avail_params.dart';
import 'flow_enum.dart';

/// Represents the parameters required to open the MeiliCar view.
class MeiliCarParams {
  /// Creates an instance of [MeiliCarParams].
  MeiliCarParams({
    required this.ptid,
    required this.flow,
    required this.env,
    this.availParams,
    this.additionalParams,
  });

  /// The ptid (possibly partner ID) for the MeiliCar view.
  final String ptid;

  /// The current flow type for the MeiliCar view.
  final FlowType flow;

  /// The environment for the MeiliCar view (e.g., dev, prod).
  final String env;

  /// The availability parameters for the MeiliCar view.
  final AvailParams? availParams;

  /// The booking parameters for the MeiliCar view.
  final AdditionalParams? additionalParams;

  /// Converts the [MeiliCarParams] instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'ptid': ptid,
      'flow': flow.toString().split('.').last,
      'env': env,
      'availParams': availParams?.toMap(),
      'additionalParams': additionalParams?.toMap(),
    };
  }
}
