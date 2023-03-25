import 'dart:async';
import 'dart:convert';

import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect/src/models/devices/oven_enums.dart';
import 'package:homeconnect/src/models/event/device_event.dart';
import 'package:homeconnect/src/models/settings/constraints/setting_constraints.dart';
import 'package:homeconnect/src/models/settings/device_setting.dart';

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

  @override
  Future<List<ProgramOptions>> getSelectedProgramOptions() async {
    String resource = "$deviceHaId/programs/selected/";
    final res = await api.get(resource);
    final data = json.decode(res.body);
    final options = ProgramOptionsListPayload.fromJson(data).options;
    return options;
  }

  @override
  Future<DeviceProgram> getSelectedProgram() async {
    String resource = "$deviceHaId/programs/selected/";
    final res = await api.get(resource);
    final data = json.decode(res.body);
    final options = ProgramOptionsListPayload.fromJson(data).options;
    final programKey = data['data']['key'];
    return DeviceProgram(programKey, options);
  }

  @override
  Future<List<DeviceProgram>> getPrograms() async {
    String resource = "$deviceHaId/programs/available";
    final res = await api.get(resource);
    final data = json.decode(res.body);
    final programs = ProgramListPayload.fromJson(data).programs;

    return programs;
  }

  @override
  Future<List<DeviceStatus>> getStatus() async {
    String resource = "$deviceHaId/status";
    final res = await api.get(resource);
    final data = json.decode(res.body);
    final status = DeviceStatsListPayload.fromJson(data).stats;
    return status;
  }

  @override
  Future<List<DeviceSetting>> getSettings() async {
    // Get device settings
    String resource = "$deviceHaId/settings";
    try {
      final res = await api.get(resource);
      final data = json.decode(res.body);
      final settings = SettingsListPayload.fromJson(data).settings;
      // Get constraints for each setting
      for (var setting in settings) {
        setting.constraints = SettingsConstraints(allowedValues: []);
        var constraintResponse = await api.get("$deviceHaId/settings/${setting.key}");
        final data = json.decode(constraintResponse.body);
        // Add constraints to setting
        final allowedValuesResponse = AllowedValuesPayload.fromJson(data).constraints.allowedValues;
        setting.constraints.allowedValues.addAll(allowedValuesResponse);
      }
      // Return complete list of settings
      return settings;
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  @override
  Future<void> selectProgram({required String programKey}) async {
    try {
      // Select program, sends put request
      final SelectProgramPayload payload = SelectProgramPayload(this, programKey);
      await api.put(body: payload.body, resource: payload.resource);
      // Get program options, /selected returns the program with no constraints
      var res = await api.get("$deviceHaId/programs/selected");
      var data = json.decode(res.body);
      final selectedOptions = ProgramOptionsListPayload.fromJson(data).options;
      selectedProgram = DeviceProgram(programKey, selectedOptions);
      // Get program options with constraints
      var constraintsRes = await api.get("$deviceHaId/programs/available/$programKey");
      var constraintsData = json.decode(constraintsRes.body);
      final constraints = ProgramOptionsListPayload.fromJson(constraintsData).options;

      for (var option in selectedOptions) {
        for (var constraint in constraints) {
          if (option.key == constraint.key) {
            option.constraints = constraint.constraints;
          }
        }
      }
    } catch (e) {
      throw Exception("Could not select program: $e");
    }
  }

  @override
  Future<void> startProgram({String? programKey, List<ProgramOptions> options = const []}) async {
    programKey ??= selectedProgram.key;
    if (programKey.isEmpty) {
      throw Exception("No program selected");
    }
    try {
      StartProgramPayload payload;
      if (options.isEmpty) {
        final selectedOptions = await getSelectedProgramOptions();
        payload = StartProgramPayload(this, selectedOptions);
      } else {
        payload = StartProgramPayload(this, options);
      }
      await api.put(body: payload.body, resource: payload.resource);
    } catch (e) {
      throw Exception(e);
    }
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

  @override
  void updateStatusFromEvent({required List<DeviceEvent> eventData}) {
    _updateValues(eventData: eventData, data: status);
  }

  @override
  void updateSettingsFromEvent({required List<DeviceEvent> eventData}) {
    _updateValues(eventData: eventData, data: settings);
  }

  @override
  void stopProgram() {
    String resource = "$deviceHaId/programs/active";
    try {
      api.delete(resource);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  /// Starts listening for events from the device
  @override
  Future<void> startListening() async {
    try {
      await api.openEventListenerChannel(source: this);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  /// Stops listening for events from the device
  @override
  Future<void> stopListening() async {
    try {
      await api.closeEventChannel();
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  Future<void> setTemperature({required int temperature}) async {
    final programKey = ovenOptionsMap[OvenOptionsEnums.temperature];
    final payload = SetProgramOptionsPayload(programKey!, temperature, unit: "°F");
    final resource = "$deviceHaId/programs/selected/options/$programKey";
    try {
      api.put(resource: resource, body: payload.body);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  Future<void> setDuration({required int duration}) async {
    final programKey = ovenOptionsMap[OvenOptionsEnums.duration];
    final payload = SetProgramOptionsPayload(programKey!, duration);
    final resource = "$deviceHaId/programs/selected/options/$programKey";
    try {
      api.put(resource: resource, body: payload.body);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  // TODO: addTime method, should use the programs/active/options/key endpoint to add time to the running program.

  // TODO: changeTemperature method, should use the programs/active/options/key endpoint to change the temperature of the running program.

  void _updateValues<T extends DeviceData>({required List<DeviceEvent> eventData, required List<T> data}) {
    for (var event in eventData) {
      for (var stat in data) {
        if (stat.key == event.key) {
          stat.value = event.value;
        }
      }
    }
  }

  void _setPower(String state) {
    final programKey = settingsMap[OvenSettings.power];
    final value = powerStateMap[OvenSettingsEnums.power]![state];
    final payload = SetSettingsPayload(deviceHaId, programKey!, value);
    api.put(resource: payload.resource, body: payload.body);
  }
}
