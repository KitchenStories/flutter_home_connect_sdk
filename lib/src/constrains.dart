// TODO: I think using mixins to represent constrains like range, or type would be a good idea
abstract class Constrains {
  String get key;
  final int min;
  final int max;

  Constrains(this.min, this.max);

  bool isValid(int v);

  Map<String, dynamic> toJson() => {
        'key': key,
        'min': min,
        'max': max,
      };
}
