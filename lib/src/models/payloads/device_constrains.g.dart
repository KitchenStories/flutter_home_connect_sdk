// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_constrains.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceConstrains _$DeviceConstrainsFromJson(Map<String, dynamic> json) => DeviceConstrains(
      min: json['min'] as int? ?? 0,
      max: json['max'] as int? ?? 100,
      stepsize: json['stepsize'] as int? ?? 5,
    );

Map<String, dynamic> _$DeviceConstrainsToJson(DeviceConstrains instance) => <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'stepsize': instance.stepsize,
    };
