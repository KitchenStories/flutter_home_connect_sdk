class DeviceException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  DeviceException(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

class DeviceProgramException extends DeviceException {
  DeviceProgramException(super.message, [super.stackTrace]);
}

class DeviceStatusException extends DeviceException {
  DeviceStatusException(super.message, [super.stackTrace]);
}

class DeviceSettingException extends DeviceException {
  DeviceSettingException(super.message, [super.stackTrace]);
}
