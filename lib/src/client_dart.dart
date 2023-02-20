import 'dart:async';
import 'dart:convert';
import 'package:eventsource/eventsource.dart';
import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

import 'package:http/http.dart' as http;

class HomeConnectApi {
  late http.Client client;
  String baseUrl;
  String _accessToken = '';
  late final HomeDevice devices;
  late StreamSubscription<Event> subscription;
  /// oauth client credentials
  HomeConnectClientCredentials credentials;
  HomeConnectAuth? authenticator;
  HomeConnectAuthStorage storage = MemoryHomeConnectAuthStorage();

  Map<String, dynamic> optionsResponse = {
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

  Map<String, dynamic> info = {
    "name": "Oven Simulator",
    "brand": "BOSCH",
    "vib": "HCS01OVN1",
    "connected": true,
    "type": "Oven",
    "enumber": "HCS01OVN1/03",
    "haId": "BOSCH-HCS01OVN1-54E7EF9DEDBB"
  };

  Map<String, dynamic> statResponse = {
    "data": {
      "status": [
        {"key": "BSH.Common.Status.RemoteControlActive", "value": true},
        {"key": "BSH.Common.Status.RemoteControlStartAllowed", "value": true},
        {"key": "BSH.Common.Status.OperationState", "value": "BSH.Common.EnumType.OperationState.Ready"},
        {"key": "BSH.Common.Status.DoorState", "value": "BSH.Common.EnumType.DoorState.Closed"},
        {"key": "Cooking.Oven.Status.CurrentCavityTemperature", "value": 20}
      ]
    }
  };

  HomeConnectApi(
    this.baseUrl,
    {
      required this.credentials,
      HomeConnectAuthStorage? storage,
      this.authenticator,
    }) {
    client = http.Client();

    devices = DeviceOven.fromPayload(this, info, optionsResponse['data'], statResponse['data']);

    // set default storage
    if (storage != null) {
      this.storage = storage;
    }
  }

  void setAuthenticator(HomeConnectAuth authenticator) {
    this.authenticator = authenticator;
  }

  Future<void> authenticate() async {
    if (authenticator == null) {
      throw Exception('No authenticator provided');
    }
    final token = await authenticator!.authorize(credentials);
    storage.setCredentials(token);
  }

  Future<bool> shouldRefreshToken() async {
    final userCredentials = await storage.getCredentials();
    print("User has access token ${userCredentials?.accessToken}");
    if (userCredentials == null || userCredentials.isAccessTokenExpired()) {
      return true;
    }
    return false;
  }

  Future<void> refreshToken() async {
    if (authenticator == null) {
      throw Exception('No authenticator provided');
    }
    final userCredentials = await storage.getCredentials();
    final tokens = await authenticator?.refresh(userCredentials!.refreshToken);
    if (tokens == null) {
      throw Exception('Failed to refresh token');
    }
    // set token in storage
    await storage.setCredentials(tokens);
  }

  Future<http.Response> get(String resource) async {
    if (await shouldRefreshToken()) {
      await refreshToken();
    }

    final userCredentials = await storage.getCredentials();
    _accessToken = userCredentials!.accessToken;
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
    result['Authorization'] = 'Bearer $_accessToken';
    result['Content-Type'] = 'application/vnd.bsh.sdk.v1+json';
    return result;
  }

  Future<List<HomeDevice>> getDevices() async {
    final response = await get('');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> devices = data['data']['homeappliances'];
      final result = <HomeDevice>[];
      for (final device in devices) {
        // final settings = await getSettings(haId);
        // final status = await getStatus(haId);
        final deviceType = device['type'];
        switch (deviceType) {
          case 'Oven':
            DeviceType deviceType = deviceTypeMap[device['type']]!;
            DeviceInfo info = DeviceInfo.fromPayload(device, deviceType);
            result.add(DeviceOven.fromInfoPayload(this, info));
            break;
          case 'Dryer':
            // result.add(DeviceDryer.fromPayload(this, device, settings, status));
            break;
          case 'Washer':
            // result.add(DeviceWasher.fromPayload(this, device, settings, status));
            break;
          case 'Dishwasher':
            // result.add(DeviceDishwasher.fromPayload(this, device, settings, status));
            break;
          case 'FridgeFreezer':
            // result.add(DeviceFridgeFreezer.fromPayload(this, device, settings, status));
            break;
          case 'CoffeeMaker':
            // result.add(DeviceCoffeeMaker.fromPayload(this, device, settings, status));
            break;
          default:
            throw Exception('Unknown device type: $deviceType');
        }
      }
      print(result);
      return result;
    } else {
      throw Exception('Error getting devices: ${response.body}');
    }
  }

  Future<HomeDevice> getDevice(HomeDevice device) async {
    //final programsResponse = await getOptions(device.info.haId);
    //final statResponse = await getStatus(device.info.haId);
    final deviceType = device.info.type;
    switch (deviceType) {
      case DeviceType.oven:
        // DeviceOven.fromPayload(
        //     this, device.info, programsResponse['data'], statResponse['data']);
        // device.options = programsResponse;
        // device.status = statResponse;
        break;
      case DeviceType.dryer:
        // result.add(DeviceDryer.fromPayload(this, device, settings, status));
        break;
      case DeviceType.washer:
        // result.add(DeviceWasher.fromPayload(this, device, settings, status));
        break;
      case DeviceType.dishwasher:
        // result.add(DeviceDishwasher.fromPayload(this, device, settings, status));
        break;
      case DeviceType.fridgeFreezer:
        // result.add(DeviceFridgeFreezer.fromPayload(this, device, settings, status));
        break;
      case DeviceType.coffeeMaker:
        // result.add(DeviceCoffeeMaker.fromPayload(this, device, settings, status));
        break;
      default:
        throw Exception('Unknown device type: $deviceType');
    }

    HomeDevice? h;
    return h!;
  }

  Future<void> putPowerState(String haId, String settingKey, Map<String, dynamic> payload) async {
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

  Future<DeviceOptions> getOptions(String haId) {
    Map<String, dynamic> programsResponse = {
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
    DeviceOptions op = DeviceOptions.fromPayload(programsResponse['data']);
    var options = Future.delayed(Duration(seconds: 1), () => op);
    return options;
  }

  Future<DeviceStatus> getStatus(String haId) {
    Map<String, dynamic> statResponse = {
      "data": {
        "status": [
          {"key": "BSH.Common.Status.RemoteControlActive", "value": true},
          {"key": "BSH.Common.Status.RemoteControlStartAllowed", "value": true},
          {"key": "BSH.Common.Status.OperationState", "value": "BSH.Common.EnumType.OperationState.Ready"},
          {"key": "BSH.Common.Status.DoorState", "value": "BSH.Common.EnumType.DoorState.Closed"},
          {"key": "Cooking.Oven.Status.CurrentCavityTemperature", "value": 20}
        ]
      }
    };
    DeviceStatus st = DeviceStatus.fromPayload(statResponse['data']);
    var response = Future.delayed(Duration(seconds: 1), () => st);
    return response;
  }
}
