import 'package:json_annotation/json_annotation.dart';

part 'device_status.g.dart';

@JsonSerializable()
class DeviceStatus {
  final String key;
  dynamic value;

  DeviceStatus(this.key, dynamic value);

  Map<String, dynamic> toJson() => _$DeviceStatusToJson(this);

  factory DeviceStatus.fromJson(Map<String, dynamic> json) => _$DeviceStatusFromJson(json);
}
