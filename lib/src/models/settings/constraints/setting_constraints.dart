import 'package:json_annotation/json_annotation.dart';

part 'setting_constraints.g.dart';

@JsonSerializable()
class SettingsConstraints {
  final List<dynamic> allowedValues;

  SettingsConstraints({required this.allowedValues});

  Map<String, dynamic> toJson() => _$SettingsConstraintsToJson(this);

  factory SettingsConstraints.fromJson(Map<String, dynamic> json) => _$SettingsConstraintsFromJson(json);
}
