import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_status.g.dart';

@JsonSerializable()
class DeviceStatus implements DeviceData {
  @override
  final String key;
  @override
  dynamic value;

  DeviceStatus(this.key, this.value);

  Map<String, dynamic> toJson() => _$DeviceStatusToJson(this);

  factory DeviceStatus.fromJson(Map<String, dynamic> json) => _$DeviceStatusFromJson(json);
}
