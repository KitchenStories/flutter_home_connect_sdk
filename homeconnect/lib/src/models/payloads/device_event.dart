import 'package:json_annotation/json_annotation.dart';

part 'device_event.g.dart';

@JsonSerializable()
class DeviceEvent {
  final String level;
  final String handling;
  final String key;
  final String value;
  final String uri;

  DeviceEvent(this.level, this.handling, this.key, this.value, this.uri);

  Map<String, dynamic> toJson() => _$DeviceEventToJson(this);

  factory DeviceEvent.fromJson(Map<String, dynamic> json) =>
      _$DeviceEventFromJson(json);
}
