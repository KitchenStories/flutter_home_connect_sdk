import 'package:homeconnect/homeconnect.dart';
import 'package:json_annotation/json_annotation.dart';

part 'program_options.g.dart';

@JsonSerializable()
class ProgramOptions implements DeviceData {
  @override
  final String key;
  String? type = '';
  String? unit = '';
  @override
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

class ProgramOptionsListPayload {
  final List<ProgramOptions> options;

  ProgramOptionsListPayload(this.options);
  factory ProgramOptionsListPayload.fromJson(Map<String, dynamic> json) {
    var options = json['data']['options'] as List;
    return ProgramOptionsListPayload(options.map((e) => ProgramOptions.fromJson(e as Map<String, dynamic>)).toList());
  }
}
