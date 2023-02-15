import 'package:flutter_home_connect_sdk/src/models/payloads/device_constrains.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_options.g.dart';

@JsonSerializable()
class DeviceOptions {
  final String key;
  final String type;
  final String unit;
  final DeviceConstrains constraints;

  DeviceOptions(this.key, this.type, this.unit, this.constraints);

  factory DeviceOptions.fromPayload(Map<String, dynamic> payload) {
    return DeviceOptions(
        payload['key'], payload['type'], payload['unit'], DeviceConstrains.fromPayload(payload['constraints']));
  }
  Map<String, dynamic> toJson() => _$DeviceOptionsToJson(this);
}
