import 'package:eventsource/eventsource.dart';
import 'package:flutter_home_connect_sdk/src/client/client_dart.dart';
import 'package:flutter_home_connect_sdk/src/home_device.dart';
import 'package:flutter_home_connect_sdk/src/models/info/device_info.dart';
import 'package:flutter_home_connect_sdk/src/models/options/program_options.dart';
import 'package:flutter_home_connect_sdk/src/models/programs/device_program.dart';
import 'package:flutter_home_connect_sdk/src/models/status/device_status.dart';

class CoffeeDevice extends HomeDevice {
  CoffeeDevice(HomeConnectApi api, DeviceInfo info, List<ProgramOptions> options, List<DeviceStatus> status,
      List<DeviceProgram> programs)
      : super(api, info, status, programs);

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
  void stopProgram() {
    // TODO: implement stopProgram
  }

  @override
  void startProgram({String? programKey, required List<ProgramOptions> options}) {
    // TODO: implement startProgram
  }
}
