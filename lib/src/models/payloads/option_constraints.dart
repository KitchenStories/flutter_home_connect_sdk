import 'package:json_annotation/json_annotation.dart';

part 'option_constraints.g.dart';

@JsonSerializable()
class OptionConstraints {
  final int min;
  final int max;
  final int stepsize;

  OptionConstraints({this.min = 0, this.max = 100, this.stepsize = 1});

  factory OptionConstraints.fromPayload(Map<String, dynamic> json) {
    return OptionConstraints(
      min: json['min'] as int? ?? 0,
      max: json['max'] as int? ?? 100,
      stepsize: json['stepsize'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => _$OptionConstraintsToJson(this);

  factory OptionConstraints.fromJson(Map<String, dynamic> json) =>
      _$OptionConstraintsFromJson(json);
}
