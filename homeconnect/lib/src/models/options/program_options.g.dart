// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgramOptions _$ProgramOptionsFromJson(Map<String, dynamic> json) =>
    ProgramOptions(
      json['key'] as String,
      json['type'] as String?,
      json['unit'] as String?,
      json['value'],
      json['constraints'] == null
          ? null
          : OptionConstraints.fromJson(
              json['constraints'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProgramOptionsToJson(ProgramOptions instance) =>
    <String, dynamic>{
      'key': instance.key,
      'type': instance.type,
      'unit': instance.unit,
      'value': instance.value,
      'constraints': instance.constraints,
    };
