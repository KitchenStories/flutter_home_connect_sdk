import 'package:eventsource/eventsource.dart';

enum EventType { notify, status, keepAlive, nil }

Map<String, EventType> _eventTypeMap = {
  'NOTIFY': EventType.notify,
  'STATUS': EventType.status,
  'KEEP-ALIVE': EventType.keepAlive,
  'null': EventType.nil,
};

class EventController {
  void handleEvent(Event event) {
    switch (_eventTypeMap[event.event]) {
      case EventType.notify:
        print("NOTIFY event");
        break;
      case EventType.status:
        print("STATUS event");
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
