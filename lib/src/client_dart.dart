import 'dart:async';
import 'dart:convert';
import 'package:eventsource/eventsource.dart';

import 'package:flutter_home_connect_sdk/src/home_device.dart';
import 'package:flutter_home_connect_sdk/src/models/oven_device.dart';
import 'package:http/http.dart' as http;

class HomeConnectApi {
  late http.Client client;
  String baseUrl;
  String accessToken;
  late final HomeDevice devices;
  late StreamSubscription<Event> subscription;

  HomeConnectApi(this.baseUrl, {required this.accessToken}) {
    client = http.Client();
    Map<String, dynamic> info = {
      "name": "Oven Simulator",
      "brand": "BOSCH",
      "vib": "HCS01OVN1",
      "connected": true,
      "type": "Oven",
      "enumber": "HCS01OVN1/03",
      "haId": "BOSCH-HCS01OVN1-54E7EF9DEDBB"
    };

    Map<String, dynamic> someResponse = {
      "data": {
        "key": "Cooking.Oven.Program.HeatingMode.PreHeating",
        "options": [
          {
            "key": "Cooking.Oven.Option.SetpointTemperature",
            "type": "Int",
            "unit": "°C",
            "constraints": {"min": 30, "max": 250, "stepsize": 5}
          },
          {
            "key": "BSH.Common.Option.Duration",
            "type": "Int",
            "unit": "seconds",
            "constraints": {"min": 1, "max": 86340}
          }
        ]
      }
    };

    Map<String, dynamic> someStatResponse = {
      "data": {
        "status": [
          {"key": "BSH.Common.Status.RemoteControlActive", "value": true},
          {"key": "BSH.Common.Status.RemoteControlStartAllowed", "value": true},
          {
            "key": "BSH.Common.Status.OperationState",
            "value": "BSH.Common.EnumType.OperationState.Ready"
          },
          {
            "key": "BSH.Common.Status.DoorState",
            "value": "BSH.Common.EnumType.DoorState.Closed"
          },
          {"key": "Cooking.Oven.Status.CurrentCavityTemperature", "value": 20}
        ]
      }
    };

    devices = DeviceOven.fromPayload(
        this, info, someResponse['data'], someStatResponse['data']);
  }

  Future<http.Response> get(String resource) async {
    var path = '$baseUrl/$resource';
    final uri = Uri.tryParse(path);
    if (uri == null) {
      throw Exception('Invalid URI: $path');
    }
    final response = await client.get(
      uri,
      headers: commonHeaders,
    );
    return response;
  }

  Map<String, String> get commonHeaders {
    final result = <String, String>{};
    result['Authorization'] = 'Bearer $accessToken';
    result['Content-Type'] = 'application/vnd.bsh.sdk.v1+json';
    return result;
  }

  Future<void> putPowerState(
      String haId, String settingKey, Map<String, dynamic> payload) async {
    final path = "$baseUrl/$haId/settings/$settingKey";
    final uri = Uri.tryParse(path);
    if (uri == null) {
      throw Exception('Invalid URI: $path');
    }
    final headers = commonHeaders;
    final body = json.encode(payload);

    try {
      final response = await http.put(uri, headers: headers, body: body);
      if (response.statusCode != 204) {
        print(response.body);
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> startListening(String haid, Function callback) async {
    final path = "$baseUrl/$haid/events";
    final uri = Uri.tryParse(path);
    if (uri == null) {
      throw Exception('Invalid URI: $path');
    }
    final headers = commonHeaders;

    EventSource eventSource = await EventSource.connect(
      uri.toString(),
      headers: headers,
    );

    subscription = eventSource.listen((Event event) {
      callback(event);
    });
  }
}
