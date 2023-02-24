import 'package:flutter_home_connect_sdk/src/models/options/program_options.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_program.g.dart';

@JsonSerializable()
class DeviceProgram {
  final String key;
  List<ProgramOptions> options;

  DeviceProgram(this.key, this.options);

  Map<String, dynamic> toJson() => _$DeviceProgramToJson(this);

  factory DeviceProgram.fromJson(Map<String, dynamic> json) => DeviceProgram(json['key'] as String, []);
}
