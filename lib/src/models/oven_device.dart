import 'package:flutter_home_connect_sdk/src/client_dart.dart';
import 'package:flutter_home_connect_sdk/src/home_device.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_info.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_options.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_settings.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_status.dart';

class DeviceOven extends HomeDevice {
  DeviceOven(HomeConnectApi api, DeviceInfo info, List<DeviceOptions> options,
      List<DeviceStatus> status)
      : super(api, info, options, status);

  factory DeviceOven.fromPayload(HomeConnectApi api, Map<String, dynamic> info,
      Map<String, dynamic> opJson, Map<String, dynamic> stats) {
    DeviceType deviceType = deviceTypeMap[info['type']]!;
    DeviceInfo dInfo = DeviceInfo.fromPayload(info, deviceType);
    List<DeviceOptions> options = (opJson['options'] as List)
        .map((option) => DeviceOptions.fromPayload(option))
        .toList();
    List<DeviceStatus> statList = (stats['status'] as List)
        .map((stat) => DeviceStatus.fromPayload(stat))
        .toList();
    return DeviceOven(api, dInfo, options, statList);
  }

  Map<String, dynamic> toPowerPayload(String key, dynamic value) {
    return {
      "data": {"key": key, "value": value}
    };
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
}
