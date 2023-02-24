import 'package:json_annotation/json_annotation.dart';

part 'option_constraints.g.dart';

@JsonSerializable()
class OptionConstraints {
  final int min;
  final int max;
  final int stepsize;

  OptionConstraints({this.min = 0, this.max = 100, this.stepsize = 1});

  Map<String, dynamic> toJson() => _$OptionConstraintsToJson(this);

  factory OptionConstraints.fromJson(Map<String, dynamic> json) => _$OptionConstraintsFromJson(json);
}
