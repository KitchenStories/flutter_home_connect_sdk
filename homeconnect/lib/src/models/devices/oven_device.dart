import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect/src/models/devices/device_exceptions.dart';
import 'package:homeconnect/src/models/settings/device_setting.dart';

mixin ActiveOvenStatus {
  List<ProgramOptions> notifyProgramOptions = [
    ProgramOptions('BSH.Common.Option.RemainingProgramTime', 'integer', 'seconds', 0, null),
    ProgramOptions("BSH.Common.Option.Duration", "integer", "seconds", 0, null),
    ProgramOptions('BSH.Common.Option.ElapsedProgramTime', 'integer', 'seconds', 0, null),
    ProgramOptions('BSH.Common.Option.ProgramProgress', 'integer', "%", 0, null),
    ProgramOptions('BSH.Common.Root.SelectedProgram', 'string', '', 0, null),
    ProgramOptions('BSH.Common.Root.ActiveProgram', 'string', '', 0, null),
    ProgramOptions('Cooking.Oven.Status.CurrentCavityTemperature', 'integer', "°C", 0, null),
  ];
}

class DeviceOven extends HomeDevice with ActiveOvenStatus {
  DeviceOven(HomeConnectApi api, DeviceInfo info, List<ProgramOptions> options, List<DeviceStatus> status,
      List<DeviceProgram> programs, List<DeviceSetting> settings)
      : super(api, info, status, programs, settings);

  factory DeviceOven.fromPayload(HomeConnectApi api, DeviceInfo info, List<ProgramOptions> options,
      List<DeviceStatus> stats, List<DeviceProgram> programs, List<DeviceSetting> settings) {
    return DeviceOven(api, info, options, stats, programs, settings);
  }

  factory DeviceOven.fromInfoPayload(HomeConnectApi api, DeviceInfo info) {
    return DeviceOven(api, info, [], [], [], []);
  }

  /// Sets the [OvenSettings.power] enum to `off`
  @override
  void turnOff() {
    setPower("off");
  }

  /// Sets the [OvenSettings.power] enum to `on`
  @override
  void turnOn() {
    setPower("on");
  }

  @override
  void updateNotifyProgramOptionsFromEvent({required List<DeviceEvent> eventData}) {
    updateValues(eventData: eventData, data: notifyProgramOptions);
  }

  @override
  void setPower(String state) {
    final programKey = settingsMap[OvenSettings.power];
    final value = validValuesMap[OvenSettings.power]?[state];
    try {
      final payload = SetSettingsPayload(deviceHaId, programKey!, value);
      api.put(resource: payload.resource, body: payload.body);
    } catch (e) {
      throw SettingsException("Something went wrong when setting power: $e");
    }
  }
}
