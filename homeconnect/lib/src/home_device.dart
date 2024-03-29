import 'dart:convert';

import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect/src/models/devices/device_exceptions.dart';
import 'package:homeconnect/src/models/devices/operation_states.dart';
import 'package:homeconnect/src/models/event/device_event.dart';
import 'package:homeconnect/src/models/settings/constraints/setting_constraints.dart';

import 'models/settings/device_setting.dart';

enum DeviceType { oven, coffeeMaker, dryer, washer, fridgeFreezer, dishwasher }

Map<String, DeviceType> deviceTypeMap = {
  "Oven": DeviceType.oven,
  "CoffeeMaker": DeviceType.coffeeMaker,
  "Dryer": DeviceType.dryer,
  "Washer": DeviceType.washer,
  "FridgeFreezer": DeviceType.fridgeFreezer,
  "Dishwasher": DeviceType.dishwasher
};

/// Base class for home devices
///
/// Contains the shared functionality for all appliances.
///
abstract class HomeDevice {
  final HomeConnectApi api;
  final DeviceInfo info;
  DeviceProgram? selectedProgram;
  List<DeviceStatus> status;
  List<DeviceProgram> programs;
  List<DeviceSetting> settings;

  addStatus(DeviceStatus stat) {
    status.add(stat);
  }

  String get deviceName => info.name;
  String get deviceHaId => info.haId;

  HomeDevice(this.api, this.info, this.status, this.programs, this.settings);

  /// Initializes the device
  ///
  /// Sets the [status] and [programs] properties for this device
  /// by calling the [getPrograms] and [getStatus] methods.
  Future<HomeDevice> init() async {
    status = await getStatus();
    programs = await getPrograms();
    settings = await getSettings();
    return this;
  }

  void updateStatusFromEvent({required List<DeviceEvent> eventData}) {
    _updateValues(eventData: eventData, data: status);
  }

  void updateSettingsFromEvent({required List<DeviceEvent> eventData}) {
    _updateValues(eventData: eventData, data: settings);
  }

  /// Selects a program to run on the selected home appliance
  /// [programKey] - the key of the program to select
  /// Trhows generic exception if the request fails.
  Future<void> selectProgram({required String programKey}) async {
    try {
      // Select program, sends put request
      final payload = SelectProgramPayload(this, programKey);
      await api.put(body: payload.body, resource: payload.resource);

      // Get program options, /selected returns the program with no constraints
      var res = await api.get("$deviceHaId/programs/selected");
      var data = json.decode(res.body);
      final selectedOptions = ProgramOptionsListPayload.fromJson(data).options;
      selectedProgram = DeviceProgram(programKey, selectedOptions);

      // Get program options with constraints
      final fullOptions = await _getFullOptions(programKey);
      _updateSelectedOptions(selectedOptions, fullOptions);
    } catch (e, stacktrace) {
      throw DeviceProgramException("Could not select program", stacktrace);
    }
  }

  /// Gets the list of programs available for the selected home appliance
  ///
  /// Returns a list of [DeviceProgram] objects.
  ///
  /// Sets the [programs] property to the list of programs.
  /// Trhows generic exception if the request fails.
  Future<List<DeviceProgram>> getPrograms() async {
    try {
      if (!isDeviceReady()) {
        throw DeviceException("Device is busy!");
      }
      String resource = "$deviceHaId/programs/available";
      final res = await api.get(resource);
      final data = json.decode(res.body);
      final programs = ProgramListPayload.fromJson(data).programs;
      return programs;
    } catch (e, stacktrace) {
      throw DeviceProgramException("Could not get programs", stacktrace);
    }
  }

