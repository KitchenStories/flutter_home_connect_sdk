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

abstract class HomeDevice {
  final HomeConnectApi api;
  final DeviceInfo info;
  List<DeviceOptions> options;
  List<DeviceStatus> status;
  List<DeviceProgram> programs;

  set info(DeviceInfo info) {
    info = info;
  }

  addOption(DeviceOptions option) {
    options.add(option);
  }

  addStatus(DeviceStatus stat) {
    status.add(stat);


  }

  String get deviceName => info.name;
  String get deviceHaId => info.haId;


  HomeDevice(this.api, this.info, this.options, this.status, this.programs);


  Map<String, dynamic> showOptions();

  Map<String, dynamic> getStatus();

  void updateStatusFromEvent(Event event);

  void turnOn();

  void turnOff();

  void listen() {
    while (true) {
      print('listening');
    }
  }
}
