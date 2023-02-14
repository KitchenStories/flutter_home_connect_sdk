import 'package:flutter_home_connect_sdk/src/client_dart.dart';
import 'package:flutter_home_connect_sdk/src/models/oven_device.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  HomeConnectApi api = HomeConnectApi('example.com', accessToken: 'sometoken');
  final mockClient = MockClient((request) async {
    if (request.url.path == "/success") {
      return http.Response('{"data": "some data"}', 200);
    } else if (request.url.path == "/bad-request") {
      return http.Response('{"error": "Bad Request"}', 400);
    } else if (request.url.path == "/no-content") {
      return http.Response('', 204);
    } else if (request.url.path == "example.com/BOSCH-HCS01OVN1-54E7EF9DEDBB") {
      return http.Response('{"data": "oven-info"}', 204);
    }
    return http.Response('Not Found', 404);
  });

  api.client = mockClient;

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

  Map<String, dynamic> someProgramResponse = {};
  final device = DeviceOven.fromPayload(api, info, someResponse['data'],
      someStatResponse['data'], someProgramResponse);

  group('Api test', () {
    test('correct uri', () async {
      final path = Uri.tryParse('/success');
      if (path == null) {
        throw Exception('Invalid path');
      }
      final response = await api.client.get(path, headers: api.commonHeaders);
      expect(response.body, '{"data": "some data"}');
    });

    test('bad uri', () async {
      final path = Uri.tryParse('/bad-request');
      if (path == null) {
        throw Exception('Invalid path');
      }
      final response = await api.client.get(path, headers: api.commonHeaders);
      expect(response.body, '{"error": "Bad Request"}');
    });

    test('no results', () async {
      final path = Uri.tryParse('/no-content');
      if (path == null) {
        throw Exception('Invalid path');
      }
      final response = await api.client.get(path, headers: api.commonHeaders);
      expect(response.body, '');
    });

    test('get existing device', () async {
      final response = await api.get(device.deviceHaId);
      expect(response.body, '{"data": "oven-info"}');
    });

    test('get non existing device', () async {
      final response = await api.get('non-existing-device');
      expect(response.body, 'Not Found');
    });
  });
}