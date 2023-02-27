import 'dart:convert';

import 'package:eventsource/eventsource.dart';
import 'package:homeconnect/src/client_dart.dart';
import 'package:homeconnect/src/home_device.dart';
import 'package:homeconnect/src/models/payloads/device_event.dart';
import 'package:homeconnect/src/models/payloads/device_info.dart';
import 'package:homeconnect/src/models/payloads/device_options.dart';
import 'package:homeconnect/src/models/payloads/device_program.dart';
import 'package:homeconnect/src/models/payloads/device_settings.dart';
import 'package:homeconnect/src/models/payloads/device_status.dart';

class DeviceOven extends HomeDevice {
  DeviceOven(HomeConnectApi api, DeviceInfo info, List<DeviceOptions> options,
      List<DeviceStatus> status, List<DeviceProgram> programs)
      : super(api, info, options, status, programs);

  factory DeviceOven.fromPayload(
      HomeConnectApi api,
      DeviceInfo info,
      List<DeviceOptions> options,
      List<DeviceStatus> stats,
      List<DeviceProgram> programs) {
    return DeviceOven(api, info, options, stats, programs);
  }

  factory DeviceOven.fromInfoPayload(HomeConnectApi api, DeviceInfo info) {
    return DeviceOven(api, info, [], [], []);
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
      await api.selectProgram(haid: info.haId, programKey: programKey);
      options = await api.getSelectedProgramOptions(haId: info.haId);
      selectedProgram = DeviceProgram(programKey, options);
      final constraints =
          await api.getProgramOptions(haId: info.haId, programKey: programKey);
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
  Future<void> startProgram(
      {String? programKey, required List<DeviceOptions> options}) async {
    programKey ??= selectedProgram.key;
    if (programKey.isEmpty) {
      throw Exception("No program selected");
    }
    try {
      print(api);
      await api.startProgram(
          haid: info.haId, programKey: programKey, options: options);
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
