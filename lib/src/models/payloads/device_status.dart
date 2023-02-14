class DeviceStatus {
  final String key;
  String value = '';

  DeviceStatus(this.key, String value);
  factory DeviceStatus.fromPayload(Map<String, dynamic> payload) {
    print("payload \n $payload");
    return DeviceStatus(
      payload['key'],
      payload['value'].toString(),
    );
  }
}
