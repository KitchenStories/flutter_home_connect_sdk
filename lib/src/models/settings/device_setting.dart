import 'package:flutter_home_connect_sdk/src/models/settings/constraints/setting_constraints.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_setting.g.dart';

@JsonSerializable()
class DeviceSetting {
  final String key;
  final dynamic value;

  late SettingsConstraints constraints;

  DeviceSetting({required this.key, required this.value});

  Map<String, dynamic> toJson() => _$DeviceSettingToJson(this);

  factory DeviceSetting.fromJson(Map<String, dynamic> json) => _$DeviceSettingFromJson(json);
}
