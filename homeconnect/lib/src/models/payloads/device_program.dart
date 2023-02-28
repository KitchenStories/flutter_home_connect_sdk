import 'package:homeconnect/homeconnect.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_program.g.dart';

@JsonSerializable()
class DeviceProgram {
  final String key;
  List<DeviceOptions> options;

  DeviceProgram(this.key, this.options);

  Map<String, dynamic> toJson() => _$DeviceProgramToJson(this);

  factory DeviceProgram.fromJson(Map<String, dynamic> json) =>
      DeviceProgram(json['key'] as String, []);
}
