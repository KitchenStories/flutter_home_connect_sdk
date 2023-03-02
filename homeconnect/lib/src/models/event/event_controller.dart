import 'dart:convert';
import 'package:eventify/eventify.dart' as eventify;
import 'package:eventsource/eventsource.dart';
import 'package:homeconnect/src/home_device.dart';
import 'package:homeconnect/src/models/event/device_event.dart';

enum EventType { notify, status, keepAlive, nil }

typedef EventFunction = void Function(Event event, HomeDevice source);

Map<String, EventType> _eventTypeMap = {
  'NOTIFY': EventType.notify,
  'STATUS': EventType.status,
  'KEEP-ALIVE': EventType.keepAlive,
  'null': EventType.nil,
};

Map<EventType, List<EventFunction>> functionMap = {
  EventType.status: [],
  EventType.notify: [],
  EventType.keepAlive: [],
  EventType.nil: [],
};

class EventController extends eventify.EventEmitter {
  List<EventFunction> statusFunctions = [
    (event, source) => source.updateStatusFromEvent(
        eventData: (json.decode(event.data!)['items'] as List).map((e) => DeviceEvent.fromJson(e)).toList()),
    (event, source) => source.updateSettingsFromEvent(
        eventData: (json.decode(event.data!)['items'] as List).map((e) => DeviceEvent.fromJson(e)).toList()),
  ];

  List<EventFunction> notifyFunctions = [];

  List<EventFunction> keepAliveFunctions = [];

  List<EventFunction> nilFunctions = [];

  EventController() {
    functionMap[EventType.status] = statusFunctions;
    functionMap[EventType.notify] = notifyFunctions;
    functionMap[EventType.keepAlive] = keepAliveFunctions;
    functionMap[EventType.nil] = nilFunctions;
  }

  void handleEvent(Event event, HomeDevice source) {
    if (functionMap.containsKey(_eventTypeMap[event.event])) {
      for (var action in functionMap[_eventTypeMap[event.event]]!) {
        action(event, source);
        emit("update", event, event.data);
      }
    }
  }

  void addListener(eventify.EventCallback callback) {
    on("update", this, callback);
  }
}
