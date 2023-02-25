import 'dart:async';
import 'dart:convert';

import 'package:eventsource/eventsource.dart';
import 'package:flutter_home_connect_sdk/src/client/client_dart.dart';
import 'package:flutter_home_connect_sdk/src/models/home_device.dart';

import 'package:flutter_home_connect_sdk/src/models/settings/settings_enums.dart';
import 'package:flutter_home_connect_sdk/src/models/event/device_event.dart';
import 'package:flutter_home_connect_sdk/src/models/info/device_info.dart';
import 'package:flutter_home_connect_sdk/src/models/options/program_options.dart';
import 'package:flutter_home_connect_sdk/src/models/programs/device_program.dart';
import 'package:flutter_home_connect_sdk/src/models/settings/device_setting.dart';
import 'package:flutter_home_connect_sdk/src/models/status/device_status.dart';

class DeviceOven extends HomeDevice {
  DeviceOven(HomeConnectApi api, DeviceInfo info, List<ProgramOptions> options, List<DeviceStatus> status,
      List<DeviceProgram> programs, List<DeviceSetting> settings)
      : super(api, info, status, programs, settings);

  factory DeviceOven.fromPayload(HomeConnectApi api, DeviceInfo info, List<ProgramOptions> options,
      List<DeviceStatus> stats, List<DeviceProgram> programs, List<DeviceSetting> settings) {
    return DeviceOven(api, info, options, stats, programs, settings);
  }

  factory DeviceOven.fromInfoPayload(HomeConnectApi api, DeviceInfo info) {
    return DeviceOven(api, info, [], [], [], []);
  }

  Map<String, dynamic> toPowerPayload(String key, dynamic value) {
    return {
      "data": {"key": key, "value": value}
    };
  }

  void updateStatus(DeviceStatus stats) {
    status.removeWhere((element) => element.key == stats.key);
    status.add(stats);
  }

  @override
  Future<List<DeviceProgram>> getPrograms() async {
    try {
      programs = await api.getPrograms(haId: info.haId);
      return programs;
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  @override
  Future<void> selectProgram({required String programKey}) async {
    try {
      await api.selectProgram(haId: info.haId, programKey: programKey);
      List<ProgramOptions> options = await api.getSelectedProgramOptions(haId: info.haId);
      selectedProgram = DeviceProgram(programKey, options);
      final constraints = await api.getProgramOptions(haId: info.haId, programKey: programKey);
      for (var option in options) {
        for (var constraint in constraints) {
          if (option.key == constraint.key) {
            option.constraints = constraint.constraints;
          }
        }
      }
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  /// Sets the [OvenSettings.power] enum to `off`
  @override
  void turnOff() {
    final key = settingsMap[OvenSettings.power];
    final value = validValuesMap[OvenSettings.power]?['off'];
    final payload = toPowerPayload(key!, value!);

    api.putPowerState(deviceHaId, key, payload);
  }

  /// Sets the [OvenSettings.power] enum to `on`
  @override
  void turnOn() {
    final key = settingsMap[OvenSettings.power];
    final value = validValuesMap[OvenSettings.power]?['on'];
    final payload = toPowerPayload(key!, value!);
    api.putPowerState(deviceHaId, key, payload);
  }

  @override
  void updateStatusFromEvent(Event event) {
    Map<String, dynamic> eventMap = json.decode(event.data!);
    List<dynamic> list = eventMap['items'];
    DeviceEvent deviceEvent = DeviceEvent.fromJson(list[0]);

    for (var stat in status) {
      if (stat.key == deviceEvent.key) {
        stat.value = deviceEvent.value;
      }
    }
  }

  @override
  void startProgram({String? programKey, required List<ProgramOptions> options}) {
    programKey ??= selectedProgram.key;
    if (programKey.isEmpty) {
      throw Exception("No program selected");
    }
    try {
      api.startProgram(haid: info.haId, programKey: programKey, options: options);
    } catch (e) {
      throw Exception("Something went wrong: $e, $options, $programKey");
    }
  }

  @override
  void stopProgram() {
    try {
      api.stopProgram(haid: info.haId);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }
}
