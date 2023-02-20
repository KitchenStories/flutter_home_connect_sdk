// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_constraints.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionConstraints _$OptionConstraintsFromJson(Map<String, dynamic> json) =>
    OptionConstraints(
      min: json['min'] as int? ?? 0,
      max: json['max'] as int? ?? 100,
      stepsize: json['stepsize'] as int? ?? 1,
    );

Map<String, dynamic> _$OptionConstraintsToJson(OptionConstraints instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'stepsize': instance.stepsize,
    };
