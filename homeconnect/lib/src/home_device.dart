import 'package:eventify/eventify.dart' show EventEmitter, EventCallback, Listener;
import 'package:eventsource/eventsource.dart' show Event;

import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect/src/models/event/device_event.dart';

import 'models/settings/device_setting.dart';

enum DeviceType { oven, coffeeMaker, dryer, washer, fridgeFreezer, dishwasher }

Map<String, DeviceType> deviceTypeMap = {
  "Oven": DeviceType.oven,
  "CoffeeMaker": DeviceType.coffeeMaker,
  "Dryer": DeviceType.dryer,
  "Washer": DeviceType.washer,
  "FridgeFreezer": DeviceType.fridgeFreezer,
  "Dishwasher": DeviceType.dishwasher
};


/// Base class for home devices
///
/// Contains the shared functionality for all appliances.
///
abstract class HomeDevice {
  final HomeConnectApi api;
  final DeviceInfo info;
  late DeviceProgram selectedProgram;
  List<DeviceStatus> status;
  List<DeviceProgram> programs;
  List<DeviceSetting> settings;
  EventEmitter emitter = EventEmitter();
  List<Listener> listeners = [];

  addStatus(DeviceStatus stat) {
    status.add(stat);
  }

  String get deviceName => info.name;
  String get deviceHaId => info.haId;

  HomeDevice(this.api, this.info, this.status, this.programs, this.settings);

  /// Initializes the device
  ///
  /// Sets the [status] and [programs] properties for this device
  /// by calling the [getPrograms] and [getStatus] methods.
  Future<HomeDevice> init() async {
    programs = await getPrograms();
    status = await getStatus();
    settings = await getSettings();
    return this;
  }

  /// Updates the device status from the provided [eventData]
  void updateStatusFromEvent({required List<DeviceEvent> eventData});

  /// Updates the device settings from the provided [eventData]
  void updateSettingsFromEvent({required List<DeviceEvent> eventData});

  /// Updates the device programs from the provided [eventData]
  void updateSelectedProgramFromEvent({required List<DeviceEvent> eventData});

  /// Updates the device active program from the provided [eventData]
  void updateNotifyProgramOptionsFromEvent({required List<DeviceEvent> eventData});

  /// Selects a program to run on the selected home appliance
  ///
  /// [programKey] - the key of the program to select
  /// Trhows ProgramsException if no program is selected.
  Future<void> selectProgram({required String programKey});

  /// Gets the list of programs available for the selected home appliance
  ///
  /// Returns a list of [DeviceProgram] objects.
  ///
  /// Sets the [programs] property to the list of programs.
  /// Trhows [ProgramsException] if the request fails.
  Future<List<DeviceProgram>> getPrograms();

  /// Gets the list of status for the selected home appliance
  ///
  /// Returns a list of [DeviceStatus] objects.
  ///
  /// Sets the [status] property to the list of status.
  /// Throws [StatusException] if the request fails.
  Future<List<DeviceStatus>> getStatus();

  /// Gets the list of settings for the selected home appliance
  ///
  /// Returns a list of [DeviceSetting] objects.
  ///
  /// Sets the [settings] property to the list of settings.
  ///
  /// Throws [SettingsException] if the request fails.
  Future<List<DeviceSetting>> getSettings();

  /// Starts the selected program
  ///
  /// If no program is selected, throws an exception.
  /// If you want to start a program without selecting it first, use [startProgram] with the [programKey].
  ///
  /// [programKey] - the key of the program to start, if not provided, the selected program will be used.
  ///
  /// [options] - a list of options for the program, e.g. temperature, duration, etc.
  /// Trhows generic exception if the request fails.
  Future<void> startProgram({String programKey, required List<ProgramOptions> options});

  /// Stops the currently running program
  ///
  /// Trhows generic exception if the request fails.
  void stopProgram();

  /// Turns on the selected home appliance
  void turnOn();

  /// Turns off the selected home appliance
  void turnOff();

  /// Starts listening for events from the selected home appliance
  void startListening();

  /// Stops listening for events from the selected home appliance
  void stopListening();

  /// Adds a callback to the event listener
  ///
  /// Before adding a callback we need to use startListening() to start listening for events.
  /// [callback] - the callback to add, needs to be of type [EventCallback]
  /// Trhows EventsException if the event listener is not initialized.
  void addCallbackToListener({required EventCallback callback});

  void handleEvent(Event event);

  Listener addListener({required EventCallback callback, EventType type}) {
    final listener = emitter.on('status', this, callback);
    listeners.add(listener);
    emitter.emit('event');
    return listener;
  }

  void removeListener({required EventCallback callback}) {
    final listener = listeners.firstWhere((element) => element.callback == callback);
    emitter.removeAllByCallback(callback);
    //emitter.off(listener);
    listeners.remove(listener);
  }
}

// General data body used to update the status and settings of the device
abstract class DeviceData {
  final String key;
  dynamic value;
  DeviceData({required this.key, required this.value});
}
