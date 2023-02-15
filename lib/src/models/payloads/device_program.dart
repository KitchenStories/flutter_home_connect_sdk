
import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

class DeviceProgram {
  final String key;
  final List<DeviceOptions> options;

  DeviceProgram(this.key, this.options);

  set options(List<DeviceOptions> options) {
    this.options = options;
  }

  factory DeviceProgram.fromPayload(Map<String, dynamic> payload) {
    return DeviceProgram(payload['key'], []);
  }
}