  Future<List<DeviceStatus>> getStatus() async {
    try {
      String resource = "$deviceHaId/status";
      final res = await api.get(resource);
      final data = json.decode(res.body);
      final status = DeviceStatsListPayload.fromJson(data).stats;
      return status;
    } catch (e, stacktrace) {
      throw DeviceStatusException("Could not get status", stacktrace);
    }
  }

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
        var constraintResponse =
            await api.get("$deviceHaId/settings/${setting.key}");
        final data = json.decode(constraintResponse.body);
        // Add constraints to setting
        final allowedValuesResponse =
            AllowedValuesPayload.fromJson(data).constraints.allowedValues;
        setting.constraints.allowedValues.addAll(allowedValuesResponse);
      }
      // Return complete list of settings
      return settings;
    } catch (e, stacktrace) {
      throw DeviceStatusException(
          "Something went wrong when getting settings", stacktrace);
    }
  }

  Future<List<ProgramOptions>> getSelectedProgramOptions() async {
    try {
      String resource = "$deviceHaId/programs/selected/";
      final res = await api.get(resource);
      final data = json.decode(res.body);
      final options = ProgramOptionsListPayload.fromJson(data).options;
      return options;
    } catch (e, stacktrace) {
      throw DeviceProgramException(
          "Could not get selected program options", stacktrace);
    }
  }

  Future<DeviceProgram> getSelectedProgram() async {
    try {
      String resource = "$deviceHaId/programs/selected/";
      final res = await api.get(resource);
      final data = json.decode(res.body);
      final options = ProgramOptionsListPayload.fromJson(data).options;
      final programKey = data['data']['key'];
      return DeviceProgram(programKey, options);
    } catch (e, stacktrace) {
      throw DeviceProgramException(
          "Could not get selected program", stacktrace);
    }
  }

  bool isDeviceReady() {
    return status.any((stat) =>
        stat.value == operationState(state: OperationStatesEnum.ready) ||
        stat.value == operationState(state: OperationStatesEnum.inactive));
  }

  /// Starts the selected program
  ///
  /// If no program is selected, throws an exception.
  /// If you want to start a program without selecting it first, use [startProgram] with the [programKey].
  ///
  /// [programKey] - the key of the program to start, if not provided, the selected program will be used.
  ///
  /// [options] - a list of options for the program, e.g. temperature, duration, etc.
  /// Throws [DeviceProgramException] if the request fails.
  Future<void> startProgram(
      {String? programKey, List<ProgramOptions> options = const []}) async {
    programKey ??= selectedProgram?.key;
    if (programKey == null || programKey.isEmpty) {
      throw DeviceProgramException("No program selected");
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
    } catch (e, stacktrace) {
      throw DeviceProgramException("Could not start program", stacktrace);
    }
  }

  /// Stops the currently running program
  ///
  /// Trhows generic exception if the request fails.
  Future<void> stopProgram() async {
    String resource = "$deviceHaId/programs/active";
    try {
      await api.delete(resource);
    } catch (e, stacktrace) {
      throw DeviceProgramException(
          "Something went wrong when stopping program", stacktrace);
    }
  }

  /// Turns on the selected home appliance
  void turnOn();

  /// Turns off the selected home appliance
  void turnOff();

  /// Starts listening for events from the selected home appliance
  Future<void> startListening() async {
    try {
      await api.openEventListenerChannel(source: this);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  /// Stops listening for events from the selected home appliance
  Future<void> stopListening() async {
    try {
      await api.closeEventChannel();
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  void _updateValues<T extends DeviceData>(
      {required List<DeviceEvent> eventData, required List<T> data}) {
    for (var event in eventData) {
      for (var stat in data) {
        if (stat.key == event.key) {
          stat.value = event.value;
        }
      }
    }
  }

  Future<List<ProgramOptions>> _getFullOptions(String programKey) async {
    var constraintsRes =
        await api.get("$deviceHaId/programs/available/$programKey");
    var constraintsData = json.decode(constraintsRes.body);
    return ProgramOptionsListPayload.fromJson(constraintsData).options;
  }

  void _updateSelectedOptions(
      List<ProgramOptions> selectedOptions, List<ProgramOptions> fullOptions) {
    for (var option in selectedOptions) {
      for (var fullOption in fullOptions) {
        if (option.key == fullOption.key) {
          option.type = fullOption.type;
          option.unit = fullOption.unit;
          option.constraints = fullOption.constraints;
        }
      }
    }
  }
}

// General data body used to update the status and settings of the device
abstract class DeviceData {
  final String key;
  dynamic value;
  DeviceData({required this.key, required this.value});
}
