import 'dart:convert';

import 'package:homeconnect/src/client/client_dart.dart';
import 'package:homeconnect/src/models/devices/oven_device.dart';
import 'package:homeconnect/src/models/info/device_info.dart';
import 'package:homeconnect/src/oauth/auth.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import '../client/client_dart_test.dart';

class MockApi extends Mock implements HomeConnectApi {
  @override
  Future<http.Response> put({required String resource, required String body}) async {
    return noSuchMethod(Invocation.method(#put, [resource, body]),
        returnValue: Future.value(http.Response('{"data": "oven-info"}', 204)));
  }
}

main() {
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

  final oven = DeviceOven.fromPayload(api, infoPayload, [], [], [], []);

  group('Oven specific methods', () {
    test('should send a power request with valid data', () async {
      final mockApi = MockApi();
      final mockOven = DeviceOven(mockApi, infoPayload, [], [], [], []);

      String expectedResource = 'BOSCH-HCS01OVN1-54E7EF9DEDBB/settings/BSH.Common.Setting.PowerState';
      String expectedBody = jsonEncode({
        "data": {
          "key": "BSH.Common.Setting.PowerState",
          "value": "BSH.Common.EnumType.PowerState.On",
        },
      });

      when(mockApi.put(resource: expectedResource, body: expectedBody)).thenAnswer((_) async => http.Response('', 204));

      mockOven.turnOn();

      verify(mockApi.put(resource: expectedResource, body: expectedBody)).called(1);
    });
  });
}
