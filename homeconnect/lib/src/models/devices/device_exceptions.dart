class DeviceException implements Exception {
  final String message;

  DeviceException(this.message);

  @override
  String toString() {
    return message;
  }
}

class DeviceNotFoundException extends DeviceException {
  DeviceNotFoundException(super.message);
}

class DeviceNotConnectedException extends DeviceException {
  DeviceNotConnectedException(super.message);
}

class DeviceNotAvailableException extends DeviceException {
  DeviceNotAvailableException(super.message);
}

class DeviceNotReadyException extends DeviceException {
  DeviceNotReadyException(super.message);
}

class DeviceNotReachableException extends DeviceException {
  DeviceNotReachableException(super.message);
}

class DeviceNotOperationalException extends DeviceException {
  DeviceNotOperationalException(super.message);
}

class DeviceNotAvailableInProgramException extends DeviceException {
  DeviceNotAvailableInProgramException(super.message);
}

class ProgramsException extends DeviceException {
  ProgramsException(super.message);
}

class StatusException extends DeviceException {
  StatusException(super.message);
}

class SettingsException extends DeviceException {
  SettingsException(super.message);
}

class EventsException extends DeviceException {
  EventsException(super.message);
}
