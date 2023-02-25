import 'package:eventsource/eventsource.dart';
import 'package:flutter_home_connect_sdk/src/client/client_dart.dart';
import 'package:flutter_home_connect_sdk/src/models/info/device_info.dart';
import 'package:flutter_home_connect_sdk/src/models/options/program_options.dart';
import 'package:flutter_home_connect_sdk/src/models/programs/device_program.dart';
import 'package:flutter_home_connect_sdk/src/models/settings/device_setting.dart';
import 'package:flutter_home_connect_sdk/src/models/status/device_status.dart';

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
    programs = await api.getPrograms(haId: info.haId);
    status = await api.getStatus(haId: info.haId);
    settings = await api.getSettings(haId: info.haId);
    return this;
  }

  void updateStatusFromEvent(Event event);

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

  /// Starts the selected program
  ///
  /// If no program is selected, throws an exception.
  /// If you want to start a program without selecting it first, use [startProgram] with the [programKey].
  ///
  /// [programKey] - the key of the program to start, if not provided, the selected program will be used.
  ///
  /// [options] - a list of options for the program, e.g. temperature, duration, etc.
  /// Trhows generic exception if the request fails.
  void startProgram({String programKey, required List<ProgramOptions> options});

  /// Stops the currently running program
  ///
  /// Trhows generic exception if the request fails.
  void stopProgram();

  /// Turns on the selected home appliance
  void turnOn();

  /// Turns off the selected home appliance
  void turnOff();

  void listen() {
    while (true) {
      print('listening');
    }
  }
}
