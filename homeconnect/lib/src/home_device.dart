import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect/src/models/event/device_event.dart';

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

  void updateStatusFromEvent({required List<DeviceEvent> eventData});

  void updateSettingsFromEvent({required List<DeviceEvent> eventData});

  /// Selects a program to run on the selected home appliance
  /// [programKey] - the key of the program to select
  /// Trhows generic exception if the request fails.
  Future<void> selectProgram({required String programKey});

  /// Gets the list of programs available for the selected home appliance
  ///
  /// Returns a list of [DeviceProgram] objects.
  ///
  /// Sets the [programs] property to the list of programs.
  /// Trhows generic exception if the request fails.
  Future<List<DeviceProgram>> getPrograms();

  Future<List<DeviceStatus>> getStatus();

  Future<List<DeviceSetting>> getSettings();

  Future<List<ProgramOptions>> getSelectedProgramOptions();

  Future<DeviceProgram> getSelectedProgram();

  /// Starts the selected program
  ///
  /// If no program is selected, throws an exception.
  /// If you want to start a program without selecting it first, use [startProgram] with the [programKey].
  ///
  /// [programKey] - the key of the program to start, if not provided, the selected program will be used.
  ///
  /// [options] - a list of options for the program, e.g. temperature, duration, etc.
  /// Trhows generic exception if the request fails.
  Future<void> startProgram({String programKey, List<ProgramOptions> options = const []});

  /// Stops the currently running program
  ///
  /// Trhows generic exception if the request fails.
  void stopProgram();

  /// Turns on the selected home appliance
  void turnOn();

  /// Turns off the selected home appliance
  void turnOff();

  /// Starts listening for events from the selected home appliance
  void startListening();

  /// Stops listening for events from the selected home appliance
  void stopListening();
}

// General data body used to update the status and settings of the device
abstract class DeviceData {
  final String key;
  dynamic value;
  DeviceData({required this.key, required this.value});
}
