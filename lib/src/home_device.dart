import 'package:eventsource/eventsource.dart';
import 'package:flutter_home_connect_sdk/src/client_dart.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_info.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_options.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_program.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_status.dart';

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
  List<DeviceOptions> options;
  List<DeviceStatus> status;
  List<DeviceProgram> programs;

  addOption(DeviceOptions option) {
    options.add(option);
  }

  addStatus(DeviceStatus stat) {
    status.add(stat);
  }

  String get deviceName => info.name;
  String get deviceHaId => info.haId;

  HomeDevice(this.api, this.info, this.options, this.status, this.programs);

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
  void startProgram({String programKey, required List<DeviceOptions> options});

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
