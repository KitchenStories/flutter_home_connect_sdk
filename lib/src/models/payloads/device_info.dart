import 'package:flutter_home_connect_sdk/src/home_device.dart';
import 'package:json_annotation/json_annotation.dart';
part 'device_info.g.dart';

@JsonSerializable()
class DeviceInfo {
  final String name;
  final String brand;
  final String vib;
  final bool connected;
  final DeviceType type;
  final String enumber;
  final String haId;

  DeviceInfo(this.name, this.brand, this.vib, this.connected, this.type,
      this.enumber, this.haId);

  factory DeviceInfo.fromPayload(
      Map<String, dynamic> payload, DeviceType deviceType) {
    return DeviceInfo(payload['name'], payload['brand'], payload['vib'],
        payload['connected'], deviceType, payload['enumber'], payload['haId']);
  }

  static DeviceInfo empty() {
    return DeviceInfo('', '', '', false, DeviceType.oven, '', '');
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}