// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceSetting _$DeviceSettingFromJson(Map<String, dynamic> json) =>
    DeviceSetting(
      key: json['key'] as String,
      value: json['value'],
    )..constraints = SettingsConstraints.fromJson(
        json['constraints'] as Map<String, dynamic>);

Map<String, dynamic> _$DeviceSettingToJson(DeviceSetting instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'constraints': instance.constraints,
    };
