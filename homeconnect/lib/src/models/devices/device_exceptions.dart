class DeviceExceptions implements Exception {
  final String message;

  DeviceExceptions(this.message);

  @override
  String toString() => message;
}

class DeviceProgramException extends DeviceExceptions {
  DeviceProgramException(super.message);
}

class DeviceStatusException extends DeviceExceptions {
  DeviceStatusException(super.message);
}

class DeviceSettingException extends DeviceExceptions {
  DeviceSettingException(super.message);
}
