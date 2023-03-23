import 'package:json_annotation/json_annotation.dart';

part 'setting_constraints.g.dart';

@JsonSerializable()
class SettingsConstraints {
  final List<dynamic> allowedValues;

  SettingsConstraints({required this.allowedValues});

  Map<String, dynamic> toJson() => _$SettingsConstraintsToJson(this);

  factory SettingsConstraints.fromJson(Map<String, dynamic> json) => _$SettingsConstraintsFromJson(json);
}

class AllowedValuesPayload {
  final SettingsConstraints constraints;

  AllowedValuesPayload(this.constraints);
  factory AllowedValuesPayload.fromJson(Map<String, dynamic> json) {
    var allowedValues = [];
    try {
      allowedValues = json['data']['constraints']['allowedvalues'] as List;
    } catch (e) {
      allowedValues = [];
    }
    return AllowedValuesPayload(SettingsConstraints(allowedValues: allowedValues));
  }
}
