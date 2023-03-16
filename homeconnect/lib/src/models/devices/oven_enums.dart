enum OvenSettingsEnums {
  power,
  temperatureUnit,
  childLock,
  alarmClock,
  sabbathMode
}

enum OvenOptionsEnums { temperature, duration }

Map<OvenSettingsEnums, String> ovenSettingsMap = {
  OvenSettingsEnums.power: 'BSH.Common.Setting.PowerState',
  OvenSettingsEnums.temperatureUnit: 'BSH.Common.Setting.TemperatureUnit',
  OvenSettingsEnums.childLock: 'BSH.Common.Setting.ChildLock',
  OvenSettingsEnums.alarmClock: 'BSH.Common.Setting.AlarmClock',
  OvenSettingsEnums.sabbathMode: 'Cooking.Oven.Setting.SabbathMode',
};

Map<OvenOptionsEnums, String> ovenOptionsMap = {
  OvenOptionsEnums.temperature: 'Cooking.Oven.Option.SetpointTemperature',
  OvenOptionsEnums.duration: 'BSH.Common.Option.Duration',
};

Map<OvenSettingsEnums, Map<String, String>> powerStateMap = {
  OvenSettingsEnums.power: {
    'on': "BSH.Common.EnumType.PowerState.On",
    'off': "BSH.Common.EnumType.PowerState.Standby"
  }
};
