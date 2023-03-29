import 'dart:async';

import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect/src/models/devices/device_exceptions.dart';
import 'package:homeconnect/src/models/devices/oven_enums.dart';
import 'package:homeconnect/src/models/settings/device_setting.dart';

class DeviceOven extends HomeDevice {
  DeviceOven(HomeConnectApi api, DeviceInfo info, List<ProgramOptions> options,
      List<DeviceStatus> status, List<DeviceProgram> programs, List<DeviceSetting> settings)
      : super(api, info, status, programs, settings);

  factory DeviceOven.fromPayload(HomeConnectApi api, DeviceInfo info, List<ProgramOptions> options,
      List<DeviceStatus> stats, List<DeviceProgram> programs, List<DeviceSetting> settings) {
    return DeviceOven(api, info, options, stats, programs, settings);
  }

  factory DeviceOven.fromInfoPayload(HomeConnectApi api, DeviceInfo info) {
    return DeviceOven(api, info, [], [], [], []);
  }

  /// Sets the [OvenSettings.power] enum to `off`
  @override
  void turnOff() {
    _setPower("off");
  }

  /// Sets the [OvenSettings.power] enum to `on`
  @override
  void turnOn() {
    _setPower("on");
  }

  void _setPower(String state) {
    print(state);
    final programKey = settingsMap[OvenSettings.power];
    final value = powerStateMap[OvenSettingsEnums.power]![state];
    final payload = SetSettingsPayload(deviceHaId, programKey!, value);
    api.put(resource: payload.resource, body: payload.body);
  }

  Future<void> setTemperature({required int temperature}) async {
    final programKey = ovenOptionsMap[OvenOptionsEnums.temperature];
    final payload = SetProgramOptionsPayload(programKey!, temperature, unit: "°C");
    final resource = "$deviceHaId/programs/selected/options/$programKey";

    try {
      api.put(resource: resource, body: payload.body);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  Future<void> setDuration({required int duration}) async {
    final programKey = ovenOptionsMap[OvenOptionsEnums.duration];
    final payload = SetProgramOptionsPayload(programKey!, duration, unit: "seconds");
    final resource = "$deviceHaId/programs/selected/options/$programKey";
    try {
      api.put(resource: resource, body: payload.body);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  /// Starts the selected program
  ///
  /// This is a convenience method that will automatically try to start the selected program
  /// with the minimum required options.
  ///
  /// In order to start a program, first we use [selectProgram] method.
  ///
  /// For ovens, the minimum required options are: [OvenOptionsEnums.duration] and [OvenOptionsEnums.temperature],
  /// they should be set using [setDuration] and [setTemperature] methods.
  ///
  /// If no program is selected, it will throw a [DeviceProgramException].
  ///
  Future<void> startBasicOvenProgram({
    String? programKey,
  }) async {
    programKey ??= selectedProgram?.key;
    if (programKey == null) {
      throw DeviceProgramException("No program selected");
    }
    try {
      final allOptions = await getSelectedProgramOptions();

      ProgramOptions temperature = allOptions
          .firstWhere((element) => element.key == getOvenOptionsKey(OvenOptionsEnums.temperature));
      temperature = ProgramOptions.toCommandPayload(
          key: temperature.key, value: temperature.value, unit: temperature.unit);

      ProgramOptions duration = allOptions
          .firstWhere((element) => element.key == getOvenOptionsKey(OvenOptionsEnums.duration));
      duration = ProgramOptions.toCommandPayload(
          key: duration.key, value: duration.value, unit: duration.unit);

      final payload = StartProgramPayload(this, [temperature, duration]);
      await api.put(body: payload.body, resource: payload.resource);
    } catch (e) {
      throw DeviceProgramException("Could not start program: $e");
    }
  }
  // TODO: addTime method, should use the programs/active/options/key endpoint to add time to the running program.

  // TODO: changeTemperature method, should use the programs/active/options/key endpoint to change the temperature of the running program.
}
