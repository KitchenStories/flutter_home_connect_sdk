import 'package:homeconnect/src/home_device.dart';
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

  DeviceInfo(this.name, this.brand, this.vib, this.connected, this.type, this.enumber, this.haId);

  static DeviceInfo empty() {
    return DeviceInfo('', '', '', false, DeviceType.oven, '', '');
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        json['name'] as String,
        json['brand'] as String,
        json['vib'] as String,
        json['connected'] as bool,
        deviceTypeMap[json['type']]!,
        json['enumber'] as String,
        json['haId'] as String,
      );

  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);
}
