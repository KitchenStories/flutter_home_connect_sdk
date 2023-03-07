import 'dart:async';
import 'dart:convert';

import 'package:eventify/eventify.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect/src/models/devices/device_exceptions.dart';
import 'package:homeconnect/src/models/event/device_event.dart';
import 'package:homeconnect/src/models/settings/constraints/setting_constraints.dart';
import 'package:homeconnect/src/models/settings/device_setting.dart';

mixin ActiveOvenStatus {
  List<ProgramOptions> notifyProgramOptions = [
    ProgramOptions('BSH.Common.Option.RemainingProgramTime', 'integer', 'seconds', 0, null),
    ProgramOptions("BSH.Common.Option.Duration", "integer", "seconds", 0, null),
    ProgramOptions('BSH.Common.Option.ElapsedProgramTime', 'integer', 'seconds', 0, null),
    ProgramOptions('BSH.Common.Option.ProgramProgress', 'integer', "%", 0, null),
    ProgramOptions('BSH.Common.Root.SelectedProgram', 'string', '', 0, null),
    ProgramOptions('BSH.Common.Root.ActiveProgram', 'string', '', 0, null),
    ProgramOptions('Cooking.Oven.Status.CurrentCavityTemperature', 'integer', "°C", 0, null),
  ];
}

class DeviceOven extends HomeDevice with ActiveOvenStatus {
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
  Future<List<DeviceProgram>> getPrograms() async {
    String resource = "$deviceHaId/programs/available";
    try {
      final res = await api.get(resource);
      final data = json.decode(res.body);
      final programs = ProgramListPayload.fromJson(data).programs;

      return programs;
    } catch (e) {
      throw ProgramsException("Something went wrong when fetching programs: $e");
    }
  }

  @override
  Future<List<DeviceStatus>> getStatus() async {
    String resource = "$deviceHaId/status";
    try {
      final res = await api.get(resource);
      final data = json.decode(res.body);
      final status = DeviceStatsListPayload.fromJson(data).stats;
      return status;
    } catch (e) {
      throw StatusException("Something went wrong when fetching status: $e");
    }
  }

  @override
  Future<List<DeviceSetting>> getSettings() async {
    // Get device settings
    String resource = "$deviceHaId/settings";
    try {
      final res = await api.get(resource);
      final data = json.decode(res.body);
      final settings = SettingsListPayload.fromJson(data).settings;

      // Sets constraints for each setting
      await _setSettingsConstraints(settings: settings);

      // Get selected program
      final currentSelected = await api.get("$deviceHaId/programs/selected");
      final currentSelectedData = json.decode(currentSelected.body);

      // Set selected program
      selectedProgram = DeviceProgram(
          currentSelectedData['data']['key'], ProgramOptionsListPayload.fromJson(currentSelectedData).options);

      // Add selected program to settings
      settings.add(DeviceSetting(key: 'BSH.Common.Root.ActiveProgram', value: ''));
      settings.add(DeviceSetting(key: 'BSH.Common.Root.SelectedProgram', value: selectedProgram.key));
      return settings;
    } catch (e) {
      throw SettingsException("Something went wrong when fetching settings: $e");
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
      await _setProgramConstraints(programKey, selectedOptions);
    } catch (e) {
      throw ProgramsException("Something went wrong when selecting program: $e");
    }
  }

  @override
  Future<void> startProgram({String? programKey, required List<ProgramOptions> options}) async {
    programKey ??= selectedProgram.key;
    if (programKey.isEmpty) {
      throw ProgramsException("No program selected");
    }
    try {
      final payload = StartProgramPayload(this, options);
      await api.put(body: payload.body, resource: payload.resource);
    } catch (e) {
      throw ProgramsException("Something went wrong when starting program: $e");
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
  void updateSelectedProgramFromEvent({required List<DeviceEvent> eventData}) {
    _updateValues(eventData: eventData, data: selectedProgram.options);
  }

  @override
  void updateNotifyProgramOptionsFromEvent({required List<DeviceEvent> eventData}) {
    _updateValues(eventData: eventData, data: notifyProgramOptions);
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

  @override
  Future<void> startListening() async {
    try {
      await api.openEventListenerChannel(source: this);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await api.closeEventChannel();
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  void _updateValues<T extends DeviceData>({required List<DeviceEvent> eventData, required List<T> data}) {
    try {
      for (var event in eventData) {
        for (var stat in data) {
          if (stat.key == event.key) {
            print("updated ${stat.key} to ${event.value}");
            stat.value = event.value;
          }
        }
      }
    } catch (e) {
      throw EventsException("Something went wrong when updating values: $e");
    }
  }

  void _setPower(String state) {
    final programKey = settingsMap[OvenSettings.power];
    final value = validValuesMap[OvenSettings.power]?[state];
    try {
      final payload = SetSettingsPayload(deviceHaId, programKey!, value);
      api.put(resource: payload.resource, body: payload.body);
    } catch (e) {
      throw SettingsException("Something went wrong when setting power: $e");
    }
  }

  Future<void> _setProgramConstraints(String programKey, List<ProgramOptions> selectedOptions) async {
    try {
      // Get program constraints
      final constraintsRes = await api.get("$deviceHaId/programs/available/$programKey");
      final constraintsData = json.decode(constraintsRes.body);
      final constraints = ProgramOptionsListPayload.fromJson(constraintsData).options;

      // Add constraints to selected program
      for (var option in selectedOptions) {
        for (var constraint in constraints) {
          if (option.key == constraint.key) {
            option.constraints = constraint.constraints;
          }
        }
      }
    } catch (e) {
      throw ProgramsException("Something went wrong when setting program constraints: $e");
    }
  }

  Future<void> _setSettingsConstraints({required List<DeviceSetting> settings}) async {
    try {
      for (var setting in settings) {
        setting.constraints = SettingsConstraints(allowedValues: []);
        var constraintResponse = await api.get("$deviceHaId/settings/${setting.key}");
        final data = json.decode(constraintResponse.body);

        // Add constraints to setting
        final allowedValuesResponse = AllowedValuesPayload.fromJson(data).constraints.allowedValues;
        setting.constraints.allowedValues.addAll(allowedValuesResponse);
      }
    } catch (e) {
      throw SettingsException("Something went wrong when setting settings constraints: $e");
    }
  }

  @override
  void addCallbackToListener({required EventCallback callback}) {
    api.eventEmitter.addListener(callback);
  }
}
