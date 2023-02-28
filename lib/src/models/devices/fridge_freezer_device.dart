import 'package:flutter_home_connect_sdk/src/models/home_device.dart';
import 'package:flutter_home_connect_sdk/src/models/options/program_options.dart';

import 'package:flutter_home_connect_sdk/src/models/programs/device_program.dart';

import '../event/device_event.dart';

class FridgeFreezerDevice extends HomeDevice {
  FridgeFreezerDevice(super.api, super.info, super.status, super.programs, super.settings);

  @override
  Future<List<DeviceProgram>> getPrograms() {
    // TODO: implement getPrograms
    throw UnimplementedError();
  }

  @override
  Future<void> selectProgram({required String programKey}) {
    // TODO: implement selectProgram
    throw UnimplementedError();
  }

  @override
  void startProgram({String? programKey, required List<ProgramOptions> options}) {
    // TODO: implement startProgram
  }

  @override
  void stopProgram() {
    // TODO: implement stopProgram
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
  void updateStatusFromEvent({required List<DeviceEvent> eventData}) {
    // TODO: implement updateStatusFromEvent
  }

  @override
  void updateSettingsFromEvent({required List<DeviceEvent> eventData}) {
    // TODO: implement updateSettingsFromEvent
  }
}
