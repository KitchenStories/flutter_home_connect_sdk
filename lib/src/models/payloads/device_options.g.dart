// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceOptions _$DeviceOptionsFromJson(Map<String, dynamic> json) =>
    DeviceOptions(
      json['key'] as String,
      json['type'] as String?,
      json['unit'] as String?,
      json['value'] as String?,
      json['constraints'] == null
          ? null
          : DeviceConstrains.fromJson(
              json['constraints'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeviceOptionsToJson(DeviceOptions instance) =>
    <String, dynamic>{
      'key': instance.key,
      'type': instance.type,
      'unit': instance.unit,
      'value': instance.value,
      'constraints': instance.constraints,
    };
