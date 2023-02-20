import 'package:eventsource/src/event.dart';
import 'package:flutter_home_connect_sdk/src/client_dart.dart';
import 'package:flutter_home_connect_sdk/src/home_device.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_status.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_program.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_options.dart';
import 'package:flutter_home_connect_sdk/src/models/payloads/device_info.dart';

class CoffeeDevice extends HomeDevice {
  CoffeeDevice(HomeConnectApi api, DeviceInfo info, List<DeviceOptions> options,
      List<DeviceStatus> status, List<DeviceProgram> programs)
      : super(api, info, options, status, programs);

  @override
  Map<String, dynamic> getStatus() {
    // TODO: implement getStatus
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> showOptions() {
    // TODO: implement showOptions
    throw UnimplementedError();
  }

  @override
  void turnOff() {
    // TODO: implement turnOff
  }

  @override
  void turnOn() {
    // TODO: implement turnOn
  }

  @override
  void updateStatusFromEvent(Event event) {
    // TODO: implement updateStatusFromEvent
  }

  @override
  Future<void> selectProgram({required String programKey}) async {
    // TODO: implement selectProgram
  }

  @override
  Future<List<DeviceProgram>> getPrograms() {
    // TODO: implement getPrograms
    throw UnimplementedError();
  }

  @override
  void startProgram(
      {String? programKey, required List<DeviceOptions> options}) {
    // TODO: implement startProgram1
  }

  @override
  void stopProgram() {
    // TODO: implement stopProgram
  }
}
