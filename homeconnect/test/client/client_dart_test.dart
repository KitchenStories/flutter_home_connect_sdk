import 'dart:convert';

import 'package:homeconnect/homeconnect.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class MyMockClass extends Mock implements MyClass {}

class MockitoClient extends Mock implements http.Client {}

class MockHomeConnectApi extends Mock implements HomeConnectApi {}

class MyClass {}

class TestAuthenticator extends HomeConnectAuth {
  String baseUrl;

  TestAuthenticator({this.baseUrl = 'https://simulator.home-connect.com/'});

  @override
  Future<HomeConnectAuthCredentials> authorize(Uri baseUrl, HomeConnectClientCredentials credentials) {
    throw UnimplementedError();
  }

  @override
  Future<HomeConnectAuthCredentials> refresh(Uri baseUrl, String refreshToken) async {
    return HomeConnectAuthCredentials(
      accessToken: "refreshed",
      refreshToken: "refreshed_token",
      expirationDate: DateTime.now().add(Duration(seconds: 1000)),
    );
  }
}

class TestCredentials extends HomeConnectAuthCredentials {
  TestCredentials({
    required super.accessToken,
    required super.refreshToken,
    required super.expirationDate,
  });

  @override
  bool isAccessTokenExpired() {
    return false;
  }

  @override
  bool isRefreshTokenExpired() {
    return false;
  }
}

class TestStorage extends MemoryHomeConnectAuthStorage {
  HomeConnectAuthCredentials? credentials;

  @override
  Future<HomeConnectAuthCredentials?> getCredentials() async {
    return credentials;
  }

  @override
  Future<void> setCredentials(HomeConnectAuthCredentials credentials) async {
    this.credentials = credentials;
  }
}

void main() {
  HomeConnectApi api = HomeConnectApi(
    Uri.parse("https://example.com"),
    credentials: HomeConnectClientCredentials(
      clientId: 'clientid',
      clientSecret: 'clientsecret',
      redirectUri: 'https://example.com',
    ),
    authenticator: TestAuthenticator(),
  );
  api.storage.setCredentials(TestCredentials(
    accessToken: "test_token",
    refreshToken: "test_refresh_token",
    expirationDate: DateTime.now().add(Duration(seconds: 1000)),
  ));

  final mockClient = MockClient((request) async {
    print(request.url.path);
    if (request.url.path == "/api/homeappliances/BOSCH-HCS01OVN1-54E7EF9DEDBB") {
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

  DeviceInfo infoPayload = DeviceInfo.fromJson(info);

  final device = DeviceOven.fromPayload(api, infoPayload, [], [], [], []);

  group('Api test', () {
    test('get existing device', () async {
      final response = await api.get(device.deviceHaId);
      expect(response.body, '{"data": "oven-info"}');
    });

    test('get non existing device', () async {
      final response = await api.get('non-existing-device');
      expect(response.body, 'Not Found');
    });
  });

  group('device methods', () {
    test('getDevices returns a list of HomeDevice', () async {
      final mockResponseBody = {
        "data": {
          "homeappliances": [
            {
              "type": "Oven",
              "id": "1",
              "name": "Oven Simulator",
              "brand": "BOSCH",
              "vib": "HCS01OVN1",
              "haId": "BOSCH-HCS01OVN1-54E7EF9DEDBB",
              "enumber": "HCS01OVN1/03",
              "connected": true,
            }
          ]
        }
      };

      final mockClient = MockClient((request) async {
        return http.Response(json.encode(mockResponseBody), 200);
      });

      api.client = mockClient;

      final devices = await api.getDevices();

      expect(devices.length, 1);
      expect(devices[0], isA<DeviceOven>());
    });

    test('getPrograms should return a list of DeviceProgram ', () async {
      final mockResponseBody = {
        "data": {
          "programs": [
            {
              "key": "Cooking.Oven.Program.HeatingMode.HotAir",
            },
            {
              "key": "Cooking.Oven.Program.HeatingMode.TopBottomHeating",
            }
          ]
        }
      };

      final mockClient = MockClient((request) async {
        return http.Response(json.encode(mockResponseBody), 204);
      });

      api.client = mockClient;

      List<DeviceProgram> programs = await device.getPrograms();

      expect(programs.length, 2);
      expect(programs[0].key, 'Cooking.Oven.Program.HeatingMode.HotAir');
      expect(programs[1].key, 'Cooking.Oven.Program.HeatingMode.TopBottomHeating');
    });

    test('startProgram should not work with empty key', () async {
      final mockDevice = DeviceOven(
          api,
          DeviceInfo.fromJson(
            {
              "name": "Oven Simulator",
              "brand": "BOSCH",
              "vib": "HCS01OVN1",
              "connected": true,
              "type": "Oven",
              "enumber": "HCS01OVN1/03",
              "haId": "BOSCH-HCS01OVN1-54E7EF9DEDBB"
            },
          ),
          [],
          [],
          [],
          []);

      final mockClient = MockClient((request) async {
        return http.Response('{}', 204);
      });

      api.client = mockClient;

      // should throw an exception if no program key is provided
      expect(
          () async => mockDevice.startProgram(
                programKey: '',
                options: [
                  ProgramOptions.fromJson(
                    {
                      "key": "Cooking.Oven.Option.SetpointTemperature",
                      "value": 200,
                      "unit": "°C",
                    },
                  )
                ],
              ),
          throwsA(isA<Exception>()));
    });
  });
}
