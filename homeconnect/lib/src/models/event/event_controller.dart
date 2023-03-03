import 'dart:convert';
import 'package:eventify/eventify.dart' as eventify;
import 'package:eventsource/eventsource.dart';
import 'package:homeconnect/src/home_device.dart';
import 'package:homeconnect/src/models/event/device_event.dart';

enum EventType { notify, status, event, keepAlive, nil }

typedef EventFunction = void Function(Event event, HomeDevice source);

Map<String, EventType> _eventTypeMap = {
  'NOTIFY': EventType.notify,
  'STATUS': EventType.status,
  'KEEP-ALIVE': EventType.keepAlive,
  'null': EventType.nil,
  'EVENT': EventType.event,
};

Map<EventType, List<EventFunction>> functionMap = {
  EventType.status: [],
  EventType.notify: [],
  EventType.keepAlive: [],
  EventType.nil: [],
};

class EventController extends eventify.EventEmitter {
  bool isListening = false;

  /// List of functions to be called when a status event is received
  ///
  /// Status events are sent when the status of a device changes, for example when the door is opened or closed.
  List<EventFunction> statusFunctions = [
    (event, source) =>
        source.updateStatusFromEvent(eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
    (event, source) =>
        source.updateSettingsFromEvent(eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
  ];

  /// List of functions to be called when a notify event is received
  ///
  /// Notify events are sent when the settings of a device change, for example when the temperature is changed.
  List<EventFunction> notifyFunctions = [
    (event, source) =>
        source.updateSettingsFromEvent(eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
    (event, source) =>
        source.updateProgramOptionsFromEvent(eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
    (event, source) =>
        source.updateActiveProgramFromEvent(eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
  ];

  List<EventFunction> keepAliveFunctions = [];

  List<EventFunction> nilFunctions = [];

  List<EventFunction> eventFunction = [(event, source) => {}];

  EventController() {
    functionMap[EventType.status] = statusFunctions;
    functionMap[EventType.notify] = notifyFunctions;
    functionMap[EventType.keepAlive] = keepAliveFunctions;
    functionMap[EventType.event] = eventFunction;
  }

  void handleEvent(Event event, HomeDevice source) {
    isListening = true;
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
