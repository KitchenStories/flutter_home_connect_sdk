import 'dart:convert';

import 'package:homeconnect/src/home_device.dart';
import 'package:homeconnect/src/models/options/program_options.dart';
import 'package:homeconnect/src/utils/utils.dart';
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

class SelectProgramPayload {
  final HomeDevice device;
  final String programKey;

  SelectProgramPayload(this.device, this.programKey);
  String get body => json.encode({
        'data': {
          'key': programKey,
        }
      });

  String get resource => "${device.deviceHaId}/programs/selected";
}

class StartProgramPayload {
  final HomeDevice device;
  final List<ProgramOptions> options;

  StartProgramPayload(this.device, this.options);
  String get body => json.encode({
        'data': {
          'key': device.selectedProgram?.key,
          'options': options.map((e) => compact(e.toJson())).toList(),
        }
      });

  String get resource => "${device.deviceHaId}/programs/active";
}

class ProgramListPayload {
  final List<DeviceProgram> programs;

  ProgramListPayload(this.programs);
  factory ProgramListPayload.fromJson(Map<String, dynamic> json) {
    var programs = json['data']['programs'] as List;
    return ProgramListPayload(programs.map((e) => DeviceProgram.fromJson(e as Map<String, dynamic>)).toList());
  }
}
