class DeviceStatus {
  final String key;
  final String value;

  DeviceStatus(this.key, this.value);
  factory DeviceStatus.fromPayload(Map<String, dynamic> payload) {
    return DeviceStatus(
      payload['key'],
      payload['value'].toString(),
    );
  }
}
