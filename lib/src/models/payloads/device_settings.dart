enum OvenSettings { power, temperatureUnit, childLock, alarmClock, sabbathMode }

Map<OvenSettings, String> settingsMap = {
  OvenSettings.power: 'BSH.Common.Setting.PowerState',
  OvenSettings.temperatureUnit: 'BSH.Common.Setting.TemperatureUnit',
  OvenSettings.childLock: 'BSH.Common.Setting.ChildLock',
  OvenSettings.alarmClock: 'BSH.Common.Setting.AlarmClock',
  OvenSettings.sabbathMode: 'Cooking.Oven.Setting.SabbathMode',
};

Map<OvenSettings, Map<String, String>> validValuesMap = {
  OvenSettings.power: {
    'on': "BSH.Common.EnumType.PowerState.On",
    'off': "BSH.Common.EnumType.PowerState.Standby"
  }
};
