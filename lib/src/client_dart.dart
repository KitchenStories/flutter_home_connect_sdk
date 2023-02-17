import 'dart:async';
import 'dart:convert';
import 'package:eventsource/eventsource.dart';
import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';
import 'package:flutter_home_connect_sdk/src/models/coffee_device.dart';
import 'package:flutter_home_connect_sdk/src/models/dryer_device.dart';
import 'package:flutter_home_connect_sdk/src/models/fridge_freezer_device.dart';
import 'package:flutter_home_connect_sdk/src/models/washer_device.dart';

import 'package:http/http.dart' as http;

import 'models/dishwasher_device.dart';

class HomeConnectApi {
  late http.Client client;
  String baseUrl;
  String accessToken;
  late final HomeDevice devices;
  late StreamSubscription<Event> subscription;
  HomeConnectClientCredentials credentials;

  HomeConnectAuth? authenticator;

  HomeConnectApi(
    this.baseUrl, {
    required this.accessToken,
    required this.credentials,
    this.authenticator,
  }) {
    client = http.Client();
  }

  Future<void> authenticate() {
    if (authenticator == null) {
      throw Exception('No authenticator provided');
    }
    return authenticator!.authorize(credentials).then((credentials) {
      accessToken = credentials.accessToken;
    });
  }

