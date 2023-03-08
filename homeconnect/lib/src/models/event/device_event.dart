import 'package:eventify/eventify.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_event.g.dart';

@JsonSerializable()
class DeviceEvent {
  final String level;
  final String handling;
  final String key;
  final dynamic value;
  final String uri;

  DeviceEvent(this.level, this.handling, this.key, this.value, this.uri);

  Map<String, dynamic> toJson() => _$DeviceEventToJson(this);

  factory DeviceEvent.fromJson(Map<String, dynamic> json) => _$DeviceEventFromJson(json);

  static List<DeviceEvent> toEventList(Event ev) {
    if (ev.eventData is List<DeviceEvent>) {
      return ev.eventData as List<DeviceEvent>;
    } else if (ev.eventData is DeviceEvent) {
      return [ev.eventData as DeviceEvent];
    } else {
      return [];
    }
  }
}

class EventDataListPayload {
  final List<DeviceEvent> events;

  EventDataListPayload(this.events);

  factory EventDataListPayload.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List).map((e) => DeviceEvent.fromJson(e)).toList();
    return EventDataListPayload(items);
  }
}
