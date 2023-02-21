// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceProgram _$DeviceProgramFromJson(Map<String, dynamic> json) =>
    DeviceProgram(
      json['key'] as String,
      (json['options'] as List<dynamic>)
          .map((e) => DeviceOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeviceProgramToJson(DeviceProgram instance) =>
    <String, dynamic>{
      'key': instance.key,
      'options': instance.options,
    };
