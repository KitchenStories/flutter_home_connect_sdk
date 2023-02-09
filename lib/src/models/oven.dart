import 'dart:convert';

import 'package:flutter_home_connect_sdk/src/constrains.dart';
import 'package:flutter_home_connect_sdk/src/handlers.dart';
import 'package:flutter_home_connect_sdk/src/home_device.dart';
import 'package:flutter_home_connect_sdk/src/program.dart';
import 'package:flutter_home_connect_sdk/src/program_options.dart';

enum OvenPrograms { preHeating, hotAir, topBottomHeating, pizzaSetting }

class Oven extends HomeDevice {
  Map<OvenPrograms, Program> programs = {
    OvenPrograms.preHeating: Program("preHeating", PreHeatinOptions()),
    OvenPrograms.hotAir: Program("hotAir", HotAirOptions())
  };
  Oven(String name, String brand, String vib, bool connected, String type,
      String enumber, String haId)
      : super(name, brand, vib, connected, type, enumber, haId);

  String toJson() {
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'name': name,
      'brand': brand,
      'vib': vib,
      'connected': connected,
      'type': type,
      'enumber': enumber,
      'haId': haId,
      'programs': [
        programs[OvenPrograms.preHeating]?.name,
        programs[OvenPrograms.hotAir]?.name,
      ]
    });
  }

  late Program selectedProgram;

  String showSelectedOptions() {
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(selectedProgram);
  }

  List<int> selectedOptions = [];

  void setOptions(List<int> options) {
    options.asMap().forEach((index, value) {
      try {
        (selectedProgram.options.getConstrains()[index].isValid(value));
      } catch (e) {
        print(e);
      }
    });
  }

  // @override
  void doProgram(Program pr, String value) {
    sendOrder(this, pr, value);
  }
}

class PreHeatinOptions extends ProgramOptions {
  @override
  String get key => "Cooking.Oven.Program.HeatingMode.PreHeating";

  List<Constrains> constrainList = [
    SetpointTemperatureConstrain(30, 250),
    DurationConstrain(1, 86340),
  ];

  @override
  List<Constrains> getConstrains() {
    List<Constrains> res = [];
    for (var element in constrainList) {
      res.add(element);
    }
    return res;
  }

  @override
  String toJson() {
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(constrainList.map((e) => e.toJson()).toList());
  }

  void canDo(PreHeatinOptions pr) {}
}

class HotAirOptions extends ProgramOptions {
  @override
  String get key => "Cooking.Oven.Program.HeatingMode.HotAir";

  List<Constrains> constrainList = [
    SetpointTemperatureConstrain(30, 250),
    DurationConstrain(1, 86340),
  ];

  @override
  List<Constrains> getConstrains() {
    List<Constrains> res = [];
    for (var element in constrainList) {
      res.add(element);
    }
    return res;
  }

  @override
  String toJson() {
    throw UnimplementedError();
  }
}

class SetpointTemperatureConstrain extends Constrains {
  SetpointTemperatureConstrain(int minTemperature, int maxTemperature)
      : super(minTemperature, maxTemperature);

  @override
  String get key => "Cooking.Oven.Option.SetpointTemperature";

  @override
  bool isValid(int v) {
    if (v < min || v > max) {
      throw Exception("Value out of range");
    }
    return true;
  }
}

class DurationConstrain extends Constrains {
  DurationConstrain(int minSeconds, int maxSeconds)
      : super(minSeconds, maxSeconds);

  @override
  String get key => "BSH.Common.Option.Duration";

  @override
  bool isValid(int v) {
    if (v < min || v > max) {
      throw Exception("Value out of range");
    }
    return true;
  }
}
