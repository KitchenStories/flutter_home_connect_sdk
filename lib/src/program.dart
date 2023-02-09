import 'package:flutter_home_connect_sdk/src/program_options.dart';

class Program {
  final String name;
  final ProgramOptions options;
  Program(this.name, this.options);

  Map<String, dynamic> toJson() => {
        'name': name,
        'options': options.toJson(),
      };
}
