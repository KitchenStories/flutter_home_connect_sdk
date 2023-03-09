import 'dart:convert';

import 'package:eventify/eventify.dart';

import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect/src/models/devices/device_exceptions.dart';
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
  late DeviceProgram selectedProgram;
  List<DeviceStatus> status;
  List<DeviceProgram> programs;
  List<DeviceSetting> settings;
  EventEmitter eventEmitter = EventEmitter();
  List<Listener> listeners = [];

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
    programs = await getPrograms();
    status = await getStatus();
    settings = await getSettings();
    return this;
  }

  /// Updates the device status from the provided [eventData]
  void updateStatusFromEvent({required List<DeviceEvent> eventData}) {
    updateValues(eventData: eventData, data: status);
  }

  /// Updates the device settings from the provided [eventData]
  void updateSettingsFromEvent({required List<DeviceEvent> eventData}) {
    updateValues(eventData: eventData, data: settings);
  }

  /// Updates the device programs from the provided [eventData]
  void updateSelectedProgramFromEvent({required List<DeviceEvent> eventData}) {
    updateValues(eventData: eventData, data: selectedProgram.options);
  }

  /// Updates the device active program from the provided [eventData]
  void updateNotifyProgramOptionsFromEvent({required List<DeviceEvent> eventData});

  void updatePowerSettingsFromEvent({required List<DeviceEvent> eventData}) {
    updateValues(eventData: eventData, data: settings);
  }

  /// Selects a program to run on the selected home appliance
  ///
  /// [programKey] - the key of the program to select
  /// Trhows ProgramsException if no program is selected.
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

  /// Starts the selected program
  ///
  /// If no program is selected, throws an exception.
  /// If you want to start a program without selecting it first, use [startProgram] with the [programKey].
  ///
  /// [programKey] - the key of the program to start, if not provided, the selected program will be used.
  ///
  /// [options] - a list of options for the program, e.g. temperature, duration, etc.
  /// Trhows generic exception if the request fails.
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

  /// Stops the currently running program
  ///
  /// Trhows generic exception if the request fails.
  void stopProgram() {
    String resource = "$deviceHaId/programs/active";
    try {
      api.delete(resource);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  /// Gets the list of programs available for the selected home appliance
  ///
  /// Returns a list of [DeviceProgram] objects.
  ///
  /// Sets the [programs] property to the list of programs.
  /// Trhows [ProgramsException] if the request fails.
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

  /// Gets the list of status for the selected home appliance
  ///
  /// Returns a list of [DeviceStatus] objects.
  ///
  /// Sets the [status] property to the list of status.
  /// Throws [StatusException] if the request fails.
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

  /// Gets the list of settings for the selected home appliance
  ///
  /// Returns a list of [DeviceSetting] objects.
  ///
  /// Sets the [settings] property to the list of settings.
  ///
  /// Throws [SettingsException] if the request fails.
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

  /// OnNotify event handler
  ///
  /// Adds a Listener to the event emitter for the OnNotify event.
  ///
  /// [callback] - the callback function to be called when the event is triggered.
  Listener onNotify({required EventCallback callback}) {
    return addListener(callback: callback, eventName: EventType.notify);
  }

  /// OnStatus event handler
  ///
  /// Adds a Listener to the event emitter for the OnStatus event.
  ///
  /// [callback] - the callback function to be called when the event is triggered.
  Listener onStatus({required EventCallback callback}) {
    return addListener(callback: callback, eventName: EventType.status);
  }

  /// OnSettings event handler
  ///
  /// Adds a Listener to the event emitter for the OnSettings event.
  ///
  /// [callback] - the callback function to be called when the event is triggered.
  Listener onEvent({required EventCallback callback}) {
    return addListener(callback: callback, eventName: EventType.event);
  }

  /// Adds a Listener to the event emitter
  ///
  /// [callback] - the callback function to be called when the event is triggered.
  ///
  /// [eventName] - the name of the event to listen for. See [EventType] for available events.
  Listener addListener({required EventCallback callback, required EventType eventName}) {
    var listener = eventEmitter.on(eventName.name, this, callback);
    listeners.add(listener);
    return listener;
  }

  /// Removes a Listener from the event emitter
  ///
  /// [listener] - the listener to remove
  Listener removeListener({required Listener listener}) {
    print("removing listener: ${listener.eventName}");
    eventEmitter.removeListener(listener.eventName, listener.callback);
    listeners.remove(listener);
    return listener;
  }

  /// Emits an event
  ///
  /// [type] - the type of event to emit. See [EventType] for available events.
  ///
  /// [eventData] - the payload of [DeviceEvent] objects to emit.
  void emitEvent({required EventType type, required List<DeviceEvent> eventData}) {
    eventEmitter.emit(type.name, this, eventData);
  }

  /// Sets the power state of the selected home appliance
  ///
  /// Available states will be different depending on the home appliance.
  ///
  /// [state] - the power state to set. See [PowerState] for available states.
  void setPower(String state);

  /// updates the values of the [data] list with the values from the [eventData] list
  ///
  /// [eventData] - the list of [DeviceEvent] objects to update the values from
  ///
  /// [data] - the list of [DeviceData] objects to update the values of
  ///
  /// Throws [EventsException] if the request fails.
  void updateValues<T extends DeviceData>({required List<DeviceEvent> eventData, required List<T> data}) {
    try {
      for (var event in eventData) {
        for (var stat in data) {
          if (stat.key == event.key) {
            stat.value = event.value;
          }
        }
      }
    } catch (e) {
      throw EventsException("Something went wrong when updating values: $e");
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
}

/// General data body used to update the status and settings of the device
abstract class DeviceData {
  final String key;
  dynamic value;
  DeviceData({required this.key, required this.value});
}
