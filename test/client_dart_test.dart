import 'dart:convert';

import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';
import 'package:flutter_home_connect_sdk/src/models/washer_device.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class TestAuthenticator extends HomeConnectAuth {
  String baseUrl;

  TestAuthenticator({this.baseUrl = 'https://simulator.home-connect.com/'});

  @override
  Future<HomeConnectAuthCredentials> authorize(
      HomeConnectClientCredentials credentials) {
    throw UnimplementedError();
  }

  @override
  Future<HomeConnectAuthCredentials> refresh(String refreshToken) async {
    return HomeConnectAuthCredentials(
      accessToken: "refreshed",
      refreshToken: "refreshed_token",
    );
  }
}

class TestCredentials extends HomeConnectAuthCredentials {
  TestCredentials({
    required super.accessToken,
    required super.refreshToken,
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
    'example.com',
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
  ));

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

  DeviceInfo infoPayload = DeviceInfo.fromJson(info);

  final device = DeviceOven.fromPayload(api, infoPayload, [], [], []);

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

  test('returns a list of HomeDevice', () async {
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
          },
          {
            "type": "Washer",
            "id": "2",
            "name": "Washer Simulator",
            "brand": "BOSCH",
            "vib": "HCS01WAS1",
            "haId": "BOSCH-HCS01WAS1-54E7EF9DEDBB",
            "enumber": "HCS01WAS1/03",
            "connected": true,
          }
        ]
      }
    };

    final mockClient = MockClient((request) async {
      return http.Response(json.encode(mockResponseBody), 200);
    });

    HomeConnectApi api = HomeConnectApi(
      'example.com',
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
    ));
    api.client = mockClient;
    final devices = await api.getDevices();

    expect(devices.length, 2);
    expect(devices[0], isA<DeviceOven>());
    expect(devices[1], isA<WasherDevice>());
  });
}
