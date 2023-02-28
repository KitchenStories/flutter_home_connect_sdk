import 'package:flutter_home_connect_sdk/src/models/event/device_event.dart';
import 'package:flutter_home_connect_sdk/src/models/home_device.dart';
import 'package:flutter_home_connect_sdk/src/models/options/program_options.dart';
import 'package:flutter_home_connect_sdk/src/models/programs/device_program.dart';

class CoffeeDevice extends HomeDevice {
  CoffeeDevice(super.api, super.info, super.status, super.programs, super.settings);

  @override
  void turnOff() {
    // TODO: implement turnOff
  }

  @override
  void turnOn() {
    // TODO: implement turnOn
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

  @override
  void updateStatusFromEvent({required List<DeviceEvent> eventData}) {
    // TODO: implement updateStatusFromEvent
  }

  @override
  void updateSettingsFromEvent({required List<DeviceEvent> eventData}) {
    // TODO: implement updateSettingsFromEvent
  }
}
