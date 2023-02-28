import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';
import 'package:flutter_home_connect_sdk/src/models/settings/constraints/setting_constraints.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_setting.g.dart';

@JsonSerializable()
class DeviceSetting implements DeviceData {
  @override
  final String key;
  @override
  dynamic value;

  late SettingsConstraints constraints;

  DeviceSetting({required this.key, required this.value});

  Map<String, dynamic> toJson() => _$DeviceSettingToJson(this);

  factory DeviceSetting.fromJson(Map<String, dynamic> json) {
    var key = json['key'] as String;
    var value = json['value'];
    return DeviceSetting(key: key, value: value);
  }
}
