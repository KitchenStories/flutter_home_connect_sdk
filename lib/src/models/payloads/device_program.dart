class DeviceProgram {
  final String key;

  DeviceProgram(this.key);

  factory DeviceProgram.fromPayload(Map<String, dynamic> payload) {
    return DeviceProgram(payload['key']);
  }
}
