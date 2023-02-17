import 'package:flutter_home_connect_sdk/src/models/payloads/device_constrains.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_options.g.dart';

@JsonSerializable()
class DeviceOptions {
  final String key;
  String? type = '';
  String? unit = '';
  String? value = '';
  DeviceConstrains? constraints = DeviceConstrains();

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
        json['value'].toString(),
        json['constraints'] == null
            ? null
            : DeviceConstrains.fromJson(
                json['constraints'] as Map<String, dynamic>),
      );
}
