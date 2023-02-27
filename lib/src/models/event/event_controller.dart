import 'dart:convert';

import 'package:eventsource/eventsource.dart';
import 'package:flutter_home_connect_sdk/src/models/event/device_event.dart';

enum EventType { notify, status, keepAlive, nil }

Map<String, EventType> _eventTypeMap = {
  'NOTIFY': EventType.notify,
  'STATUS': EventType.status,
  'KEEP-ALIVE': EventType.keepAlive,
  'null': EventType.nil,
};

class EventController {
  void handleEvent(Event event) {
    DeviceEvent deviceEvent;
    switch (_eventTypeMap[event.event]) {
      case EventType.notify:
        print("NOTIFY event");
        break;
      case EventType.status:
        print("STATUS event");
        print(event.data);
        try {
          deviceEvent = DeviceEvent.fromJson(json.decode(event.data!));
          print(deviceEvent.key);
        } catch (e) {
          print(e);
        }
        break;
      case EventType.keepAlive:
        print("KEEP-ALIVE event");
        break;
      default:
        print(EventType.nil);
        break;
    }
  }
}
