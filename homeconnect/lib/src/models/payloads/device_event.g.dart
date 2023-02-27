// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceEvent _$DeviceEventFromJson(Map<String, dynamic> json) => DeviceEvent(
      json['level'] as String,
      json['handling'] as String,
      json['key'] as String,
      json['value'] as String,
      json['uri'] as String,
    );

Map<String, dynamic> _$DeviceEventToJson(DeviceEvent instance) =>
    <String, dynamic>{
      'level': instance.level,
      'handling': instance.handling,
      'key': instance.key,
      'value': instance.value,
      'uri': instance.uri,
    };
