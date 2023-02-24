import 'package:flutter_home_connect_sdk/src/models/constraints/option_constraints.dart';
import 'package:json_annotation/json_annotation.dart';

part 'program_options.g.dart';

@JsonSerializable()
class ProgramOptions {
  final String key;
  String? type = '';
  String? unit = '';
  dynamic value;
  OptionConstraints? constraints = OptionConstraints();

  ProgramOptions(this.key, this.type, this.unit, this.value, this.constraints);

  Map<String, dynamic> toJson() => _$ProgramOptionsToJson(this);

  factory ProgramOptions.fromJson(Map<String, dynamic> json) => ProgramOptions(
        json['key'] as String,
        json['type'] ??= '',
        json['unit'] ??= '',
        json['value'],
        json['constraints'] == null ? null : OptionConstraints.fromJson(json['constraints'] as Map<String, dynamic>),
      );

  /// Creates a [ProgramOptions] object from a [key] and [value].
  factory ProgramOptions.toCommandPayload({required String key, required dynamic value}) {
    return ProgramOptions(key, null, null, value, null);
  }
}
