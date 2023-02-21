import 'package:flutter_home_connect_sdk/src/models/payloads/option_constraints.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_options.g.dart';

@JsonSerializable()
class DeviceOptions {
  final String key;
  String? type = '';
  String? unit = '';
  dynamic value;
  OptionConstraints? constraints = OptionConstraints();

  DeviceOptions(this.key, this.type, this.unit, this.value, this.constraints);

  // factory DeviceOptions.fromPayload(Map<String, dynamic> payload) {
  //   return DeviceOptions(payload['key'], payload['type'], payload['unit'],
  //       DeviceConstrains.fromPayload(payload['constraints']));
  // }
  Map<String, dynamic> toJson() => _$DeviceOptionsToJson(this);

  factory DeviceOptions.fromJson(Map<String, dynamic> json) => DeviceOptions(
        json['key'] as String,
        json['type'] ??= '',
        json['unit'] ??= '',
        json['value'],
        json['constraints'] == null
            ? null
            : OptionConstraints.fromJson(
                json['constraints'] as Map<String, dynamic>),
      );

  /// Creates a [DeviceOptions] object from a [key] and [value].
  factory DeviceOptions.toCommandPayload(
      {required String key, required dynamic value}) {
    return DeviceOptions(key, null, null, value, null);
  }
}
