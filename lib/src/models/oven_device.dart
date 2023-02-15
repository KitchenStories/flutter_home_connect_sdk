import 'dart:convert';

import 'package:eventsource/eventsource.dart';
import 'package:flutter_home_connect_sdk/src/client_dart.dart';
import 'package:flutter_home_connect_sdk/src/home_device.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_event.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_info.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_options.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_program.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_settings.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_status.dart';

class DeviceOven extends HomeDevice {
  DeviceOven(HomeConnectApi api, DeviceInfo info, List<DeviceOptions> options,
      List<DeviceStatus> status, List<DeviceProgram> programs)
      : super(api, info, options, status, programs);

  factory DeviceOven.fromPayload(
      HomeConnectApi api,
      Map<String, dynamic> info,
      Map<String, dynamic> opJson,
      Map<String, dynamic> stats,
      Map<String, dynamic> programs) {
    DeviceType deviceType = deviceTypeMap[info['type']]!;
    DeviceInfo dInfo = DeviceInfo.fromPayload(info, deviceType);
    List<DeviceOptions> options = (opJson['options'] as List)
        .map((option) => DeviceOptions.fromPayload(option))
        .toList();
    List<DeviceStatus> statList = (stats['status'] as List)
        .map((stat) => DeviceStatus.fromPayload(stat))
        .toList();
    List<DeviceProgram> prList = (programs['programs'] as List)
        .map((program) => DeviceProgram.fromPayload(program))
        .toList();
    return DeviceOven(api, dInfo, options, statList, prList);
  }

  factory DeviceOven.fromInfoPayload(HomeConnectApi api, DeviceInfo info) {
    return DeviceOven(api, info, [], [], []);
  }

  Map<String, dynamic> toPowerPayload(String key, dynamic value) {
    return {
      "data": {"key": key, "value": value}
    };
  }

  void updateStatus(Map<String, dynamic> stats) {
    List<DeviceStatus> statList = (stats['status'] as List)
        .map((stat) => DeviceStatus.fromPayload(stat))
        .toList();
    status = statList;
  }

  @override
  Map<String, dynamic> getStatus() {
    Map<String, dynamic> response = {};
    for (var stat in status) {
      response.addAll({
        stat.key: stat.value,
      });
    }
    return response;
  }

  @override
  Map<String, dynamic> showOptions() {
    Map<String, dynamic> response = {};
    for (var option in options) {
      response.addAll({
        option.key: option.constraints.toPayload(),
      });
    }
    return response;
  }

  @override
  void turnOff() {
    final key = settingsMap[OvenSettings.power];
    final value = validValuesMap[OvenSettings.power]?['off'];
    final payload = toPowerPayload(key!, value!);

    api.putPowerState(deviceHaId, key, payload);
  }

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
    DeviceEvent deviceEvent = DeviceEvent.fromPayload(list[0]);

    for (var stat in status) {
      if (stat.key == deviceEvent.key) {
        stat.value = deviceEvent.value;
      }
    }
  }

  @override
  void startProgram(
      {required String haid,
      required String programKey,
      required Map<String, int> options}) {
    api.startProgram(haid: haid, programKey: programKey, options: options);
  }
}
