import 'dart:convert';
import 'package:homeconnect/src/models/event/device_event.dart';
import 'package:http/http.dart' as http;

/// Returns a copy of the map with all null values removed.
Map<String, dynamic> compact(Map<String, dynamic> map) {
  var copy = Map<String, dynamic>.from(map);
  return copy..removeWhere((key, value) => value == null);
}

Future<void> honeyPotLog(List<DeviceEvent> eventData) async {
  var url = Uri.parse('https://honeypot.codes/pot/01GV1AR66KPSQZF2JNYB0BMST8');
  var headers = {'Content-Type': 'application/json'};
  var data = eventData.map((e) => e.toJson()).toList();
  var body = jsonEncode({'data': data});

  var response = await http.post(url, headers: headers, body: body);
  print(response.statusCode);
  print(response.body);
}
