class DeviceEvent {
  final String level;
  final String handling;
  final String key;
  final String value;
  final String uri;

  DeviceEvent(this.level, this.handling, this.key, this.value, this.uri);

  factory DeviceEvent.fromPayload(Map<String, dynamic> payload) {
    return DeviceEvent(
      payload['level'],
      payload['handling'],
      payload['key'],
      payload['value'],
      payload['uri'],
    );
  }
}
