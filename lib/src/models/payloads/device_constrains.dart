import 'package:json_annotation/json_annotation.dart';

part 'device_constrains.g.dart';

@JsonSerializable()
class DeviceConstrains {
  final int min;
  final int max;
  final int stepsize;

  DeviceConstrains({this.min = 0, this.max = 100, this.stepsize = 5});

  factory DeviceConstrains.fromPayload(Map<String, dynamic> json) {
    return DeviceConstrains(
      min: json['min'] as int? ?? 0,
      max: json['max'] as int? ?? 100,
      stepsize: json['stepsize'] as int? ?? 5,
    );
  }

  factory DeviceConstrains.fromJson(Map<String, dynamic> json) =>
      _$DeviceConstrainsFromJson(json);
}
