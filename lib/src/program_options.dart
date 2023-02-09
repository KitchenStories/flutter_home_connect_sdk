import 'package:flutter_home_connect_sdk/src/constrains.dart';

abstract class ProgramOptions {
  String get key;
  List<Constrains> getConstrains();

  String toJson();
}
