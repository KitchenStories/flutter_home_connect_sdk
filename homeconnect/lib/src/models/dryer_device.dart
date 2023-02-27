import 'package:eventsource/eventsource.dart';
import 'package:homeconnect/src/client_dart.dart';
import 'package:homeconnect/src/home_device.dart';
import 'package:homeconnect/src/models/payloads/device_status.dart';
import 'package:homeconnect/src/models/payloads/device_program.dart';
import 'package:homeconnect/src/models/payloads/device_options.dart';
import 'package:homeconnect/src/models/payloads/device_info.dart';

class DryerDevice extends HomeDevice {
  DryerDevice(HomeConnectApi api, DeviceInfo info, List<DeviceOptions> options,
      List<DeviceStatus> status, List<DeviceProgram> programs)
      : super(api, info, options, status, programs);

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
    // TODO: implement startProgram
  }

  @override
  void stopProgram() {
    // TODO: implement stopProgram
  }
}
