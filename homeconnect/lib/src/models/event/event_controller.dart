import 'dart:convert';
import 'package:eventify/eventify.dart' as eventify;
import 'package:eventsource/eventsource.dart';
import 'package:homeconnect/src/home_device.dart';
import 'package:homeconnect/src/models/event/device_event.dart';

enum EventType { notify, status, event, keepAlive, nil, conected, disconected }

typedef EventFunction = void Function(Event event, HomeDevice source);

Map<String, EventType> _eventTypeMap = {
  'NOTIFY': EventType.notify,
  'STATUS': EventType.status,
  'KEEP-ALIVE': EventType.keepAlive,
  'null': EventType.nil,
  'EVENT': EventType.event,
  'CONNECTED': EventType.conected,
  'DISCONNECTED': EventType.disconected,
};

Map<EventType, List<EventFunction>> functionMap = {
  EventType.status: [],
  EventType.notify: [],
  EventType.keepAlive: [],
  EventType.nil: [],
  EventType.conected: [],
  EventType.disconected: [],
  EventType.event: [],
};

class EventController extends eventify.EventEmitter {
  /// List of functions to be called when a status event is received
  ///
  /// Status events are sent when the status of a device changes, for example when the door is opened or closed.
  List<EventFunction> statusFunctions = [
    (event, source) =>
        source.updateStatusFromEvent(eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
    (event, source) =>
        source.updatePowerSettingsFromEvent(eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
  ];

  /// List of functions to be called when a notify event is received
  ///
  /// Notify events are sent when the settings of a device change, for example when the temperature is changed.
  List<EventFunction> notifyFunctions = [
    (event, source) =>
        source.updateSettingsFromEvent(eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
    (event, source) => source.updateNotifyProgramOptionsFromEvent(
        eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
    (event, source) => source.updateSelectedProgramFromEvent(
        eventData: EventDataListPayload.fromJson(json.decode(event.data!)).events),
  ];

  List<EventFunction> keepAliveFunctions = [];

  List<EventFunction> nilFunctions = [];

  List<EventFunction> eventFunction = [];

  List<EventFunction> placeHolderFunctions = [
    (event, source) => print("Incoming event from: ${source.deviceName}"),
    (event, source) => print("Trigger event:  ${event.event}"),
  ];

  EventController() {
    functionMap[EventType.status] = statusFunctions;
    functionMap[EventType.notify] = notifyFunctions;
    functionMap[EventType.keepAlive] = placeHolderFunctions;
    functionMap[EventType.event] = placeHolderFunctions;
    functionMap[EventType.conected] = placeHolderFunctions;
    functionMap[EventType.disconected] = placeHolderFunctions;
  }

  void handleEvent(Event event, HomeDevice source) {
    if (functionMap.containsKey(_eventTypeMap[event.event])) {
      for (var action in functionMap[_eventTypeMap[event.event]]!) {
        action(event, source);
        // emit("update", event, event.data);
      }
    }
  }
}
