// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => DeviceInfo(
      json['name'] as String,
      json['brand'] as String,
      json['vib'] as String,
      json['connected'] as bool,
      $enumDecode(_$DeviceTypeEnumMap, json['type']),
      json['enumber'] as String,
      json['haId'] as String,
    );

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'brand': instance.brand,
      'vib': instance.vib,
      'connected': instance.connected,
      'type': _$DeviceTypeEnumMap[instance.type]!,
      'enumber': instance.enumber,
      'haId': instance.haId,
    };

const _$DeviceTypeEnumMap = {
  DeviceType.oven: 'oven',
  DeviceType.coffeeMaker: 'coffeeMaker',
  DeviceType.dryer: 'dryer',
  DeviceType.washer: 'washer',
  DeviceType.fridgeFreezer: 'fridgeFreezer',
  DeviceType.dishWasher: 'dishWasher',
};