  Future<http.Response> put(
      {required String resource,
      required Map<String, String> headers,
      required String body}) async {
    var path = '$baseUrl/$resource';
    final uri = Uri.tryParse(path);
    if (uri == null) {
      throw Exception('Invalid URI: $path');
    }
    final response = await client.put(uri, headers: commonHeaders, body: body);
    return response;
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
            DeviceInfo info = DeviceInfo.fromJson(device);
            result.add(DeviceOven.fromInfoPayload(this, info));

            break;
          case 'Dryer':
            DryerDevice mock = DryerDevice(
              this,
              DeviceInfo.fromJson(device),
              [],
              [],
              [],
            );
            result.add(mock);
            break;
          case 'Washer':
            WasherDevice mock = WasherDevice(
              this,
              DeviceInfo.fromJson(device),
              [],
              [],
              [],
            );
            result.add(mock);
            break;
          case 'Dishwasher':
            DishwasherDevice mock = DishwasherDevice(
              this,
              DeviceInfo.fromJson(device),
              [],
              [],
              [],
            );
            result.add(mock);
            break;
          case 'FridgeFreezer':
            FridgeFreezerDevice mock = FridgeFreezerDevice(
              this,
              DeviceInfo.fromJson(device),
              [],
              [],
              [],
            );
            result.add(mock);
            break;
          case 'CoffeeMaker':
            CoffeeDevice mock = CoffeeDevice(
              this,
              DeviceInfo.fromJson(device),
              [],
              [],
              [],
            );
            result.add(mock);
            break;
          default:
            throw Exception('Unknown device type: $deviceType');
        }
      }
      return result;
    } else {
      throw Exception('Error getting devices: ${response.body}');
    }
  }

  Future<HomeDevice> getDevice(HomeDevice device) async {
    final devicePrograms = await getPrograms(haId: device.info.haId);
    final statResponse = await getStatus(device.info.haId);
    final deviceType = device.info.type;
    switch (deviceType) {
      case DeviceType.oven:
        device.programs = devicePrograms;
        device.status = statResponse;
        return device;

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
      if (response.statusCode != 204) {}
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> startProgram(
      {required String haid,
      required String programKey,
      required Map<String, int> options}) async {
    final path = "$haid/programs/active";

    final headers = commonHeaders;
    final body = json.encode({
      'data': {
        'key': programKey,
        'options': options.entries
            .map((e) => {'key': e.key, 'value': e.value})
            .toList()
      }
    });

    try {
      final response = await put(resource: path, headers: headers, body: body);
      if (response.statusCode != 204) {}
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> pauseProgram({required String haid}) async {
    final path = "$baseUrl/$haid/commands/BSH.Common.Command.PauseProgram";
    final uri = Uri.tryParse(path);
    if (uri == null) {
      throw Exception('Invalid URI: $path');
    }
    final headers = commonHeaders;
    final body = json.encode({
      'data': {
        'key': 'BSH.Common.Command.PauseProgram',
        'value': true,
      }
    });

    try {
      final response = await http.put(uri, headers: headers, body: body);
      if (response.statusCode != 204) {}
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

  Future<List<DeviceOptions>> getProgramOptionsConstraints(
      {required String haId, required String programKey}) async {
    String path = "$haId/programs/available/$programKey";
    var res = await get(path);
    var data = json.decode(res.body);
    // Each program contains a list of options so we need to loop through each
    // option and then we create a DeviceOption object from the payload
    List<DeviceOptions> options = (data['data']['options'] as List)
        .map((e) => DeviceOptions.fromJson(e))
        .toList();
    return options;
  }

  Future<List<DeviceOptions>> getSelectedProgramOptions({String? haId}) async {
    String deviceHaId = haId ?? devices.info.haId;
    String path = "$deviceHaId/programs/selected";
    var res = await get(path);
    var data = json.decode(res.body);
    // Each program contains a list of options so we need to loop through each
    // option and then we create a DeviceOption object from the payload
    List<DeviceOptions> options = (data['data']['options'] as List)
        .map((e) => DeviceOptions.fromJson(e))
        .toList();
    return options;
  }

  Future<void> selectProgram({
    String? haid,
    required String programKey,
  }) async {
    String deviceHaId = haid ?? devices.info.haId;
    final path = "$baseUrl/$deviceHaId/programs/selected";
    final uri = Uri.tryParse(path);
    if (uri == null) {
      throw Exception('Invalid URI: $path');
    }
    final headers = commonHeaders;
    final body = json.encode({
      'data': {
        'key': programKey,
      }
    });

    try {
      final response = await http.put(uri, headers: headers, body: body);
      if (response.statusCode == 204) {
        print("Program selected successfully: $programKey");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<DeviceStatus>> getStatus(String haId) {
    Map<String, dynamic> statResponse = {
      "data": {
        "status": [
          {"key": "BSH.Common.Status.RemoteControlActive", "value": 'true'},
          {
            "key": "BSH.Common.Status.RemoteControlStartAllowed",
            "value": 'true'
          },
          {
            "key": "BSH.Common.Status.OperationState",
            "value": "BSH.Common.EnumType.OperationState.Ready"
          },
          {
            "key": "BSH.Common.Status.DoorState",
            "value": "BSH.Common.EnumType.DoorState.Closed"
          },
          {"key": "Cooking.Oven.Status.CurrentCavityTemperature", "value": '20'}
        ]
      }
    };
    List<DeviceStatus> stList = (statResponse['data']['status'] as List)
        .map((e) => DeviceStatus.fromJson(e))
        .toList();
    var response = Future.delayed(Duration(seconds: 1), () => stList);
    return response;
  }

  Future<List<DeviceProgram>> getPrograms({String? haId}) async {
    String deviceHaid = haId ?? devices.info.haId;
    // Map<String, dynamic> programsResponse = {
    //   "data": {
    //     "programs": [
    //       {
    //         "key": "Cooking.Oven.Program.HeatingMode.PreHeating",
    //         "constraints": {"available": true, "execution": "selectandstart"}
    //       },
    //       {
    //         "key": "Cooking.Oven.Program.HeatingMode.HotAir",
    //         "constraints": {"available": true, "execution": "selectandstart"}
    //       },
    //       {
    //         "key": "Cooking.Oven.Program.HeatingMode.TopBottomHeating",
    //         "constraints": {"available": true, "execution": "selectandstart"}
    //       },
    //       {
    //         "key": "Cooking.Oven.Program.HeatingMode.PizzaSetting",
    //         "constraints": {"available": true, "execution": "selectandstart"}
    //       }
    //     ]
    //   }
    // };

    String path = "$deviceHaid/programs/available";
    final res = await get(path);
    final List<DeviceProgram> programs =
        (json.decode(res.body)['data']['programs'] as List)
            .map((e) => DeviceProgram.fromJson(e))
            .toList();
    // List<DeviceProgram> programs =
    //     (programsResponse['data']['programs'] as List)
    //         .map((e) => DeviceProgram.fromJson(e))
    //         .toList();
    // // Loop through each program from programResponse
    // for (var devProgram in programs) {
    //   var options =
    //       await getProgramOptions(haId: haId, programKey: devProgram.key);
    //   devProgram.options = options;
    // }
    return programs;
  }
}
